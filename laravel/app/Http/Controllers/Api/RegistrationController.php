<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Event;
use App\Models\EventRegistration;
use App\Models\User;

class RegistrationController extends Controller
{
    /**
     * Sinh viên đăng ký tham gia sự kiện
     */
    public function register(Request $request)
    {
        $request->validate([
            'user_id' => 'required|exists:users,id',
            'event_id' => 'required|exists:events,id',
        ]);

        $user = User::find($request->user_id);
        
        if ($user->isRegisteredFor($request->event_id)) {
            return response()->json([
                'status' => false,
                'message' => 'Bạn đã đăng ký sự kiện này rồi!'
            ], 400);
        }

        $registration = EventRegistration::create([
            'user_id' => $request->user_id,
            'event_id' => $request->event_id,
            'registration_time' => now(),
            'status' => 'registered'
        ]);

        return response()->json([
            'status' => true,
            'message' => 'Đăng ký sự kiện thành công!',
            'data' => $registration
        ]);
    }

    /**
     * Lấy danh sách sự kiện mà user đã đăng ký
     */
    public function myEvents($userId)
    {
        $user = User::findOrFail($userId);
        $events = $user->registeredEvents()
                        ->where('is_active', true)
                        ->orderBy('start_time', 'asc')
                        ->get();

        return response()->json([
            'status' => true,
            'data' => $events
        ]);
    }

    /**
     * Lấy danh sách sinh viên đã đăng ký cho một sự kiện (Admin)
     */
    public function eventStudents($eventId)
    {
        $registrations = EventRegistration::with('user')
                                        ->where('event_id', $eventId)
                                        ->get();

        return response()->json([
            'status' => true,
            'data' => $registrations
        ]);
    }
}
