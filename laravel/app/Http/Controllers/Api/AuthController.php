<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\User;

class AuthController extends Controller
{
    /**
     * Đăng nhập lấy thông tin user
     */
    public function login(Request $request)
    {
        $credentials = $request->validate([
            'mssv' => 'required', // Đăng nhập bằng MSSV
            'password' => 'required',
        ]);

        if (Auth::attempt(['mssv' => $request->mssv, 'password' => $request->password])) {
            $user = Auth::user();
            // Trong thực tế nên dùng $user->createToken('authToken')->plainTextToken; (nếu cài Sanctum)
            
            return response()->json([
                'status' => true,
                'message' => 'Đăng nhập thành công',
                'data' => $user
            ]);
        }

        return response()->json([
            'status' => false,
            'message' => 'Thông tin đăng nhập không chính xác',
        ], 401);
    }

    /**
     * Lấy thông tin user hiện tại
     */
    public function me(Request $request)
    {
        return response()->json([
            'status' => true,
            'data' => $request->user()
        ]);
    }

    /**
     * Đăng ký khuôn mặt (Gửi ảnh lên Python để lấy vector)
     */
    public function registerFace(Request $request)
    {
        $request->validate([
            'user_id' => 'required',
            'image' => 'required|file|mimes:jpg,jpeg,png,bmp'
        ]);

        $user = User::find($request->user_id);
        if (!$user) {
            return response()->json(['status' => false, 'message' => 'User not found'], 404);
        }

        // Gọi sang Python Service
        try {
            $imageFile = $request->file('image');
            $response = \Illuminate\Support\Facades\Http::attach(
                'file', file_get_contents($imageFile->getRealPath()), $imageFile->getClientOriginalName()
            )->post('http://ai_service:5000/represent'); // Tên service trong Docker Compose

            if ($response->successful() && $response['status'] == true) {
                // Lưu file ảnh vào storage/public/faces
                $path = $imageFile->store('public/faces');
                $publicPath = str_replace('public/', 'storage/', $path);

                // Lưu vector và đường dẫn ảnh vào database
                $user->face_embedding = $response['embedding'];
                $user->face_image_path = $publicPath;
                $user->save();

                return response()->json([
                    'status' => true,
                    'message' => 'Đăng ký khuôn mặt thành công!',
                    'data' => $user
                ]);
            }

            return response()->json([
                'status' => false,
                'message' => 'Không thể xử lý ảnh: ' . ($response['error'] ?? 'Unknown error'),
            ], 400);

        } catch (\Exception $e) {
            return response()->json(['status' => false, 'message' => $e->getMessage()], 500);
        }
    }
}
