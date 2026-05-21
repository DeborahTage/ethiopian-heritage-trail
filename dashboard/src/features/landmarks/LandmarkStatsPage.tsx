import { useQuery } from '@tanstack/react-query';
import { useParams, Link } from 'react-router-dom';
import { fetchLandmarkStats } from './api/landmarkApi';
import { ArrowLeft, Users, QrCode, Award } from 'lucide-react';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

export const LandmarkStatsPage = () => {
    const { id } = useParams<{ id: string }>();

    const { data: stats, isLoading } = useQuery({
        queryKey: ['landmarkStats', id],
        queryFn: () => fetchLandmarkStats(id!)
    });

    if (isLoading) return <div className="text-textSecondary animate-pulse">Loading stats...</div>;
    if (!stats) return <div className="text-error">Failed to load stats.</div>;

    
    const chartData = stats.timeSeriesData || [];

    return (
        <div className="max-w-6xl mx-auto space-y-6">
            <div className="flex items-center gap-4">
                <Link to="/landmarks" className="p-2 bg-surface border border-gray-800 rounded-xl hover:bg-white/5 transition text-textSecondary hover:text-white">
                    <ArrowLeft className="w-5 h-5" />
                </Link>
                <div>
                    <h1 className="text-3xl font-bold text-white tracking-tight">{stats.landmarkName || 'Landmark Stats'}</h1>
                    <p className="text-textSecondary mt-1">Performance and visitor engagement metrics</p>
                </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div className="bg-surface border border-gray-800 p-6 rounded-2xl flex items-center gap-4">
                    <div className="w-12 h-12 bg-primary/20 flex items-center justify-center rounded-xl text-primary">
                        <QrCode className="w-6 h-6" />
                    </div>
                    <div>
                        <p className="text-textSecondary text-sm">Total Scans</p>
                        <p className="text-2xl font-bold text-white">{stats.totalScans || 0}</p>
                    </div>
                </div>

                <div className="bg-surface border border-gray-800 p-6 rounded-2xl flex items-center gap-4">
                    <div className="w-12 h-12 bg-blue-500/20 flex items-center justify-center rounded-xl text-blue-400">
                        <Users className="w-6 h-6" />
                    </div>
                    <div>
                        <p className="text-textSecondary text-sm">Unique Visitors</p>
                        <p className="text-2xl font-bold text-white">{stats.uniqueVisitors || 0}</p>
                    </div>
                </div>

                <div className="bg-surface border border-gray-800 p-6 rounded-2xl flex items-center gap-4">
                    <div className="w-12 h-12 bg-amber-500/20 flex items-center justify-center rounded-xl text-amber-400">
                        <Award className="w-6 h-6" />
                    </div>
                    <div>
                        <p className="text-textSecondary text-sm">Points Rewarded</p>
                        <p className="text-2xl font-bold text-white">{stats.totalPointsRewarded || 0}</p>
                    </div>
                </div>
            </div>

            <div className="bg-surface border border-gray-800 p-6 rounded-2xl h-[400px]">
                <h3 className="text-lg font-semibold text-white mb-6">Scan Activity over time</h3>
                {chartData.length > 0 ? (
                    <ResponsiveContainer width="100%" height="100%">
                        <AreaChart data={chartData} margin={{ top: 10, right: 30, left: 0, bottom: 0 }}>
                            <defs>
                                <linearGradient id="colorScans" x1="0" y1="0" x2="0" y2="1">
                                    <stop offset="5%" stopColor="#25D366" stopOpacity={0.3} />
                                    <stop offset="95%" stopColor="#25D366" stopOpacity={0} />
                                </linearGradient>
                            </defs>
                            <XAxis dataKey="date" stroke="#6b7280" fontSize={12} tickLine={false} axisLine={false} />
                            <YAxis stroke="#6b7280" fontSize={12} tickLine={false} axisLine={false} />
                            <CartesianGrid strokeDasharray="3 3" stroke="#374151" vertical={false} />
                            <Tooltip
                                contentStyle={{ backgroundColor: '#111827', borderColor: '#1f2937', color: '#fff', borderRadius: '8px' }}
                                itemStyle={{ color: '#25D366' }}
                            />
                            <Area type="monotone" dataKey="scans" stroke="#25D366" strokeWidth={2} fillOpacity={1} fill="url(#colorScans)" />
                        </AreaChart>
                    </ResponsiveContainer>
                ) : (
                    <div className="flex h-full items-center justify-center text-textSecondary">
                        No temporal data available.
                    </div>
                )}
            </div>
        </div>
    );
};
