import { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { LogIn } from 'lucide-react';
import api from '../../services/api';
import type { AuthResponse } from './types';

export const LoginPage = () => {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);
    const navigate = useNavigate();
    const location = useLocation();

    const handleLogin = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setError('');

        try {
            const { data } = await api.post<AuthResponse>('/auth/login', { email, password });
            localStorage.setItem('access_token', data.accessToken);
            localStorage.setItem('refresh_token', data.refreshToken);
            localStorage.setItem('user', JSON.stringify(data.user)); // Store role for UI

            const from = location.state?.from?.pathname || '/analytics';
            navigate(from, { replace: true });
        } catch (err: any) {
            setError(err.response?.data?.message || 'Failed to login');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen flex items-center justify-center bg-background px-4">
            <div className="max-w-md w-full bg-surface p-8 rounded-2xl shadow-xl border border-gray-800">
                <div className="text-center mb-8">
                    <div className="mx-auto bg-primary/20 w-16 h-16 rounded-full flex items-center justify-center mb-4">
                        <LogIn className="w-8 h-8 text-secondary" />
                    </div>
                    <h2 className="text-2xl font-bold text-textPrimary">Heritage Admin</h2>
                    <p className="text-textSecondary text-sm mt-2">Sign in to manage the trail</p>
                </div>

                <form onSubmit={handleLogin} className="space-y-6">
                    <div>
                        <label className="text-sm font-medium text-textSecondary block mb-2">Email Address</label>
                        <input
                            type="email"
                            required
                            className="w-full bg-cardBg border border-gray-700 rounded-lg px-4 py-3 text-textPrimary focus:outline-none focus:border-secondary transition-colors"
                            value={email}
                            onChange={e => setEmail(e.target.value)}
                        />
                    </div>

                    <div>
                        <label className="text-sm font-medium text-textSecondary block mb-2">Password</label>
                        <input
                            type="password"
                            required
                            className="w-full bg-cardBg border border-gray-700 rounded-lg px-4 py-3 text-textPrimary focus:outline-none focus:border-secondary transition-colors"
                            value={password}
                            onChange={e => setPassword(e.target.value)}
                        />
                    </div>

                    {error && <div className="text-error text-sm text-center">{error}</div>}

                    <button
                        type="submit"
                        disabled={loading}
                        className="w-full bg-primary hover:bg-primary/90 text-white font-medium rounded-lg py-3 transition-colors flex justify-center items-center"
                    >
                        {loading ? <span className="animate-pulse">Signing in...</span> : 'Sign In'}
                    </button>
                </form>
            </div>
        </div>
    );
};
