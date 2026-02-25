import { LayoutDashboard, Calendar, Users, LogOut, ChevronRight } from 'lucide-react';
import { NavLink } from 'react-router-dom';
import { authService } from '../services/api';

const Sidebar = () => {
    const menuItems = [
        { icon: <LayoutDashboard size={20} />, label: 'Dashboard', path: '/admin' },
        { icon: <Calendar size={20} />, label: 'Quản lý Sự kiện', path: '/admin/events' },
        { icon: <Users size={20} />, label: 'Quản lý Sinh viên', path: '/admin/students' },
    ];

    return (
        <div className="w-72 bg-slate-900 text-white flex flex-col h-screen sticky top-0 shadow-2xl">
            <div className="p-8">
                <div className="flex items-center gap-3 mb-10 px-2">
                    <div className="w-10 h-10 bg-blue-600 rounded-xl flex items-center justify-center shadow-lg shadow-blue-500/30">
                        <span className="font-bold text-xl">N</span>
                    </div>
                    <div>
                        <h1 className="text-xl font-bold tracking-tight">NCKH</h1>
                        <p className="text-[10px] text-slate-400 font-medium uppercase tracking-widest">Admin Dashboard</p>
                    </div>
                </div>

                <nav className="space-y-2">
                    {menuItems.map((item) => (
                        <NavLink
                            key={item.path}
                            to={item.path}
                            className={({ isActive }) =>
                                `flex items-center justify-between p-3.5 rounded-xl transition-all duration-200 group ${isActive
                                    ? 'bg-blue-600 text-white shadow-lg shadow-blue-600/20'
                                    : 'text-slate-400 hover:bg-slate-800 hover:text-white'
                                }`
                            }
                        >
                            <div className="flex items-center gap-3">
                                <span className="transition-transform duration-200 group-hover:scale-110">
                                    {item.icon}
                                </span>
                                <span className="font-medium">{item.label}</span>
                            </div>
                            <ChevronRight size={14} className="opacity-0 group-hover:opacity-100 transition-opacity" />
                        </NavLink>
                    ))}
                </nav>
            </div>

            <div className="mt-auto p-6 border-t border-slate-800/50">
                <button
                    onClick={() => authService.logout()}
                    className="flex items-center gap-3 w-full p-3.5 text-slate-400 hover:text-red-400 hover:bg-red-400/10 rounded-xl transition-all duration-200 group"
                >
                    <LogOut size={20} className="transition-transform group-hover:-translate-x-1" />
                    <span className="font-medium">Đăng xuất</span>
                </button>
                <div className="mt-6 text-[10px] text-slate-500 text-center font-medium opacity-50">
                    Version 2.0.0 • Powered by Antigravity
                </div>
            </div>
        </div>
    );
};

export default Sidebar;
