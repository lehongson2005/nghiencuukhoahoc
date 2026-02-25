<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('attendances', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id'); // Chỉ lưu ID, không ràng buộc cứng database
            $table->unsignedBigInteger('event_id'); 
            
            $table->string('status')->default('success'); // success, failed
            $table->dateTime('checkin_time'); // Thời gian check-in thực tế
            
            // Tọa độ thực tế lúc check-in để đối soát
            $table->decimal('checkin_latitude', 10, 8)->nullable();
            $table->decimal('checkin_longitude', 11, 8)->nullable();
            
            // Đường dẫn ảnh chụp lúc check-in (minh chứng)
            $table->string('evidence_image')->nullable();
            
            // Đảm bảo mỗi user chỉ check-in thành công 1 lần cho 1 sự kiện (optional, tùy logic)
            // $table->unique(['user_id', 'event_id']); 

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('attendances');
    }
};
