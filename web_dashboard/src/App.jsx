import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import AdminLayout from './components/AdminLayout';
import UserLayout from './components/UserLayout';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import Events from './pages/Events';
import Students from './pages/Students';
import UserHome from './pages/UserHome';
import { authService } from './services/api';
import './App.css';

const RoleBasedRedirect = () => {
  const user = authService.getCurrentUser();
  if (!user) return <Navigate to="/login" replace />;
  if (user.role === 'admin') return <Navigate to="/admin" replace />;
  return <Navigate to="/home" replace />;
};

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/login" element={<Login />} />

        {/* Điều hướng gốc dựa trên Role */}
        <Route path="/" element={<RoleBasedRedirect />} />

        {/* Cụm Route cho Admin */}
        <Route path="/admin" element={<AdminLayout />}>
          <Route index element={<Dashboard />} />
          <Route path="events" element={<Events />} />
          <Route path="students" element={<Students />} />
        </Route>

        {/* Cụm Route cho Sinh viên */}
        <Route path="/home" element={<UserLayout />}>
          <Route index element={<UserHome />} />
        </Route>

        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </Router>
  );
}

export default App;
