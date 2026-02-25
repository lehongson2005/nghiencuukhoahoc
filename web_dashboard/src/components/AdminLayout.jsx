import { Outlet, Navigate } from 'react-router-dom';
import Sidebar from './Sidebar';
import { authService } from '../services/api';

const AdminLayout = () => {
    const user = authService.getCurrentUser();

    if (!user) {
        return <Navigate to="/login" replace />;
    }

    if (user.role !== 'admin') {
        return <Navigate to="/home" replace />;
    }

    return (
        <div className="flex min-h-screen bg-[#F8FAFC]">
            <Sidebar />
            <main className="flex-1 overflow-y-auto">
                <div className="p-10 max-w-7xl mx-auto">
                    <Outlet />
                </div>
            </main>
        </div>
    );
};

export default AdminLayout;
