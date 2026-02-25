import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { authService } from '../services/api';
import { Lock, User, AlertCircle } from 'lucide-react';

const Login = () => {
    const [mssv, setMssv] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);
    const navigate = useNavigate();

    const handleLogin = async (e) => {
        e.preventDefault();
        setLoading(true);
        setError('');

        try {
            const res = await authService.login(mssv, password);
            if (res.status) {
                if (res.data.role === 'admin') {
                    navigate('/admin');
                } else {
                    navigate('/home');
                }
            } else {
                setError(res.message || 'Đăng nhập thất bại');
            }
        } catch (err) {
            setError('Lỗi kết nối máy chủ. Vui lòng thử lại sau.');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen bg-slate-50 flex items-center justify-center p-6 bg-[radial-gradient(#e5e7eb_1px,transparent_1px)] [background-size:20px_20px]">
            <div className="w-full max-w-md">
                <div className="bg-white rounded-3xl shadow-xl shadow-slate-200/50 overflow-hidden border border-slate-100">
                    <div className="p-10 pt-12 text-center">
                        <div className="w-16 h-16 bg-blue-600 rounded-2xl flex items-center justify-center shadow-xl shadow-blue-500/30 mx-auto mb-6 transform -rotate-6">
                            <span className="font-bold text-3xl text-white">N</span>
                        </div>
                        <h1 className="text-3xl font-extrabold text-slate-900 tracking-tight">Chào mừng trở lại</h1>
                        <p className="text-slate-500 mt-2 font-medium">Hệ thống Quản lý Nghiên cứu Khoa học</p>
                    </div>

                    <form onSubmit={handleLogin} className="p-10 pb-12 pt-0 space-y-5">
                        {error && (
                            <div className="bg-red-50 text-red-600 p-4 rounded-xl flex items-center gap-3 text-sm font-medium border border-red-100 animate-shake">
                                <AlertCircle size={18} />
                                {error}
                            </div>
                        )}

                        <div className="space-y-1.5">
                            <label className="text-sm font-bold text-slate-700 ml-1">Mã số Sinh viên / Admin</label>
                            <div className="relative group">
                                <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none text-slate-400 group-focus-within:text-blue-500 transition-colors">
                                    <User size={18} />
                                </div>
                                <input
                                    type="text"
                                    className="w-full bg-slate-50 border border-slate-200 text-slate-900 rounded-xl py-3.5 pl-11 pr-4 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 outline-none transition-all placeholder:text-slate-400 font-medium"
                                    placeholder="Nhập MSSV"
                                    value={mssv}
                                    onChange={(e) => setMssv(e.target.value)}
                                    required
                                />
                            </div>
                        </div>

                        <div className="space-y-1.5">
                            <label className="text-sm font-bold text-slate-700 ml-1">Mật khẩu</label>
                            <div className="relative group">
                                <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none text-slate-400 group-focus-within:text-blue-500 transition-colors">
                                    <Lock size={18} />
                                </div>
                                <input
                                    type="password"
                                    className="w-full bg-slate-50 border border-slate-200 text-slate-900 rounded-xl py-3.5 pl-11 pr-4 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 outline-none transition-all placeholder:text-slate-400 font-medium"
                                    placeholder="••••••••"
                                    value={password}
                                    onChange={(e) => setPassword(e.target.value)}
                                    required
                                />
                            </div>
                        </div>

                        <button
                            type="submit"
                            disabled={loading}
                            className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-4 px-6 rounded-xl shadow-lg shadow-blue-600/20 transition-all active:scale-[0.98] disabled:opacity-50 disabled:pointer-events-none flex items-center justify-center gap-2 mt-4"
                        >
                            {loading ? (
                                <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                            ) : (
                                'ĐĂNG NHẬP HỆ THỐNG'
                            )}
                        </button>
                    </form>
                </div>

                <p className="mt-8 text-center text-slate-500 text-sm font-medium">
                    Dành riêng cho Quản trị viên & Cán bộ NCKH
                </p>
            </div>
        </div>
    );
};

export default Login;
