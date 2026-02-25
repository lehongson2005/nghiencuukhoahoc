<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class EventSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Sự kiện đang diễn ra
        DB::table('events')->insert([
            'title' => 'Hội thảo Công nghệ 2026',
            'description' => 'Giới thiệu các công nghệ mới trong năm 2026',
            'latitude' => 10.8507278, // Ví dụ tọa độ trường SPKT
            'longitude' => 106.7719039,
            'radius' => 100, // 100m
            'start_time' => Carbon::now()->subHour(),
            'end_time' => Carbon::now()->addHours(3),
            'is_active' => true,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Sự kiện đã kết thúc
        DB::table('events')->insert([
            'title' => 'Ngày hội việc làm 2025',
            'description' => 'Sự kiện thường niên',
            'latitude' => 10.8507278,
            'longitude' => 106.7719039,
            'radius' => 50,
            'start_time' => Carbon::now()->subMonths(1),
            'end_time' => Carbon::now()->subMonths(1)->addHours(4),
            'is_active' => false,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
        
        // Sự kiện sắp tới
        DB::table('events')->insert([
            'title' => 'Workshop AI & Big Data',
            'description' => 'Chuyên đề về trí tuệ nhân tạo',
            'latitude' => 10.8507278,
            'longitude' => 106.7719039,
            'radius' => 50,
            'start_time' => Carbon::now()->addDays(2),
            'end_time' => Carbon::now()->addDays(2)->addHours(3),
            'is_active' => true,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}
