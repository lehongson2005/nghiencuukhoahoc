<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Event;
use App\Models\Attendance;

class AdminController extends Controller
{
    public function stats()
    {
        return response()->json([
            'status' => true,
            'data' => [
                'total_users' => User::where('role', 'student')->count(),
                'active_events' => Event::where('is_active', true)->count(),
                'total_attendances' => Attendance::where('status', 'success')->count(),
            ]
        ]);
    }

    // Event CRUD
    public function getEvents()
    {
        return response()->json(['status' => true, 'data' => Event::orderBy('created_at', 'desc')->get()]);
    }

    public function createEvent(Request $request)
    {
        $data = $request->validate([
            'title' => 'required',
            'description' => 'nullable|string',
            'latitude' => 'required',
            'longitude' => 'required',
            'radius' => 'required',
            'start_time' => 'required|date',
            'end_time' => 'required|date',
        ]);

        $data['is_active'] = true;
        
        $event = Event::create($data);
        return response()->json(['status' => true, 'data' => $event]);
    }

    // Student Management
    public function getUsers()
    {
        $users = User::where('role', 'student')
            ->orderBy('name', 'asc')
            ->get();
            
        return response()->json(['status' => true, 'data' => $users]);
    }

    public function resetFace($id)
    {
        $user = User::findOrFail($id);
        
        // Xóa file ảnh vật lý nếu có
        if ($user->face_image_path) {
            $path = str_replace('storage/', 'public/', $user->face_image_path);
            \Illuminate\Support\Facades\Storage::delete($path);
        }

        $user->face_embedding = null;
        $user->face_image_path = null;
        $user->save();

        return response()->json([
            'status' => true,
            'message' => 'Đã xóa dữ liệu khuôn mặt. Sinh viên có thể đăng ký lại.'
        ]);
    }
}
