export interface User {
    id: string;
    email: string;
    displayName: string;
    role: 'ADMIN' | 'ORGANIZER' | 'USER';
}

export interface AuthResponse {
    accessToken: string;
    refreshToken: string;
    user: User;
}
