import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useNavigate, useParams } from 'react-router-dom';
import { fetchLandmark, updateLandmark } from './api/landmarkApi';
import { LandmarkForm } from './components/LandmarkForm';
import type { LandmarkUpdateData } from './types';

export const LandmarkEditPage = () => {
    const { id } = useParams<{ id: string }>();
    const navigate = useNavigate();
    const queryClient = useQueryClient();

    const { data: landmark, isLoading } = useQuery({
        queryKey: ['landmarks', id],
        queryFn: () => fetchLandmark(id!)
    });

    const mutation = useMutation({
        mutationFn: (data: LandmarkUpdateData) => updateLandmark(id!, data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['landmarks'] });
            navigate('/landmarks');
        }
    });

    if (isLoading) return <div className="text-textSecondary animate-pulse">Loading site data...</div>;
    if (!landmark) return <div className="text-error">Site not found.</div>;

    return (
        <div className="max-w-4xl mx-auto space-y-6">
            <div>
                <h1 className="text-3xl font-bold text-white tracking-tight">Edit Heritage Site</h1>
                <p className="text-textSecondary mt-1">Update details for {landmark.name}</p>
            </div>

            <div className="bg-surface border border-gray-800 rounded-2xl p-6 shadow-sm">
                <LandmarkForm
                    initialData={landmark}
                    onSubmit={(data: LandmarkUpdateData) => mutation.mutate(data)}
                    isSubmitting={mutation.isPending}
                    isEdit
                />
            </div>
        </div>
    );
};
