import { useMutation, useQueryClient } from '@tanstack/react-query';
import { useNavigate } from 'react-router-dom';
import { createLandmark } from './api/landmarkApi';
import { LandmarkForm } from './components/LandmarkForm';
import type { LandmarkCreateData } from './types';

export const LandmarkCreatePage = () => {
    const navigate = useNavigate();
    const queryClient = useQueryClient();

    const mutation = useMutation({
        mutationFn: createLandmark,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['landmarks'] });
            navigate('/landmarks');
        }
    });

    return (
        <div className="max-w-4xl mx-auto space-y-6">
            <div>
                <h1 className="text-3xl font-bold text-white tracking-tight">Add New Heritage Site</h1>
                <p className="text-textSecondary mt-1">Register a new landmark and generate its QR code.</p>
            </div>

            <div className="bg-surface border border-gray-800 rounded-2xl p-6 shadow-sm">
                <LandmarkForm
                    onSubmit={(data: LandmarkCreateData) => mutation.mutate(data)}
                    isSubmitting={mutation.isPending}
                />
            </div>
        </div>
    );
};
