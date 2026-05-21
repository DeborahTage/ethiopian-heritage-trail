import { Outlet } from 'react-router-dom';
import { Sidebar } from './Sidebar';
import { Header } from './Header';
import type { User } from '../../features/auth/types';

export const MainLayout = () => {
    const userStr = localStorage.getItem('user');
    const user = userStr ? JSON.parse(userStr) as User : null;

    if (!user) return null;

    return (
        <div className="flex h-screen w-screen overflow-hidden bg-background">
            <Sidebar user={user} />
            <div className="flex-1 flex flex-col min-w-0">
                <Header user={user} />
                <main className="flex-1 overflow-y-auto p-8">
                    <Outlet />
                </main>
            </div>
        </div>
    );
};
