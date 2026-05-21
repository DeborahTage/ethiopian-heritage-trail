import React from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import type { User } from '../../features/auth/types';

export const RequireAuth = ({ children, allowedRoles }: { children: React.ReactNode, allowedRoles?: string[] }) => {
    const token = localStorage.getItem('access_token');
    const userStr = localStorage.getItem('user');
    const location = useLocation();

    if (!token || !userStr) {
        return <Navigate to="/login" state={{ from: location }} replace />;
    }

    const user = JSON.parse(userStr) as User;
    if (allowedRoles && !allowedRoles.includes(user.role)) {
        return <Navigate to="/" replace />; // not authorized, send back
    }

    return children;
};
