<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Event;

class EventController extends Controller
{
    /**
     * Lấy danh sách sự kiện (có thể lọc theo ngày)
     */
    public function index()
    {
        // Lấy các sự kiện đang active và chưa kết thúc
        $events = Event::where('is_active', true)
                        ->where('end_time', '>=', now())
                        ->orderBy('start_time', 'desc')
                        ->get();

        return response()->json([
            'status' => true,
            'data' => $events
        ]);
    }

    /**
     * Xem chi tiết sự kiện
     */
    public function show($id)
    {
        $event = Event::find($id);

        if (!$event) {
            return response()->json(['status' => false, 'message' => 'Không tìm thấy sự kiện'], 404);
        }

        return response()->json([
            'status' => true,
            'data' => $event
        ]);
    }
}
