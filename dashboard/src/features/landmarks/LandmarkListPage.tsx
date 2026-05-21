import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { fetchLandmarks, deleteLandmark } from './api/landmarkApi';
import { Link } from 'react-router-dom';
import { Plus, QrCode, Edit2, Trash2, BarChart2, BookOpen } from 'lucide-react';
import { QrGeneratorModal } from './components/QrGeneratorModal';
import api from '../../services/api';

export const LandmarkListPage = () => {
    const queryClient = useQueryClient();
    const { data: landmarks, isLoading } = useQuery({ queryKey: ['landmarks'], queryFn: fetchLandmarks });

    const [qrModalOpen, setQrModalOpen] = useState<{ id: string, name: string } | null>(null);

    const deleteMutation = useMutation({
        mutationFn: deleteLandmark,
        onSuccess: () => queryClient.invalidateQueries({ queryKey: ['landmarks'] })
    });

    const handleDownload = async (type: 'zip' | 'pdf') => {
        try {
            const token = localStorage.getItem('access_token');
            const response = await fetch(`${api.defaults.baseURL}/admin/landmarks/bulk-qr/${type}`, {
                method: 'POST',
                headers: { 'Authorization': `Bearer ${token}` }
            });
            const blob = await response.blob();
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `bulk_qrs.${type}`;
            document.body.appendChild(a);
            a.click();
            window.URL.revokeObjectURL(url);
            document.body.removeChild(a);
        } catch (e) {
            console.error(e);
        }
    };

    if (isLoading) return <div className="text-textSecondary animate-pulse">Loading sites...</div>;

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <h1 className="text-3xl font-bold text-white tracking-tight">Heritage Sites</h1>
                <div className="flex gap-3">
                    <button onClick={() => handleDownload('zip')} className="flex items-center gap-2 px-4 py-2 bg-surface text-white border border-gray-800 font-medium rounded-xl hover:bg-white/5 transition">
                        Download ZIP
                    </button>
                    <button onClick={() => handleDownload('pdf')} className="flex items-center gap-2 px-4 py-2 bg-surface text-white border border-gray-800 font-medium rounded-xl hover:bg-white/5 transition">
                        Printable PDF
                    </button>
                    <Link to="/landmarks/create" className="flex items-center gap-2 px-4 py-2 bg-primary text-secondary font-medium rounded-xl hover:bg-primary/90 transition">
                        <Plus className="w-4 h-4" /> Add Site
                    </Link>
                </div>
            </div>

            <div className="bg-surface border border-gray-800 rounded-2xl overflow-hidden shadow-sm">
                <div className="overflow-x-auto">
                    <table className="w-full text-left border-collapse">
                        <thead>
                            <tr className="border-b border-gray-800 bg-white/5 text-sm uppercase tracking-wider text-textSecondary">
                                <th className="p-4 font-medium">Name</th>
                                <th className="p-4 font-medium">Category</th>
                                <th className="p-4 font-medium">Points</th>
                                <th className="p-4 font-medium text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            {landmarks?.map(landmark => (
                                <tr key={landmark.id} className="border-b border-gray-800/50 hover:bg-white/5 transition group">
                                    <td className="p-4">
                                        <div className="font-medium text-white">{landmark.name}</div>
                                        <div className="text-sm text-textSecondary">{landmark.region}</div>
                                    </td>
                                    <td className="p-4">
                                        <span className="px-2.5 py-1 bg-gray-800 text-xs rounded-full text-gray-300">
                                            {landmark.category}
                                        </span>
                                    </td>
                                    <td className="p-4 text-primary font-medium">+{landmark.pointsValue}</td>
                                    <td className="p-4 flex gap-2 justify-end">
                                        <button title="View QR" onClick={() => setQrModalOpen({ id: landmark.id, name: landmark.name })} className="p-2 text-textSecondary hover:text-white bg-gray-800 hover:bg-gray-700 rounded-lg transition">
                                            <QrCode className="w-4 h-4" />
                                        </button>
                                        <Link title="Stats" to={`/landmarks/${landmark.id}/stats`} className="p-2 text-textSecondary hover:text-blue-400 bg-gray-800 hover:bg-gray-700 rounded-lg transition">
                                            <BarChart2 className="w-4 h-4" />
                                        </Link>
                                        <Link title="Edit Content" to={`/landmarks/${landmark.id}/content`} className="p-2 text-textSecondary hover:text-primary bg-gray-800 hover:bg-gray-700 rounded-lg transition">
                                            <BookOpen className="w-4 h-4" />
                                        </Link>
                                        <Link title="Edit" to={`/landmarks/${landmark.id}/edit`} className="p-2 text-textSecondary hover:text-amber-400 bg-gray-800 hover:bg-gray-700 rounded-lg transition">
                                            <Edit2 className="w-4 h-4" />
                                        </Link>
                                        <button title="Delete" onClick={() => { if (window.confirm('Deactivate site?')) deleteMutation.mutate(landmark.id) }} className="p-2 text-textSecondary hover:text-error bg-gray-800 hover:bg-gray-700 rounded-lg transition">
                                            <Trash2 className="w-4 h-4" />
                                        </button>
                                    </td>
                                </tr>
                            ))}
                            {(!landmarks || landmarks.length === 0) && (
                                <tr>
                                    <td colSpan={4} className="p-8 text-center text-textSecondary">No heritage sites found. Create one.</td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>
            </div>

            {qrModalOpen && (
                <QrGeneratorModal
                    landmarkId={qrModalOpen.id}
                    landmarkName={qrModalOpen.name}
                    onClose={() => setQrModalOpen(null)}
                />
            )}
        </div>
    );
};
