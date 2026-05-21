import { NavLink, useNavigate } from 'react-router-dom';
import { BarChart3, MapPin, LogOut } from 'lucide-react';
import type { User } from '../../features/auth/types';

export const Sidebar = ({ user }: { user: User }) => {
    const navigate = useNavigate();

    const handleLogout = () => {
        localStorage.clear();
        navigate('/login');
    };

    return (
        <div className="w-64 bg-surface border-r border-gray-800 flex flex-col h-full">
            <div className="p-6">
                <h1 className="text-xl font-bold text-white tracking-tight">Heritage Trail</h1>
                <p className="text-xs text-textSecondary uppercase tracking-widest mt-1">Admin Portal</p>
            </div>

            <nav className="flex-1 px-4 space-y-2 mt-4">
                {['ADMIN'].includes(user.role) && (
                    <NavLink
                        to="/analytics"
                        className={({ isActive }) =>
                            `flex items-center gap-3 px-4 py-3 rounded-xl transition-colors ${isActive ? 'bg-primary/20 text-secondary font-medium' : 'text-textSecondary hover:bg-cardBg hover:text-white'
                            }`
                        }
                    >
                        <BarChart3 className="w-5 h-5" />
                        Analytics
                    </NavLink>
                )}

                {['ADMIN', 'ORGANIZER'].includes(user.role) && (
                    <NavLink
                        to="/landmarks"
                        className={({ isActive }) =>
                            `flex items-center gap-3 px-4 py-3 rounded-xl transition-colors ${isActive ? 'bg-primary/20 text-secondary font-medium' : 'text-textSecondary hover:bg-cardBg hover:text-white'
                            }`
                        }
                    >
                        <MapPin className="w-5 h-5" />
                        Sites
                    </NavLink>
                )}
            </nav>

            <div className="p-4 border-t border-gray-800">
                <button
                    onClick={handleLogout}
                    className="w-full flex items-center justify-center gap-2 px-4 py-3 text-textSecondary hover:text-error hover:bg-error/10 rounded-xl transition-colors group"
                >
                    <LogOut className="w-4 h-4 group-hover:-translate-x-1 transition-transform" />
                    <span className="text-sm font-medium">Log out</span>
                </button>
            </div>
        </div>
    );
};
