import { useState, useEffect } from 'react';
import { adminService } from '../services/api';
import { Calendar, Plus, Search, MapPin, Clock, CheckCircle2, XCircle, Users } from 'lucide-react';

const Events = () => {
    const [events, setEvents] = useState([]);
    const [loading, setLoading] = useState(false);
    const [showAddForm, setShowAddForm] = useState(false);
    const [newEvent, setNewEvent] = useState({
        title: '', description: '',
        latitude: '10.8507278', longitude: '106.7719039',
        radius: '50',
        start_time: '', end_time: ''
    });

    useEffect(() => {
        fetchEvents();
    }, []);

    const fetchEvents = async () => {
        setLoading(true);
        try {
            const res = await adminService.getEvents();
            if (res.data.status) setEvents(res.data.data);
        } catch (err) {
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const handleCreate = async (e) => {
        e.preventDefault();
        try {
            const res = await adminService.createEvent(newEvent);
            if (res.data.status) {
                alert("Tạo sự kiện thành công!");
                fetchEvents();
                setShowAddForm(false);
                setNewEvent({ ...newEvent, title: '', description: '' });
            }
        } catch (err) {
            alert("Lỗi khi tạo sự kiện");
        }
    };

    return (
        <div className="space-y-8 animate-fade-in">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h2 className="text-4xl font-extrabold text-slate-900 tracking-tight">Quản lý Sự kiện</h2>
                    <p className="text-slate-500 mt-1 font-medium italic">Tạo và điều hành các chương trình điểm danh.</p>
                </div>
                <button
                    onClick={() => setShowAddForm(!showAddForm)}
                    className="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white font-bold py-3.5 px-6 rounded-2xl shadow-lg shadow-blue-600/20 transition-all active:scale-95"
                >
                    {showAddForm ? <Plus className="rotate-45" /> : <Plus />}
                    {showAddForm ? 'Hủy bỏ' : 'Tạo sự kiện mới'}
                </button>
            </div>

            {showAddForm && (
                <div className="bg-white p-8 rounded-3xl shadow-xl shadow-slate-200/50 border border-blue-100 animate-slide-down">
                    <h3 className="text-xl font-black mb-6 text-slate-800 flex items-center gap-2">
                        <Calendar className="text-blue-600" />
                        Chi tiết Sự kiện mới
                    </h3>
                    <form onSubmit={handleCreate} className="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div className="space-y-1.5 md:col-span-2">
                            <label className="text-sm font-bold text-slate-700">Tên sự kiện</label>
                            <input
                                className="w-full bg-slate-50 border border-slate-200 rounded-xl py-3 px-4 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 outline-none"
                                placeholder="Nhập tên sự kiện..."
                                value={newEvent.title}
                                onChange={e => setNewEvent({ ...newEvent, title: e.target.value })}
                                required
                            />
                        </div>

                        <div className="space-y-1.5 md:col-span-2">
                            <label className="text-sm font-bold text-slate-700">Mô tả ngắn</label>
                            <input
                                className="w-full bg-slate-50 border border-slate-200 rounded-xl py-3 px-4 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 outline-none"
                                placeholder="Nội dung sự kiện..."
                                value={newEvent.description}
                                onChange={e => setNewEvent({ ...newEvent, description: e.target.value })}
                            />
                        </div>

                        <div className="space-y-1.5">
                            <label className="text-sm font-bold text-slate-700 flex items-center gap-2"><Clock size={16} /> Thời gian bắt đầu</label>
                            <input
                                type="datetime-local"
                                className="w-full bg-slate-50 border border-slate-200 rounded-xl py-3 px-4 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 outline-none"
                                value={newEvent.start_time}
                                onChange={e => setNewEvent({ ...newEvent, start_time: e.target.value })}
                                required
                            />
                        </div>

                        <div className="space-y-1.5">
                            <label className="text-sm font-bold text-slate-700 flex items-center gap-2"><Clock size={16} /> Thời gian kết thúc</label>
                            <input
                                type="datetime-local"
                                className="w-full bg-slate-50 border border-slate-200 rounded-xl py-3 px-4 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 outline-none"
                                value={newEvent.end_time}
                                onChange={e => setNewEvent({ ...newEvent, end_time: e.target.value })}
                                required
                            />
                        </div>

                        <div className="grid grid-cols-3 gap-4 md:col-span-2">
                            <div className="space-y-1.5">
                                <label className="text-sm font-bold text-slate-700 flex items-center gap-2"><MapPin size={16} /> Vĩ độ (Lat)</label>
                                <input className="w-full bg-slate-50 border border-slate-200 rounded-xl py-3 px-4" value={newEvent.latitude} onChange={e => setNewEvent({ ...newEvent, latitude: e.target.value })} />
                            </div>
                            <div className="space-y-1.5">
                                <label className="text-sm font-bold text-slate-700 flex items-center gap-2"><MapPin size={16} /> Kinh độ (Long)</label>
                                <input className="w-full bg-slate-50 border border-slate-200 rounded-xl py-3 px-4" value={newEvent.longitude} onChange={e => setNewEvent({ ...newEvent, longitude: e.target.value })} />
                            </div>
                            <div className="space-y-1.5">
                                <label className="text-sm font-bold text-slate-700">Bán kính (m)</label>
                                <input className="w-full bg-slate-50 border border-slate-200 rounded-xl py-3 px-4" value={newEvent.radius} onChange={e => setNewEvent({ ...newEvent, radius: e.target.value })} />
                            </div>
                        </div>

                        <button type="submit" className="bg-slate-900 text-white font-bold py-4 rounded-2xl md:col-span-2 hover:bg-black transition-colors shadow-lg">
                            Xác nhận Lưu Sự kiện
                        </button>
                    </form>
                </div>
            )}

            {/* Danh sách Sự kiện */}
            <div className="bg-white rounded-[2rem] shadow-sm border border-slate-100 overflow-hidden">
                <div className="p-8 border-b border-slate-50 flex items-center justify-between">
                    <h3 className="font-bold text-slate-800 text-lg">Danh sách đang diễn ra</h3>
                    <div className="relative">
                        <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={18} />
                        <input className="bg-slate-50 border-none rounded-xl py-2 pl-10 pr-4 text-sm w-64 focus:ring-2 focus:ring-blue-500/10" placeholder="Tìm kiếm sự kiện..." />
                    </div>
                </div>

                {loading ? (
                    <div className="p-20 text-center"><div className="w-8 h-8 border-4 border-blue-600/30 border-t-blue-600 rounded-full animate-spin mx-auto"></div></div>
                ) : (
                    <div className="overflow-x-auto">
                        <table className="w-full text-left">
                            <thead>
                                <tr className="text-slate-400 text-xs font-black uppercase tracking-widest bg-slate-50/50">
                                    <th className="px-8 py-5">Sự kiện</th>
                                    <th className="px-8 py-5">Thời gian</th>
                                    <th className="px-8 py-5">Địa điểm</th>
                                    <th className="px-8 py-5 text-center">Trạng thái</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-50">
                                {events.map(ev => (
                                    <EventRow key={ev.id} ev={ev} />
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}
            </div>
        </div>
    );
};

const EventRow = ({ ev }) => {
    const [showStudents, setShowStudents] = useState(false);
    const [students, setStudents] = useState([]);
    const [loading, setLoading] = useState(false);

    const fetchRegistrations = async () => {
        if (!showStudents) {
            setLoading(true);
            try {
                const res = await adminService.getRegisteredStudents(ev.id);
                if (res.data.status) setStudents(res.data.data);
            } catch (err) {
                console.error(err);
            } finally {
                setLoading(false);
            }
        }
        setShowStudents(!showStudents);
    };

    return (
        <>
            <tr
                onClick={fetchRegistrations}
                className="hover:bg-slate-50/50 transition-colors group cursor-pointer"
            >
                <td className="px-8 py-6">
                    <div className="font-bold text-slate-900 group-hover:text-blue-600 transition-colors">{ev.title}</div>
                    <div className="text-xs text-slate-400 mt-1 line-clamp-1">{ev.description || 'Không có mô tả'}</div>
                </td>
                <td className="px-8 py-6">
                    <div className="flex items-center gap-2 text-sm font-medium text-slate-600">
                        <Clock size={14} className="text-slate-300" />
                        {new Date(ev.start_time).toLocaleDateString('vi-VN')}
                    </div>
                    <div className="text-[10px] font-bold text-slate-400 mt-1">
                        {new Date(ev.start_time).toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' })} ➝
                        {new Date(ev.end_time).toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' })}
                    </div>
                </td>
                <td className="px-8 py-6">
                    <div className="flex items-center gap-2 text-xs font-bold text-slate-500 bg-slate-100 w-fit px-3 py-1.5 rounded-lg">
                        <MapPin size={12} />
                        GPS: {ev.latitude}, {ev.longitude}
                    </div>
                </td>
                <td className="px-8 py-6 text-center">
                    {ev.is_active ? (
                        <span className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-green-50 text-green-600 text-[10px] font-black uppercase tracking-wider border border-green-100">
                            <CheckCircle2 size={12} /> Đang chạy
                        </span>
                    ) : (
                        <span className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-slate-100 text-slate-400 text-[10px] font-black uppercase tracking-wider">
                            <XCircle size={12} /> Kết thúc
                        </span>
                    )}
                </td>
            </tr>
            {showStudents && (
                <tr>
                    <td colSpan="4" className="px-8 py-4 bg-slate-50/30">
                        <div className="bg-white rounded-2xl border border-slate-100 p-6 shadow-inner animate-slide-down">
                            <h4 className="text-sm font-black text-slate-800 mb-4 flex items-center gap-2 uppercase tracking-wider">
                                <Users size={16} className="text-blue-600" /> Sinh viên đã đăng ký
                            </h4>
                            {loading ? (
                                <div className="py-4 text-center text-xs text-slate-400">Đang tải...</div>
                            ) : students.length === 0 ? (
                                <div className="py-4 text-center text-xs text-slate-400 italic">Chưa có sinh viên nào đăng ký.</div>
                            ) : (
                                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
                                    {students.map(reg => (
                                        <div key={reg.id} className="flex items-center gap-3 p-3 bg-slate-50 rounded-xl border border-slate-100">
                                            <div className="w-8 h-8 bg-blue-100 text-blue-600 rounded-lg flex items-center justify-center font-bold text-xs uppercase">
                                                {reg.user.name.charAt(0)}
                                            </div>
                                            <div>
                                                <div className="text-xs font-bold text-slate-900">{reg.user.name}</div>
                                                <div className="text-[10px] text-slate-400">{reg.user.mssv}</div>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>
                    </td>
                </tr>
            )}
        </>
    );
};

export default Events;
