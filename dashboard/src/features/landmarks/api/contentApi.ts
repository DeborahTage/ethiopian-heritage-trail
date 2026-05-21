import api from '../../../services/api';
import type { LandmarkContent, LandmarkContentPayload, UploadResponse } from '../contentTypes';

export const fetchLandmarkContent = async (landmarkId: string): Promise<LandmarkContent> => {
    const response = await api.get(`/admin/landmarks/${landmarkId}/content`);
    return response.data;
};

export const createLandmarkContent = async (
    landmarkId: string,
    payload: LandmarkContentPayload
): Promise<LandmarkContent> => {
    const response = await api.post(`/admin/landmarks/${landmarkId}/content`, payload);
    return response.data;
};

export const updateLandmarkContent = async (
    landmarkId: string,
    payload: LandmarkContentPayload
): Promise<LandmarkContent> => {
    const response = await api.put(`/admin/landmarks/${landmarkId}/content`, payload);
    return response.data;
};

export const uploadLandmarkFile = async (
    type: 'image' | 'video' | 'audio',
    file: File,
    landmarkId: string
): Promise<UploadResponse> => {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('landmarkId', landmarkId);
    const response = await api.post(`/admin/upload/${type}`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
    });
    return response.data;
};
