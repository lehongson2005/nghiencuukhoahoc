import { Outlet, Navigate } from 'react-router-dom';
import { authService } from '../services/api';
import { LogOut, User as UserIcon, BookOpen } from 'lucide-react';

const UserLayout = () => {
    const user = authService.getCurrentUser();

    if (!user) {
        return <Navigate to="/login" replace />;
    }

    return (
        <div className="min-h-screen bg-slate-50 flex flex-col">
            {/* Header chuyên nghiệp cho Sinh viên */}
            <header className="bg-white border-b border-slate-100 sticky top-0 z-50">
                <div className="max-w-7xl mx-auto px-6 h-20 flex items-center justify-between">
                    <div className="flex items-center gap-3">
                        <div className="w-10 h-10 bg-blue-600 rounded-xl flex items-center justify-center shadow-lg shadow-blue-500/20">
                            <BookOpen size={20} className="text-white" />
                        </div>
                        <div>
                            <h1 className="text-lg font-black text-slate-900 tracking-tight leading-none uppercase">NCKH</h1>
                            <p className="text-[10px] font-bold text-slate-400 mt-1 uppercase tracking-widest">Portal Sinh Viên</p>
                        </div>
                    </div>

                    <div className="flex items-center gap-6">
                        <div className="hidden md:flex flex-col items-end">
                            <span className="text-sm font-bold text-slate-900">{user.name}</span>
                            <span className="text-[10px] font-medium text-slate-400 italic">MSSV: {user.mssv}</span>
                        </div>
                        <div className="w-10 h-10 bg-slate-100 rounded-full flex items-center justify-center text-slate-600">
                            <UserIcon size={20} />
                        </div>
                        <div className="h-6 w-px bg-slate-200"></div>
                        <button
                            onClick={() => authService.logout()}
                            className="p-2 text-slate-400 hover:text-red-500 transition-colors"
                            title="Đăng xuất"
                        >
                            <LogOut size={20} />
                        </button>
                    </div>
                </div>
            </header>

            <main className="flex-1">
                <div className="max-w-7xl mx-auto p-6 md:p-10">
                    <Outlet />
                </div>
            </main>

            <footer className="py-8 text-center text-slate-400 text-xs font-medium border-t border-slate-100">
                © {new Date().getFullYear()} Hệ thống Quản lý Nghiên cứu Khoa học
            </footer>
        </div>
    );
};

export default UserLayout;
