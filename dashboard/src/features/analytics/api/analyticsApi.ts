 import api from '../../../services/api';
import type { AnalyticsResponse } from '../types';

export const fetchHeatmap = async (startDate: string, endDate: string): Promise<AnalyticsResponse> => {
    const response = await api.get('/analytics/heatmap', {
        params: { startDate, endDate }
    });
    return response.data;
};

export const fetchFlow = async (startDate?: string, endDate?: string, landmarkId?: string): Promise<AnalyticsResponse> => {
    const response = await api.get('/analytics/flow', {
        params: { startDate, endDate, landmarkId }
    });
    return response.data;
};
