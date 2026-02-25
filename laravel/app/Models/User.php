<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'mssv',
        'face_embedding',
        'face_image_path',
        'role',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    public function attendances()
    {
        return $this->hasMany(Attendance::class);
    }

    public function eventRegistrations()
    {
        return $this->hasMany(EventRegistration::class);
    }

    public function registeredEvents()
    {
        return $this->belongsToMany(Event::class, 'event_registrations');
    }

    /**
     * Kiểm tra xem user đã đăng ký sự kiện chưa
     */
    public function isRegisteredFor($eventId): bool
    {
        return $this->eventRegistrations()->where('event_id', $eventId)->exists();
    }

    /**
     * Kiểm tra xem user đã check-in sự kiện này chưa
     */
    public function hasCheckedIn($eventId): bool
    {
        return $this->attendances()
                    ->where('event_id', $eventId)
                    ->where('status', 'success')
                    ->exists();
    }
}
