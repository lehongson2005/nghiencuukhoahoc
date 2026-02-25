import { useState, useEffect } from 'react';
import { userService, authService } from '../services/api';
import { Calendar, MapPin, Clock, Info, CheckCircle2, Search, Filter, ArrowRight, UserCheck } from 'lucide-react';

const UserHome = () => {
    const [allEvents, setAllEvents] = useState([]);
    const [myEvents, setMyEvents] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');
    const [selectedEvent, setSelectedEvent] = useState(null);
    const [registering, setRegistering] = useState(false);

    const user = authService.getCurrentUser();

    useEffect(() => {
        fetchData();
    }, []);

    const fetchData = async () => {
        setLoading(true);
        try {
            const [allRes, myRes] = await Promise.all([
                userService.getEvents(),
                userService.getMyEvents(user.id)
            ]);

            if (allRes.data.status) setAllEvents(allRes.data.data);
            if (myRes.data.status) setMyEvents(myRes.data.data);
        } catch (err) {
            console.error("Lỗi khi tải dữ liệu:", err);
        } finally {
            setLoading(false);
        }
    };

    const handleRegister = async (eventId) => {
        setRegistering(true);
        try {
            const res = await userService.registerForEvent(user.id, eventId);
            if (res.status) {
                alert("Đăng ký tham gia thành công!");
                fetchData();
                setSelectedEvent(null);
            } else {
                alert(res.message || "Đăng ký thất bại.");
            }
        } catch (err) {
            alert("Đã xảy ra lỗi khi đăng ký.");
        } finally {
            setRegistering(false);
        }
    };

    const isRegistered = (eventId) => {
        return myEvents.some(ev => ev.id === eventId);
    };

    const filteredEvents = allEvents.filter(ev =>
        ev.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
        (ev.description && ev.description.toLowerCase().includes(searchTerm.toLowerCase()))
    );

    return (
        <div className="space-y-12 animate-fade-in">
            {/* Chào mừng */}
            <section className="relative overflow-hidden bg-slate-900 rounded-[2.5rem] p-8 md:p-12 text-white shadow-2xl shadow-slate-900/20">
                <div className="relative z-10 max-w-2xl">
                    <h2 className="text-3xl md:text-5xl font-black tracking-tight mb-4">
                        Chào bạn, {user.name.split(' ').pop()}! 👋
                    </h2>
                    <p className="text-slate-400 text-lg font-medium leading-relaxed">
                        Khám phá và đăng ký tham gia các sự kiện Nghiên cứu Khoa học mới nhất để tích lũy kiến thức và điểm rèn luyện.
                    </p>
                </div>
                <div className="absolute right-0 top-0 w-1/3 h-full opacity-10 pointer-events-none">
                    <BookOpen size={300} className="transform rotate-12 -translate-y-20 translate-x-20" />
                </div>
            </section>

            {/* Thống kê nhanh */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div className="bg-white p-6 rounded-[2rem] border border-slate-100 flex items-center gap-5 shadow-sm">
                    <div className="w-14 h-14 bg-blue-50 text-blue-600 rounded-2xl flex items-center justify-center">
                        <Calendar size={28} />
                    </div>
                    <div>
                        <div className="text-2xl font-black text-slate-900">{allEvents.length}</div>
                        <div className="text-xs font-bold text-slate-400 uppercase tracking-wider">Sự kiện có sẵn</div>
                    </div>
                </div>
                <div className="bg-white p-6 rounded-[2rem] border border-slate-100 flex items-center gap-5 shadow-sm">
                    <div className="w-14 h-14 bg-green-50 text-green-600 rounded-2xl flex items-center justify-center">
                        <UserCheck size={28} />
                    </div>
                    <div>
                        <div className="text-2xl font-black text-slate-900">{myEvents.length}</div>
                        <div className="text-xs font-bold text-slate-400 uppercase tracking-wider">Đã đăng ký</div>
                    </div>
                </div>
                <div className="bg-white p-6 rounded-[2rem] border border-slate-100 flex items-center gap-5 shadow-sm">
                    <div className="w-14 h-14 bg-purple-50 text-purple-600 rounded-2xl flex items-center justify-center">
                        <CheckCircle2 size={28} />
                    </div>
                    <div>
                        <div className="text-2xl font-black text-slate-900">0</div>
                        <div className="text-xs font-bold text-slate-400 uppercase tracking-wider">Đã hoàn thành</div>
                    </div>
                </div>
            </div>

            {/* Danh sách Sự kiện khám phá */}
            <section className="space-y-6">
                <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                    <h3 className="text-2xl font-black text-slate-900 flex items-center gap-3">
                        Khám phá Sự kiện
                        <span className="bg-blue-600 text-white text-[10px] py-1 px-2 rounded-lg uppercase tracking-tighter">Mới nhất</span>
                    </h3>
                    <div className="relative group">
                        <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-blue-500 transition-colors" size={18} />
                        <input
                            className="bg-white border border-slate-200 rounded-2xl py-3 pl-12 pr-6 text-sm w-full md:w-80 outline-none focus:ring-2 focus:ring-blue-500/10 focus:border-blue-500 transition-all shadow-sm"
                            placeholder="Tìm kiếm theo tên hoặc mô tả..."
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                        />
                    </div>
                </div>

                {loading ? (
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                        {[1, 2, 3].map(i => (
                            <div key={i} className="bg-white h-72 rounded-[2rem] border border-slate-100 animate-pulse"></div>
                        ))}
                    </div>
                ) : filteredEvents.length === 0 ? (
                    <div className="bg-white rounded-[2rem] p-20 text-center border border-slate-100">
                        <div className="text-slate-300 mb-4 flex justify-center"><Calendar size={64} /></div>
                        <p className="text-slate-500 font-bold italic">Không tìm thấy sự kiện nào phù hợp.</p>
                    </div>
                ) : (
                    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                        {filteredEvents.map(ev => (
                            <div
                                key={ev.id}
                                className="group bg-white rounded-[2rem] border border-slate-100 overflow-hidden shadow-sm hover:shadow-xl transition-all duration-300 hover:-translate-y-2 relative"
                            >
                                <div className="p-8">
                                    <div className="flex justify-between items-start mb-6">
                                        <div className="p-3 bg-blue-50 text-blue-600 rounded-2xl">
                                            <Calendar size={24} />
                                        </div>
                                        {isRegistered(ev.id) && (
                                            <span className="bg-green-100 text-green-600 text-[10px] font-black uppercase px-2 py-1 rounded-lg flex items-center gap-1">
                                                <CheckCircle2 size={12} /> Đã Đăng Ký
                                            </span>
                                        )}
                                    </div>
                                    <h4 className="text-xl font-black text-slate-900 mb-3 group-hover:text-blue-600 transition-colors line-clamp-2 min-h-[3.5rem] leading-tight">
                                        {ev.title}
                                    </h4>
                                    <div className="space-y-3 mb-8">
                                        <div className="flex items-center gap-2 text-xs font-bold text-slate-500">
                                            <Clock size={14} className="text-slate-300" />
                                            {new Date(ev.start_time).toLocaleDateString('vi-VN')} | {new Date(ev.start_time).toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' })}
                                        </div>
                                        <div className="flex items-center gap-2 text-xs font-bold text-slate-500">
                                            <MapPin size={14} className="text-slate-300" />
                                            Khu vực: {ev.radius}m
                                        </div>
                                    </div>
                                    <button
                                        onClick={() => setSelectedEvent(ev)}
                                        className="w-full bg-slate-50 hover:bg-blue-600 hover:text-white text-slate-900 font-bold py-4 px-6 rounded-2xl flex items-center justify-center gap-2 transition-all group-hover:shadow-lg group-hover:shadow-blue-600/20"
                                    >
                                        Xem Chi Tiết
                                        <ArrowRight size={18} />
                                    </button>
                                </div>
                            </div>
                        ))}
                    </div>
                )}
            </section>

            {/* Modal Chi tiết Sự kiện */}
            {selectedEvent && (
                <div className="fixed inset-0 z-[100] flex items-center justify-center p-6 animate-fade-in">
                    <div className="absolute inset-0 bg-slate-900/60 backdrop-blur-sm" onClick={() => setSelectedEvent(null)}></div>
                    <div className="bg-white w-full max-w-2xl rounded-[3rem] shadow-2xl relative z-10 overflow-hidden animate-zoom-in">
                        <div className="p-8 md:p-12">
                            <div className="flex justify-between items-start mb-8">
                                <div className="p-4 bg-blue-600 text-white rounded-2xl shadow-lg shadow-blue-500/30">
                                    <Info size={32} />
                                </div>
                                <button onClick={() => setSelectedEvent(null)} className="text-slate-400 hover:text-slate-900 transition-colors p-2 cursor-pointer">
                                    <X size={24} />
                                </button>
                            </div>

                            <h3 className="text-3xl font-black text-slate-900 mb-6 leading-tight">
                                {selectedEvent.title}
                            </h3>

                            <div className="grid grid-cols-2 gap-6 mb-8">
                                <div className="bg-slate-50 p-4 rounded-2xl">
                                    <div className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Thời gian</div>
                                    <div className="text-sm font-bold text-slate-700">
                                        {new Date(selectedEvent.start_time).toLocaleDateString('vi-VN')}
                                    </div>
                                    <div className="text-xs font-medium text-slate-500 mt-1">
                                        {new Date(selectedEvent.start_time).toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' })} ➝ {new Date(selectedEvent.end_time).toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' })}
                                    </div>
                                </div>
                                <div className="bg-slate-50 p-4 rounded-2xl">
                                    <div className="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Địa điểm</div>
                                    <div className="text-sm font-bold text-slate-700">Tọa độ sự kiện</div>
                                    <div className="text-xs font-medium text-slate-500 mt-1">
                                        {selectedEvent.latitude}, {selectedEvent.longitude}
                                    </div>
                                </div>
                            </div>

                            <div className="space-y-4 mb-10">
                                <h5 className="text-xs font-black text-slate-900 uppercase tracking-widest">Mô tả sự kiện</h5>
                                <p className="text-slate-600 leading-relaxed font-medium">
                                    {selectedEvent.description || 'Chưa có thông tin mô tả chi tiết cho sự kiện này.'}
                                </p>
                            </div>

                            <div className="flex gap-4">
                                <button
                                    onClick={() => setSelectedEvent(null)}
                                    className="flex-1 bg-slate-100 hover:bg-slate-200 text-slate-600 font-bold py-4 rounded-2xl transition-colors"
                                >
                                    Đóng
                                </button>
                                {isRegistered(selectedEvent.id) ? (
                                    <div className="flex-1 bg-green-50 text-green-600 font-bold py-4 rounded-2xl flex items-center justify-center gap-2 border border-green-100">
                                        <CheckCircle2 size={20} /> Đã Đăng Ký
                                    </div>
                                ) : (
                                    <button
                                        disabled={registering}
                                        onClick={() => handleRegister(selectedEvent.id)}
                                        className="flex-1 bg-blue-600 hover:bg-blue-700 text-white font-bold py-4 rounded-2xl shadow-lg shadow-blue-500/20 flex items-center justify-center gap-2 transition-all active:scale-95 disabled:opacity-50"
                                    >
                                        {registering ? (
                                            <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                                        ) : (
                                            <>Đăng ký ngay <ArrowRight size={20} /></>
                                        )}
                                    </button>
                                )}
                            </div>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

// Mock icon component if BookOpen is missing from imports
const BookOpen = ({ size, className }) => <svg className={className} width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z" /><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z" /></svg>;
const X = ({ size, className }) => <svg className={className} width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" /></svg>;

export default UserHome;
