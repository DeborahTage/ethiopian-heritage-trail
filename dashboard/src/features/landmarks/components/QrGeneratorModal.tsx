import { X, Download } from 'lucide-react';
import { getQrCodeUrl } from '../api/landmarkApi';

interface Props {
    landmarkId: string;
    landmarkName: string;
    onClose: () => void;
}

export const QrGeneratorModal = ({ landmarkId, landmarkName, onClose }: Props) => {
    const qrUrl = getQrCodeUrl(landmarkId);

    const handleDownload = async () => {
        try {
            const response = await fetch(qrUrl, {
                headers: {
                    'Authorization': `Bearer ${localStorage.getItem('access_token')}`
                }
            });
            const blob = await response.blob();
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `landmark-${landmarkName}-qr.png`;
            document.body.appendChild(a);
            a.click();
            window.URL.revokeObjectURL(url);
            document.body.removeChild(a);
        } catch (error) {
            console.error('Failed to download QR code', error);
        }
    };

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
            <div className="bg-surface border border-gray-800 rounded-2xl w-full max-w-sm overflow-hidden flex flex-col p-6 items-center shadow-2xl relative">
                <button onClick={onClose} className="absolute top-4 right-4 text-textSecondary hover:text-white transition">
                    <X className="w-5 h-5" />
                </button>
                <h3 className="text-xl font-semibold text-white mb-2 text-center">{landmarkName}</h3>
                <p className="text-sm text-textSecondary mb-6 text-center">Scan to verify visitation</p>

                <div className="bg-white p-4 rounded-xl shadow-inner mb-6">
                    <img
                        src={qrUrl}
                        alt="QR Code"
                        className="w-48 h-48 object-contain"
                        onError={(e) => {
                            const target = e.target as HTMLImageElement;
                            target.src = 'https://via.placeholder.com/400?text=QR+Code+Error';
                        }}
                    />
                </div>

                <button
                    onClick={handleDownload}
                    className="w-full py-3 bg-primary text-secondary font-medium rounded-xl hover:bg-primary/90 transition flex items-center justify-center gap-2"
                >
                    <Download className="w-4 h-4" />
                    Download PNG
                </button>
            </div>
        </div>
    );
};
