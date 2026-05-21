import { useQuery } from '@tanstack/react-query';
import { fetchFlow } from './api/analyticsApi';
import { AreaChart, Area, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { BarChart3, TrendingUp, AlertTriangle } from 'lucide-react';

export const OverviewPage = () => {
    const { data: analytics, isLoading } = useQuery({
        queryKey: ['analytics_flow'],
        queryFn: () => fetchFlow()
    });

    if (isLoading) return <div className="text-textSecondary animate-pulse">Loading overview...</div>;
    if (!analytics) return <div className="text-error">Failed to load analytics data.</div>;

    const hourlyData = Object.entries(analytics.scansByHour || {}).map(([hour, scans]) => ({ hour, scans }));
    const landmarkData = Object.entries(analytics.scansByLandmark || {}).map(([name, scans]) => ({ name, scans }));

    return (
        <div className="space-y-6 pt-2">
            <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
                <div className="bg-surface border border-gray-800 p-6 rounded-2xl flex items-center gap-4">
                    <div className="w-12 h-12 bg-primary/20 flex items-center justify-center rounded-xl text-primary">
                        <BarChart3 className="w-6 h-6" />
                    </div>
                    <div>
                        <p className="text-textSecondary text-sm">Total Scans</p>
                        <p className="text-2xl font-bold text-white">{analytics.totalScans}</p>
                    </div>
                </div>

                <div className="bg-surface border border-gray-800 p-6 rounded-2xl flex items-center gap-4">
                    <div className="w-12 h-12 bg-blue-500/20 flex items-center justify-center rounded-xl text-blue-400">
                        <TrendingUp className="w-6 h-6" />
                    </div>
                    <div>
                        <p className="text-textSecondary text-sm">Successful</p>
                        <p className="text-2xl font-bold text-white">{analytics.successfulScans}</p>
                    </div>
                </div>

                <div className="bg-surface border border-gray-800 p-6 rounded-2xl flex items-center gap-4">
                    <div className="w-12 h-12 bg-error/20 flex items-center justify-center rounded-xl text-error">
                        <AlertTriangle className="w-6 h-6" />
                    </div>
                    <div>
                        <p className="text-textSecondary text-sm">Failed</p>
                        <p className="text-2xl font-bold text-white">{analytics.failedScans}</p>
                    </div>
                </div>

                <div className="bg-surface border border-gray-800 p-6 rounded-2xl flex items-center gap-4">
                    <div className="w-12 h-12 bg-amber-500/20 flex items-center justify-center rounded-xl text-amber-400">
                        <TrendingUp className="w-6 h-6" />
                    </div>
                    <div>
                        <p className="text-textSecondary text-sm">Success Rate</p>
                        <p className="text-2xl font-bold text-white">{(analytics.successRate * 100).toFixed(1)}%</p>
                    </div>
                </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <div className="bg-surface border border-gray-800 p-6 rounded-2xl h-[400px] flex flex-col">
                    <h3 className="text-lg font-semibold text-white mb-6">Scan Activity by Hour (Last 30 Days)</h3>
                    <div className="flex-1 min-h-0">
                        {hourlyData.length > 0 ? (
                            <ResponsiveContainer width="100%" height="100%">
                                <AreaChart data={hourlyData}>
                                    <defs>
                                        <linearGradient id="colorHour" x1="0" y1="0" x2="0" y2="1">
                                            <stop offset="5%" stopColor="#25D366" stopOpacity={0.3} />
                                            <stop offset="95%" stopColor="#25D366" stopOpacity={0} />
                                        </linearGradient>
                                    </defs>
                                    <XAxis dataKey="hour" stroke="#6b7280" fontSize={12} tickLine={false} axisLine={false} />
                                    <YAxis stroke="#6b7280" fontSize={12} tickLine={false} axisLine={false} />
                                    <CartesianGrid strokeDasharray="3 3" stroke="#374151" vertical={false} />
                                    <Tooltip contentStyle={{ backgroundColor: '#111827', borderColor: '#1f2937', color: '#fff', borderRadius: '8px' }} itemStyle={{ color: '#25D366' }} />
                                    <Area type="monotone" dataKey="scans" stroke="#25D366" strokeWidth={2} fillOpacity={1} fill="url(#colorHour)" />
                                </AreaChart>
                            </ResponsiveContainer>
                        ) : (
                            <div className="flex h-full items-center justify-center text-textSecondary">No data available</div>
                        )}
                    </div>
                </div>

                <div className="bg-surface border border-gray-800 p-6 rounded-2xl h-[400px] flex flex-col">
                    <h3 className="text-lg font-semibold text-white mb-6">Top Landmarks by Scan Volume</h3>
                    <div className="flex-1 min-h-0">
                        {landmarkData.length > 0 ? (
                            <ResponsiveContainer width="100%" height="100%">
                                <BarChart data={landmarkData} layout="vertical" margin={{ left: 50 }}>
                                    <XAxis type="number" stroke="#6b7280" fontSize={12} tickLine={false} axisLine={false} />
                                    <YAxis dataKey="name" type="category" stroke="#6b7280" fontSize={12} tickLine={false} axisLine={false} />
                                    <CartesianGrid strokeDasharray="3 3" stroke="#374151" horizontal={false} />
                                    <Tooltip contentStyle={{ backgroundColor: '#111827', borderColor: '#1f2937', color: '#fff', borderRadius: '8px' }} cursor={{ fill: '#ffffff0a' }} />
                                    <Bar dataKey="scans" fill="#3b82f6" radius={[0, 4, 4, 0]} />
                                </BarChart>
                            </ResponsiveContainer>
                        ) : (
                            <div className="flex h-full items-center justify-center text-textSecondary">No data available</div>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
};
