import type { Config } from 'tailwindcss';
import animatePlugin from 'tailwindcss-animate';

const config: Config = {
  content: ['./app/**/*.{ts,tsx}', './components/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        background: 'hsl(0 0% 100%)',
        foreground: 'hsl(222.2 47.4% 11.2%)',
        muted: 'hsl(210 40% 96%)',
        border: 'hsl(214 32% 91%)'
      }
    }
  },
  plugins: [animatePlugin]
};

export default config;
