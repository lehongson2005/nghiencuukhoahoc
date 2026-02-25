import { useState, useEffect } from 'react';
import { adminService } from '../services/api';
import { Users, Calendar, CheckSquare, ArrowUpRight, Lightbulb } from 'lucide-react';

const Dashboard = () => {
    const [stats, setStats] = useState({ total_users: 0, active_events: 0, total_attendances: 0 });

    useEffect(() => {
        fetchStats();
    }, []);

    const fetchStats = async () => {
        try {
            const res = await adminService.getStats();
            if (res.data.status) setStats(res.data.data);
        } catch (err) {
            console.error(err);
        }
    };

    const statCards = [
        { label: 'Tổng sinh viên', value: stats.total_users, color: 'blue', icon: <Users size={24} /> },
        { label: 'Sự kiện đang chạy', value: stats.active_events, color: 'green', icon: <Calendar size={24} /> },
        { label: 'Lượt điểm danh', value: stats.total_attendances, color: 'indigo', icon: <CheckSquare size={24} /> },
    ];

    return (
        <div className="space-y-10 animate-fade-in">
            <div>
                <h2 className="text-4xl font-extrabold text-slate-900 tracking-tight">Tổng quan Hệ thống</h2>
                <p className="text-slate-500 mt-2 font-medium">Chào mừng bạn trở lại, đây là trạng thái hiện tại của dự án.</p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                {statCards.map((card) => (
                    <div key={card.label} className="bg-white p-8 rounded-3xl shadow-sm border border-slate-100 hover:shadow-xl hover:shadow-slate-200/50 transition-all group overflow-hidden relative">
                        <div className={`absolute top-0 right-0 p-6 opacity-5 group-hover:scale-110 transition-transform ${card.color === 'blue' ? 'text-blue-600' : card.color === 'green' ? 'text-green-600' : 'text-indigo-600'
                            }`}>
                            {card.icon}
                        </div>
                        <div className={`w-14 h-14 rounded-2xl flex items-center justify-center mb-6 ${card.color === 'blue' ? 'bg-blue-50 text-blue-600' :
                                card.color === 'green' ? 'bg-green-50 text-green-600' :
                                    'bg-indigo-50 text-indigo-600'
                            }`}>
                            {card.icon}
                        </div>
                        <h3 className="text-slate-500 font-bold text-sm tracking-wide uppercase">{card.label}</h3>
                        <div className="flex items-center justify-between mt-2">
                            <p className="text-4xl font-black text-slate-900">{card.value}</p>
                            <div className="flex items-center text-xs font-bold text-green-600 bg-green-50 px-2 py-1 rounded-lg">
                                <ArrowUpRight size={14} /> 12%
                            </div>
                        </div>
                    </div>
                ))}
            </div>

            <div className="bg-gradient-to-r from-blue-600 to-indigo-700 p-10 rounded-3xl shadow-2xl shadow-blue-500/20 text-white relative overflow-hidden">
                <div className="absolute top-0 right-0 p-10 opacity-10 rotate-12">
                    <Lightbulb size={120} />
                </div>
                <div className="relative z-10 max-w-2xl">
                    <h3 className="text-2xl font-bold mb-4 flex items-center gap-3">
                        <Lightbulb className="text-yellow-400" />
                        Mẹo quản trị nhanh
                    </h3>
                    <ul className="space-y-4 text-blue-50 font-medium">
                        <li className="flex items-start gap-3">
                            <div className="w-6 h-6 bg-white/20 rounded-lg flex items-center justify-center text-xs font-bold shrink-0 mt-0.5">1</div>
                            Tạo sự kiện mới tại mục <span className="underline underline-offset-4 decoration-white/30 italic">Quản lý Sự kiện</span> để bắt đầu điểm danh.
                        </li>
                        <li className="flex items-start gap-3">
                            <div className="w-6 h-6 bg-white/20 rounded-lg flex items-center justify-center text-xs font-bold shrink-0 mt-0.5">2</div>
                            Nếu sinh viên quên mẫu nhận diện, bạn hãy vào mục <span className="underline underline-offset-4 decoration-white/30 italic">Quản lý Sinh viên</span> để reset khuôn mặt.
                        </li>
                        <li className="flex items-start gap-3">
                            <div className="w-6 h-6 bg-white/20 rounded-lg flex items-center justify-center text-xs font-bold shrink-0 mt-0.5">3</div>
                            Sử dụng app Mobile để kiểm tra trực tiếp việc quét mã QR & định vị GPS.
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    );
};

export default Dashboard;
