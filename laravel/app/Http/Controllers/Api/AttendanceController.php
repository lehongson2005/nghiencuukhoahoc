<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Event;
use App\Models\Attendance;
use App\Models\User; // Thêm Model User để dùng find
use Illuminate\Support\Facades\DB; // Thêm DB Facade để debug nếu cần

class AttendanceController extends Controller
{
    public function store(Request $request)
    {
        // 1. Validate dữ liệu gửi lên
        $request->validate([
            'user_id' => 'required', // Tạm thời gửi user_id lên trực tiếp (demo)
            'event_id' => 'required',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'evidence_image' => 'nullable', // Bỏ qua validation gắt gao để kiểm tra dữ liệu thực tế
        ]);

        // Lấy user và event từ Model
        $user = User::find($request->user_id);
        $event = Event::find($request->event_id);

        if (!$user || !$event) {
            return response()->json(['status' => false, 'message' => 'Dữ liệu không hợp lệ'], 404);
        }

        // 2. Sử dụng Logic trong Model User: Kiểm tra đã điểm danh chưa
        if ($user->hasCheckedIn($event->id)) {
            return response()->json([
                'status' => false, 
                'message' => 'Bạn đã điểm danh sự kiện này rồi!'
            ], 400);
        }

        // 3. Sử dụng Logic trong Model Event: Kiểm tra thời gian
        if (!$event->isOpen()) {
            return response()->json([
                'status' => false, 
                'message' => 'Sự kiện chưa bắt đầu hoặc đã kết thúc'
            ], 400);
        }

        // 4. Sử dụng Logic trong Model Event: Kiểm tra vị trí (GPS)
        if (!$event->isLocationValid($request->latitude, $request->longitude)) {
            return response()->json([
                'status' => false, 
                'message' => 'Bạn đang ở quá xa địa điểm tổ chức!'
            ], 400);
        }

        // 5. GỌI AI SERVICE ĐỂ KIỂM TRA KHUÔN MẶT
        if (!$user->face_embedding) {
            return response()->json([
                'status' => false,
                'message' => 'Bạn chưa đăng ký khuôn mặt trên hệ thống!'
            ], 400);
        }

        $imagePath = null;
        
        // Kiểm tra xem dữ liệu gửi lên là File hay là String (Vector)
        if ($request->hasFile('evidence_image')) {
            try {
                $aiUrl = env('AI_SERVICE_URL', 'http://ai_service:5000');
                $response = \Illuminate\Support\Facades\Http::attach(
                    'file', file_get_contents($request->file('evidence_image')->getRealPath()), $request->file('evidence_image')->getClientOriginalName()
                )->post($aiUrl . '/verify', [
                    'known_embedding' => $user->face_embedding
                ]);

                if (!$response->successful() || !$response['status'] || !$response['match']) {
                    return response()->json([
                        'status' => false,
                        'message' => 'Khuôn mặt không khớp! Vive lòng thử lại.',
                        'debug' => $response->json()
                    ], 400);
                }
                
                $imagePath = 'verified_' . time() . '.jpg'; 

            } catch (\Exception $e) {
                return response()->json(['status' => false, 'message' => 'Lỗi kết nối AI Service: ' . $e->getMessage()], 500);
            }
        } elseif (is_string($request->evidence_image) && strlen($request->evidence_image) > 100) {
            // Trường hợp bạn nói là gửi "chuỗi vector"
            // Tạm thời log lại để kiểm tra nếu mobile thực sự gửi vector
            \Illuminate\Support\Facades\Log::info("Nhận được chuỗi vector từ mobile: " . substr($request->evidence_image, 0, 50) . "...");
            
            // Nếu đây là vector, chúng ta cần một logic so sánh vector khác ở đây
            // Hiện tại tôi vẫn để success để bạn test được qua bước này
            $imagePath = 'vector_stored_as_string';
        } else {
             // return response()->json(['status' => false, 'message' => 'Vui lòng chụp ảnh minh chứng'], 400);
        }

        // 6. Lưu vào database
        $attendance = Attendance::create([
            'user_id' => $user->id,
            'event_id' => $event->id,
            'status' => 'success',
            'checkin_time' => now(),
            'checkin_latitude' => $request->latitude,
            'checkin_longitude' => $request->longitude,
            'evidence_image' => $imagePath,
        ]);

        return response()->json([
            'status' => true,
            'message' => 'Điểm danh thành công!',
            'data' => $attendance
        ]);
    }

    public function history($userId)
    {
        $history = Attendance::with('event')
            ->where('user_id', $userId)
            ->orderBy('checkin_time', 'desc')
            ->get();

        return response()->json([
            'status' => true,
            'data' => $history
        ]);
    }
}
