import { useState, useEffect } from 'react';
import { adminService } from '../services/api';
import { GraduationCap, ShieldCheck, ShieldAlert, History, RotateCcw } from 'lucide-react';

const Students = () => {
    const [students, setStudents] = useState([]);
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        fetchStudents();
    }, []);

    const fetchStudents = async () => {
        setLoading(true);
        try {
            const res = await adminService.getUsers();
            if (res.data.status) setStudents(res.data.data);
        } catch (err) {
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const handleResetFace = async (id) => {
        if (!window.confirm("Cảnh báo: Bạn có chắc chắn muốn xóa dữ liệu khuôn mặt của sinh viên này? Sinh viên sẽ không thể điểm danh cho đến khi đăng ký lại trên app.")) return;

        try {
            const res = await adminService.resetFace(id);
            if (res.data.status) {
                alert("Đã reset khuôn mặt thành công!");
                fetchStudents();
            }
        } catch (err) {
            alert("Lỗi khi reset khuôn mặt");
        }
    };

    const API_ROOT = "http://192.168.1.168:8080"; // Base URL cho ảnh

    return (
        <div className="space-y-8 animate-fade-in">
            <div>
                <h2 className="text-4xl font-extrabold text-slate-900 tracking-tight">Cơ sở dữ liệu Sinh viên</h2>
                <p className="text-slate-500 mt-1 font-medium italic">Quản lý hồ sơ và dữ liệu nhận diện khuôn mặt sinh viên.</p>
            </div>

            <div className="bg-white rounded-[2rem] shadow-sm border border-slate-100 overflow-hidden">
                {loading ? (
                    <div className="p-20 text-center"><div className="w-8 h-8 border-4 border-blue-600/30 border-t-blue-600 rounded-full animate-spin mx-auto"></div></div>
                ) : (
                    <div className="overflow-x-auto">
                        <table className="w-full text-left">
                            <thead>
                                <tr className="text-slate-400 text-xs font-black uppercase tracking-widest bg-slate-50/50">
                                    <th className="px-8 py-5">Sinh viên</th>
                                    <th className="px-8 py-5">MSSV / Email</th>
                                    <th className="px-8 py-5">Dữ liệu khuôn mặt</th>
                                    <th className="px-8 py-5 text-right whitespace-nowrap">Hành động</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-50">
                                {students.map(std => (
                                    <tr key={std.id} className="hover:bg-slate-50/50 transition-colors">
                                        <td className="px-8 py-6">
                                            <div className="flex items-center gap-4">
                                                <div className="w-12 h-12 bg-slate-100 rounded-2xl flex items-center justify-center text-slate-400">
                                                    <GraduationCap size={24} />
                                                </div>
                                                <div>
                                                    <div className="font-bold text-slate-900">{std.name}</div>
                                                    <div className="text-[10px] font-bold text-blue-600 bg-blue-50 px-2 py-0.5 rounded-full w-fit mt-1">Hệ Đại học</div>
                                                </div>
                                            </div>
                                        </td>
                                        <td className="px-8 py-6">
                                            <div className="font-black text-slate-700 text-sm tracking-tight">{std.mssv}</div>
                                            <div className="text-xs text-slate-400 mt-1">{std.email}</div>
                                        </td>
                                        <td className="px-8 py-6">
                                            {std.face_image_path ? (
                                                <div className="flex items-center gap-3">
                                                    <img
                                                        src={`${API_ROOT}/${std.face_image_path}`}
                                                        alt="Face"
                                                        className="w-10 h-10 rounded-xl object-cover ring-2 ring-blue-50"
                                                    />
                                                    <div className="flex items-center gap-1.5 text-green-600 font-bold text-[10px] uppercase tracking-wider">
                                                        <ShieldCheck size={14} /> Có mẫu
                                                    </div>
                                                </div>
                                            ) : (
                                                <div className="flex items-center gap-1.5 text-slate-300 font-bold text-[10px] uppercase tracking-wider">
                                                    <ShieldAlert size={14} /> Chưa đăng ký
                                                </div>
                                            )}
                                        </td>
                                        <td className="px-8 py-6 text-right">
                                            <div className="flex items-center justify-end gap-2">
                                                <button className="p-2.5 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-xl transition-all" title="Lịch sử">
                                                    <History size={18} />
                                                </button>
                                                {std.face_image_path && (
                                                    <button
                                                        onClick={() => handleResetFace(std.id)}
                                                        className="flex items-center gap-2 bg-red-50 text-red-600 hover:bg-red-600 hover:text-white px-4 py-2.5 rounded-xl text-xs font-black transition-all"
                                                    >
                                                        <RotateCcw size={14} /> RESET
                                                    </button>
                                                )}
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}
            </div>
        </div>
    );
};

export default Students;
