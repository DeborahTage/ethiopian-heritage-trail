import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { fetchFlow } from './api/analyticsApi';
import { Download } from 'lucide-react';

export const ReportsPage = () => {
    const defaultEnd = new Date().toISOString().split('T')[0];
    const defaultStart = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];

    const [startDate, setStartDate] = useState(defaultStart);
    const [endDate, setEndDate] = useState(defaultEnd);

    // Fetch Flow data (contains scans by hour, scans by landmark, totals)
    const { data: flowData, isFetching: fetchingFlow } = useQuery({
        queryKey: ['report_flow', startDate, endDate],
        queryFn: () => fetchFlow(startDate, endDate)
    });

    const handleExportCSV = () => {
        if (!flowData) return;

        let csvContent = "data:text/csv;charset=utf-8,";

        // 1. Overall Stats
        csvContent += "Metric,Value\n";
        csvContent += `Total Scans,${flowData.totalScans}\n`;
        csvContent += `Successful Scans,${flowData.successfulScans}\n`;
        csvContent += `Failed Scans,${flowData.failedScans}\n`;
        csvContent += `Success Rate,${(flowData.successRate * 100).toFixed(2)}%\n\n`;

        // 2. Scans by Landmark
        csvContent += "Landmark,Scans\n";
        Object.entries(flowData.scansByLandmark || {}).forEach(([name, count]) => {
            csvContent += `"${name}",${count}\n`;
        });

        const encodedUri = encodeURI(csvContent);
        const link = document.createElement("a");
        link.setAttribute("href", encodedUri);
        link.setAttribute("download", `analytics_report_${startDate}_${endDate}.csv`);
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    };

    return (
        <div className="space-y-6 pt-2 max-w-3xl">
            <p className="text-textSecondary text-sm mb-6">Generate and export analytical reports for physical scan metrics.</p>

            <div className="bg-surface border border-gray-800 p-6 rounded-2xl space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                        <label className="block text-sm font-medium text-textSecondary mb-1">Start Date</label>
                        <input
                            type="date"
                            value={startDate}
                            onChange={e => setStartDate(e.target.value)}
                            className="w-full bg-black/50 border border-gray-800 rounded-lg p-2.5 text-white"
                        />
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-textSecondary mb-1">End Date</label>
                        <input
                            type="date"
                            value={endDate}
                            onChange={e => setEndDate(e.target.value)}
                            className="w-full bg-black/50 border border-gray-800 rounded-lg p-2.5 text-white"
                        />
                    </div>
                </div>

                <div className="flex items-center gap-4 pt-4 border-t border-gray-800">
                    <button
                        onClick={handleExportCSV}
                        disabled={fetchingFlow || !flowData}
                        className="px-6 py-2.5 bg-primary text-secondary font-medium rounded-xl hover:bg-primary/90 transition disabled:opacity-50 flex items-center gap-2"
                    >
                        <Download className="w-4 h-4" />
                        Export to CSV
                    </button>
                    {fetchingFlow && <span className="text-sm text-textSecondary animate-pulse">Fetching latest data...</span>}
                </div>
            </div>
        </div>
    );
};
