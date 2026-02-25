<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class AttendanceSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Giả sử user id 2 là student A, check-in sự kiện 1
        DB::table('attendances')->insert([
            'user_id' => 2,
            'event_id' => 1,
            'status' => 'success',
            'checkin_time' => Carbon::now(),
            'checkin_latitude' => 10.8507278,
            'checkin_longitude' => 106.7719039,
            'evidence_image' => 'path/to/image.jpg',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // User id 3 (Student B) check-in thất bại (ví dụ)
        DB::table('attendances')->insert([
            'user_id' => 3,
            'event_id' => 1,
            'status' => 'failed',
            'checkin_time' => Carbon::now(),
            'checkin_latitude' => 10.9999999, // Sai vị trí
            'checkin_longitude' => 106.9999999,
            'evidence_image' => null,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}
