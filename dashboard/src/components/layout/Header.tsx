import { User as UserIcon } from 'lucide-react';
import type { User } from '../../features/auth/types';

export const Header = ({ user }: { user: User }) => {
    return (
        <header className="h-16 border-b border-gray-800 bg-surface flex items-center justify-end px-8">
            <div className="flex items-center gap-3">
                <div className="text-right hidden sm:block">
                    <p className="text-sm font-medium text-white leading-tight">{user.displayName}</p>
                    <p className="text-xs text-textSecondary">{user.role}</p>
                </div>
                <div className="w-9 h-9 rounded-full bg-primary/30 flex items-center justify-center border border-primary/50">
                    <UserIcon className="w-5 h-5 text-secondary" />
                </div>
            </div>
        </header>
    );
};
