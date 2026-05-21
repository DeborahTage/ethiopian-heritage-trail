export interface HeatmapPoint {
    landmarkId: string;
    lat: number;
    lng: number;
    count: number;
}

export interface AnalyticsResponse {
    totalScans: number;
    successfulScans: number;
    failedScans: number;
    successRate: number;
    heatmapPoints: HeatmapPoint[];
    flowData: Array<Record<string, any>>;
    scansByHour: Record<string, number>;
    scansByLandmark: Record<string, number>;
}
