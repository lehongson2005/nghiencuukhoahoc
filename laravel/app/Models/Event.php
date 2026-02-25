<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Event extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'description',
        'latitude',
        'longitude',
        'radius',
        'start_time',
        'end_time',
        'is_active',
    ];

    protected $casts = [
        'start_time' => 'datetime',
        'end_time' => 'datetime',
        'is_active' => 'boolean',
    ];

    public function attendances()
    {
        return $this->hasMany(Attendance::class);
    }

    /**
     * Kiểm tra sự kiện có đang diễn ra không
     */
    public function isOpen(): bool
    {
        $now = now();
        return $this->is_active && $now->between($this->start_time, $this->end_time);
    }

    /**
     * Kiểm tra vị trí của người dùng có nằm trong bán kính cho phép không
     * Sử dụng công thức Haversine
     */
    public function isLocationValid($userLat, $userLng): bool
    {
        $earthRadius = 6371000; // Bán kính trái đất (mét)

        $dLat = deg2rad($userLat - $this->latitude);
        $dLon = deg2rad($userLng - $this->longitude);

        $a = sin($dLat / 2) * sin($dLat / 2) +
             cos(deg2rad($this->latitude)) * cos(deg2rad($userLat)) *
             sin($dLon / 2) * sin($dLon / 2);

        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
        $distance = $earthRadius * $c;

        return $distance <= $this->radius;
    }
    public function registrations()
    {
        return $this->hasMany(EventRegistration::class);
    }
}
