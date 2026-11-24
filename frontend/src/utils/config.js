// Dynamic backend URL configuration
// In browser, uses current host on port 5000 (works on both localhost and AWS EC2 IP)
export const BACKEND_URL = import.meta.env.VITE_BACKEND_URL || 
    (typeof window !== 'undefined' && window.location.hostname 
        ? `http://${window.location.hostname}:5000` 
        : 'http://localhost:5000');
