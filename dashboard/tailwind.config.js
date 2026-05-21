/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        background: '#0F0F13',
        surface: '#1A1C23',
        cardBg: '#1f212a',
        primary: '#2F3C7E',
        secondary: '#FBEAEB',
        accent: '#F3A683',
        gold: '#F7D794',
        textPrimary: '#F1F2F6',
        textSecondary: '#A4B0BE',
        success: '#10ac84',
        error: '#ff5252',
      }
    },
  },
  plugins: [],
}
