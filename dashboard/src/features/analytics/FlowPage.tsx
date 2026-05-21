import { useQuery } from '@tanstack/react-query';
import { fetchFlow } from './api/analyticsApi';

export const FlowPage = () => {
    const { data: analytics, isLoading } = useQuery({
        queryKey: ['analytics_flow'],
        queryFn: () => fetchFlow()
    });

    if (isLoading) return <div className="text-textSecondary animate-pulse">Loading flow analysis...</div>;
    if (!analytics) return <div className="text-error">Failed to load flow data.</div>;

    const flows = analytics.flowData || [];

    return (
        <div className="space-y-6 pt-2">
            <p className="text-textSecondary text-sm mb-4">Analyze how users transition between landmarks.</p>

            <div className="bg-surface border border-gray-800 rounded-2xl overflow-hidden shadow-sm">
                <table className="w-full text-left border-collapse">
                    <thead>
                        <tr className="border-b border-gray-800 bg-white/5 text-sm uppercase tracking-wider text-textSecondary">
                            <th className="p-4 font-medium">Flow Data Source</th>
                            <th className="p-4 font-medium text-right">Details</th>
                        </tr>
                    </thead>
                    <tbody>
                        {flows.map((flow, index) => (
                            <tr key={index} className="border-b border-gray-800/50 hover:bg-white/5 transition">
                                <td className="p-4">
                                    <div className="font-medium text-white">Flow Step #{index + 1}</div>
                                </td>
                                <td className="p-4 text-right text-textSecondary text-sm">
                                    <pre className="inline-block bg-black/40 px-3 py-2 rounded-lg text-left">
                                        {JSON.stringify(flow, null, 2)}
                                    </pre>
                                </td>
                            </tr>
                        ))}
                        {flows.length === 0 && (
                            <tr>
                                <td colSpan={2} className="p-8 text-center text-textSecondary">No relational flow data available for the selected period.</td>
                            </tr>
                        )}
                    </tbody>
                </table>
            </div>
        </div>
    );
};
