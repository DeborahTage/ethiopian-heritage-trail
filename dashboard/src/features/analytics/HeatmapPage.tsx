import { useQuery } from '@tanstack/react-query';
import { fetchHeatmap } from './api/analyticsApi';
import { MapContainer, TileLayer, CircleMarker, Popup } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';

export const HeatmapPage = () => {
    // 30 days ago and today
    const end = new Date();
    const start = new Date(end);
    start.setDate(end.getDate() - 30);

    const startDate = start.toISOString().split('T')[0];
    const endDate = end.toISOString().split('T')[0];

    const { data: analytics, isLoading } = useQuery({
        queryKey: ['analytics_heatmap', startDate, endDate],
        queryFn: () => fetchHeatmap(startDate, endDate)
    });

    if (isLoading) return <div className="text-textSecondary animate-pulse">Loading heatmap...</div>;
    if (!analytics) return <div className="text-error">Failed to load heatmap data.</div>;

    const points = analytics.heatmapPoints || [];

    // Addis Ababa fallback center
    const center: [number, number] = points.length > 0
        ? [points[0].lat, points[0].lng]
        : [9.03, 38.74];

    return (
        <div className="space-y-4 pt-2 h-[calc(100vh-200px)] flex flex-col">
            <p className="text-textSecondary text-sm mb-2">Displaying heatmap based on physical scan density across heritage sites.</p>
            <div className="flex-1 rounded-2xl overflow-hidden border border-gray-800 bg-surface">
                {points.length > 0 ? (
                    <MapContainer center={center} zoom={12} style={{ height: '100%', width: '100%' }}>
                        <TileLayer
                            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                            url="https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
                        />
                        {points.map((pt, idx) => {
                            // Scale radius visually logic: base 10 + count
                            const radius = Math.min(30, 10 + (pt.count * 0.5));
                            // Opacity increases slightly with count
                            const opacity = Math.min(0.9, 0.4 + (pt.count * 0.05));

                            return (
                                <CircleMarker
                                    key={idx}
                                    center={[pt.lat, pt.lng]}
                                    radius={radius}
                                    pathOptions={{
                                        color: '#ef4444',
                                        fillColor: '#ef4444',
                                        fillOpacity: opacity,
                                        weight: 0
                                    }}
                                >
                                    <Popup className="text-gray-900 font-medium">
                                        Landmark ID: {pt.landmarkId}<br />
                                        Total Scans: {pt.count}
                                    </Popup>
                                </CircleMarker>
                            )
                        })}
                    </MapContainer>
                ) : (
                    <div className="flex h-full items-center justify-center text-textSecondary">
                        No heatmap scans generated for the current window.
                    </div>
                )}
            </div>
        </div>
    );
};
