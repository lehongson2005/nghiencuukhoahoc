import axios from 'axios';

const API_URL = "http://192.168.1.174:8080/api"; // Thay đổi IP nếu cần

const api = axios.create({
    baseURL: API_URL,
    headers: {
        'Content-Type': 'application/json',
    },
});

// Interceptor để thêm token vào header nếu có
api.interceptors.request.use((config) => {
    const token = localStorage.getItem('token');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});

export const authService = {
    login: async (mssv, password) => {
        const response = await api.post('/login', { mssv, password });
        if (response.data.status) {
            localStorage.setItem('user', JSON.stringify(response.data.data));
            // Nếu backend có token thì lưu ở đây
            // localStorage.setItem('token', response.data.token);
        }
        return response.data;
    },
    logout: () => {
        localStorage.removeItem('user');
        localStorage.removeItem('token');
        window.location.href = '/login';
    },
    getCurrentUser: () => {
        const user = localStorage.getItem('user');
        return user ? JSON.parse(user) : null;
    }
};

export const adminService = {
    getStats: () => api.get('/admin/stats'),
    getEvents: () => api.get('/admin/events'),
    createEvent: (eventData) => api.post('/admin/events', eventData),
    getUsers: () => api.get('/admin/users'),
    resetFace: (userId) => api.post(`/admin/users/${userId}/reset-face`),

    // Các hàm mới cho việc đăng ký
    getRegisteredStudents: (eventId) => api.get(`/admin/events/${eventId}/registrations`),
};

export const userService = {
    getEvents: () => api.get('/events'),
    registerForEvent: (userId, eventId) => api.post('/events/register', { user_id: userId, event_id: eventId }),
    getMyEvents: (userId) => api.get(`/user/${userId}/events`),
};

export default api;
