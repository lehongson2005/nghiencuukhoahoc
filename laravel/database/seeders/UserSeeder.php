<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Admin
        DB::table('users')->insert([
            'name' => 'Admin User',
            'mssv' => 'ADMIN001',
            'email' => 'admin@example.com',
            'password' => Hash::make('password'),
            'role' => 'admin',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Student 1
        DB::table('users')->insert([
            'name' => 'Nguyen Van A',
            'mssv' => '20110001',
            'email' => 'studentA@example.com',
            'password' => Hash::make('password'), // password mặc định
            'role' => 'student',
            'face_embedding' => null, // Chưa có dữ liệu khuôn mặt
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Student 2
        DB::table('users')->insert([
            'name' => 'Tran Thi B',
            'mssv' => '20110002',
            'email' => 'studentB@example.com',
            'password' => Hash::make('password'),
            'role' => 'student',
            'face_embedding' => null,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}
