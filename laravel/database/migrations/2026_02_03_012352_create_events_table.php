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
        Schema::create('events', function (Blueprint $table) {
            $table->id();
            $table->string('title'); // Tên sự kiện
            $table->text('description')->nullable(); // Mô tả
            $table->decimal('latitude', 10, 8); // Vĩ độ
            $table->decimal('longitude', 11, 8); // Kinh độ
            $table->integer('radius')->default(50); // Bán kính cho phép (mét)
            $table->dateTime('start_time'); // Thời gian bắt đầu
            $table->dateTime('end_time'); // Thời gian kết thúc
            $table->boolean('is_active')->default(true); // Trạng thái sự kiện
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('events');
    }
};
