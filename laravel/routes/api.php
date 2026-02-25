<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\EventController;
use App\Http\Controllers\Api\AttendanceController;
use App\Http\Controllers\Api\AdminController;

use App\Http\Controllers\Api\RegistrationController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Auth
Route::post('/login', [AuthController::class, 'login']);
Route::post('/face/register', [AuthController::class, 'registerFace']); // Đăng ký khuôn mặt

// Events (Public or Protected)
Route::get('/events', [EventController::class, 'index']);
Route::get('/events/{id}', [EventController::class, 'show']);

// Event Registrations
Route::post('/events/register', [RegistrationController::class, 'register']);
Route::get('/user/{userId}/events', [RegistrationController::class, 'myEvents']);
Route::get('/admin/events/{eventId}/registrations', [RegistrationController::class, 'eventStudents']);

// Attendance
Route::post('/checkin', [AttendanceController::class, 'store']);
Route::get('/attendance/history/{userId}', [AttendanceController::class, 'history']);

// Admin Routes
Route::get('/admin/stats', [AdminController::class, 'stats']);
Route::get('/admin/events', [AdminController::class, 'getEvents']);
Route::post('/admin/events', [AdminController::class, 'createEvent']);
Route::get('/admin/users', [AdminController::class, 'getUsers']);
Route::post('/admin/users/{id}/reset-face', [AdminController::class, 'resetFace']);

// Route test user info (nếu gửi kèm token sau này)
Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});
