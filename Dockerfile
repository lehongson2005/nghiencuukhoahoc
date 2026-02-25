# Sử dụng hình ảnh PHP chính thức với FPM
FROM php:8.2-fpm

# Cài đặt các phần phụ thuộc hệ thống
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Xóa bộ đệm
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Cài đặt các tiện ích mở rộng PHP cần thiết cho Laravel và MySQL
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Lấy Composer phiên bản mới nhất
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Thiết lập thư mục làm việc
WORKDIR /var/www

# Cấp quyền cho thư mục storage và bootstrap/cache
RUN chown -R www-data:www-data /var/www