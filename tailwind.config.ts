import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./app/**/*.{ts,tsx}",
    "./components/**/*.{ts,tsx}",
    "./lib/**/*.{ts,tsx}"
  ],
  theme: {
    extend: {
      colors: {
        ink: "#101828",
        canvas: "#f5f7fb",
        line: "#e4e7ec",
        muted: "#667085",
        primary: {
          50: "#eef4ff",
          100: "#dbe8ff",
          500: "#2e6df6",
          600: "#1456e1",
          700: "#0f43b5"
        },
        success: {
          50: "#ecfdf3",
          500: "#17b26a",
          700: "#067647"
        },
        warning: {
          50: "#fffaeb",
          500: "#f79009",
          700: "#b54708"
        },
        danger: {
          50: "#fef3f2",
          500: "#f04438",
          700: "#b42318"
        }
      },
      boxShadow: {
        soft: "0 20px 40px rgba(16, 24, 40, 0.08)"
      },
      borderRadius: {
        "4xl": "2rem"
      }
    }
  },
  plugins: []
};

export default config;
