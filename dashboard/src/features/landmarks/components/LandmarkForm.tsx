import React, { useState } from 'react';
import { MapContainer, TileLayer, Marker, useMapEvents } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';
import type { LandmarkCreateData } from '../types';
import { useNavigate } from 'react-router-dom';

// Fix Leaflet's default icon issue
import icon from 'leaflet/dist/images/marker-icon.png';
import iconShadow from 'leaflet/dist/images/marker-shadow.png';
const DefaultIcon = L.icon({
    iconUrl: icon,
    shadowUrl: iconShadow,
    iconAnchor: [12, 41]
});
L.Marker.prototype.options.icon = DefaultIcon;

interface Props {
    initialData?: Partial<LandmarkCreateData>;
    onSubmit: (data: any) => void;
    isSubmitting: boolean;
    isEdit?: boolean;
}

const LocationPicker = ({ position, setPosition }: { position: L.LatLngExpression, setPosition: (p: L.LatLngExpression) => void }) => {
    useMapEvents({
        click(e) {
            setPosition([e.latlng.lat, e.latlng.lng]);
        },
    });

    return position ? <Marker position={position} /> : null;
};

export const LandmarkForm = ({ initialData, onSubmit, isSubmitting, isEdit }: Props) => {
    const navigate = useNavigate();
    const [formData, setFormData] = useState<Partial<LandmarkCreateData>>({
        name: initialData?.name || '',
        nameAm: initialData?.nameAm || '',
        description: initialData?.description || '',
        descriptionAm: initialData?.descriptionAm || '',
        category: initialData?.category || 'HERITAGE',
        address: initialData?.address || '',
        region: initialData?.region || '',
        gpsRadiusMeters: initialData?.gpsRadiusMeters || 100,
        pointsValue: initialData?.pointsValue || 10,
        ...initialData
    });

    const [location, setLocation] = useState<L.LatLngExpression>(
        initialData?.latitude ? [initialData.latitude, initialData.longitude!] : [9.03, 38.74] // Default Addis Ababa
    );

    const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
        const { name, value } = e.target;
        setFormData(prev => ({ ...prev, [name]: name === 'gpsRadiusMeters' || name === 'pointsValue' ? Number(value) : value }));
    };

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        onSubmit({
            ...formData,
            latitude: (location as any)[0],
            longitude: (location as any)[1],
            isActive: isEdit ? (initialData as any).isActive ?? true : true
        });
    };

    return (
        <form onSubmit={handleSubmit} className="space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                    <label className="block text-sm font-medium text-textSecondary mb-1">Name (English)</label>
                    <input required type="text" name="name" value={formData.name} onChange={handleChange} className="w-full bg-surface border border-gray-800 rounded-lg p-2.5 text-white" />
                </div>
                <div>
                    <label className="block text-sm font-medium text-textSecondary mb-1">Name (Amharic)</label>
                    <input type="text" name="nameAm" value={formData.nameAm} onChange={handleChange} className="w-full bg-surface border border-gray-800 rounded-lg p-2.5 text-white" />
                </div>

                <div className="md:col-span-2 grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                        <label className="block text-sm font-medium text-textSecondary mb-1">Description (English)</label>
                        <textarea required name="description" value={formData.description} onChange={handleChange} className="w-full bg-surface border border-gray-800 rounded-lg p-2.5 text-white h-24" />
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-textSecondary mb-1">Description (Amharic)</label>
                        <textarea name="descriptionAm" value={formData.descriptionAm} onChange={handleChange} className="w-full bg-surface border border-gray-800 rounded-lg p-2.5 text-white h-24" />
                    </div>
                </div>

                <div>
                    <label className="block text-sm font-medium text-textSecondary mb-1">Category</label>
                    <select name="category" value={formData.category} onChange={handleChange} className="w-full bg-surface border border-gray-800 rounded-lg p-2.5 text-white">
                        <option value="HERITAGE">Heritage</option>
                        <option value="MUSEUM">Museum</option>
                        <option value="CHURCH">Church</option>
                        <option value="MOSQUE">Mosque</option>
                        <option value="PALACE">Palace</option>
                        <option value="NATURE">Nature</option>
                        <option value="OTHER">Other</option>
                    </select>
                </div>

                <div>
                    <label className="block text-sm font-medium text-textSecondary mb-1">Region</label>
                    <input type="text" name="region" value={formData.region} onChange={handleChange} className="w-full bg-surface border border-gray-800 rounded-lg p-2.5 text-white" />
                </div>

                <div>
                    <label className="block text-sm font-medium text-textSecondary mb-1">Points Value</label>
                    <input required type="number" name="pointsValue" value={formData.pointsValue} onChange={handleChange} className="w-full bg-surface border border-gray-800 rounded-lg p-2.5 text-white" />
                </div>

                <div>
                    <label className="block text-sm font-medium text-textSecondary mb-1">GPS Radius (meters)</label>
                    <input required type="number" name="gpsRadiusMeters" value={formData.gpsRadiusMeters} onChange={handleChange} className="w-full bg-surface border border-gray-800 rounded-lg p-2.5 text-white" />
                </div>

                <div className="md:col-span-2">
                    <label className="block text-sm font-medium text-textSecondary mb-1">Location Map (Click to set default location)</label>
                    <div className="h-64 w-full rounded-lg overflow-hidden border border-gray-800">
                        <MapContainer center={location as L.LatLngExpression} zoom={13} style={{ height: '100%', width: '100%' }}>
                            <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
                            <LocationPicker position={location} setPosition={setLocation} />
                        </MapContainer>
                    </div>
                    <div className="mt-2 text-sm text-textSecondary flex gap-4">
                        <span>Lat: {(location as any)[0].toFixed(6)}</span>
                        <span>Lng: {(location as any)[1].toFixed(6)}</span>
                    </div>
                </div>
            </div>

            <div className="flex justify-end gap-4 mt-8">
                <button type="button" onClick={() => navigate('/landmarks')} className="px-4 py-2 text-textSecondary hover:text-white hover:bg-white/10 rounded-lg transition">Cancel</button>
                <button type="submit" disabled={isSubmitting} className="px-4 py-2 bg-primary text-secondary font-medium rounded-lg hover:bg-primary/90 transition disabled:opacity-50">
                    {isSubmitting ? 'Saving...' : 'Save Landmark'}
                </button>
            </div>
        </form>
    );
};
