import api from '../../../services/api';
import type { Landmark, LandmarkCreateData, LandmarkUpdateData } from '../types';

export const fetchLandmarks = async (): Promise<Landmark[]> => {
    const response = await api.get('/landmarks');
    return response.data;
};

export const fetchLandmark = async (id: string): Promise<Landmark> => {
    const response = await api.get(`/landmarks/${id}`);
    return response.data;
};

export const createLandmark = async (data: LandmarkCreateData): Promise<Landmark> => {
    const response = await api.post('/landmarks', data);
    return response.data;
};

export const updateLandmark = async (id: string, data: LandmarkUpdateData): Promise<Landmark> => {
    const response = await api.put(`/landmarks/${id}`, data);
    return response.data;
};

export const deleteLandmark = async (id: string): Promise<void> => {
    await api.delete(`/landmarks/${id}`);
};

export const fetchLandmarkStats = async (id: string) => {
    const response = await api.get(`/analytics/landmarks/${id}`);
    return response.data;
};

export const getQrCodeUrl = (id: string) => {
    return `${api.defaults.baseURL}/landmarks/${id}/qr`;
};