export interface Landmark {
    id: string;
    name: string;
    nameAm?: string;
    description: string;
    descriptionAm?: string;
    latitude: number;
    longitude: number;
    address?: string;
    region?: string;
    category: 'HERITAGE' | 'MUSEUM' | 'CHURCH' | 'MOSQUE' | 'PALACE' | 'NATURE' | 'OTHER';
    mediaUrl?: string;
    gpsRadiusMeters: number;
    pointsValue: number;
    visited?: boolean;
    qrCodeUrl?: string;
}

export type LandmarkCreateData = Omit<Landmark, 'id' | 'visited' | 'qrCodeUrl'>;
export type LandmarkUpdateData = Omit<Landmark, 'id' | 'visited' | 'qrCodeUrl'> & { isActive: boolean };
