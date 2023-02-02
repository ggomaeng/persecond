/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.{js,jsx,ts,tsx}"],
  theme: {
    extend: {
      colors: {
        primary: "#dfcefd",
        secondary: "#8a6eaa",
        "input-border": "#4a4a4a",
        "option-border": "#2a1636",
        "modal-bg": "#170726",
        bg: "#150c1d",
        "dark-purple": "#463b53",
      },
      screens: {
        maxscreen: "1500px",
        fullscreen: "1280px",
        laptop: "1024px",
        detail: "840px",
        tablet: "600px",
        mobile: "425px",
      },
      keyframes: {
        fade: {
          "0%": { opacity: "0" },
          "100%": { opacity: "1" },
        },
        growY: {
          "0%": { minHeight: 0 },
          "100%": { minHeight: "100%" },
        },
        growY60: {
          "0%": { minHeight: 0 },
          "100%": { minHeight: "75%" },
        },
        growY90: {
          "0%": { minHeight: 0 },
          "100%": { minHeight: "86%" },
        },
        rotate180: {
          "0%": { transform: "rotate(-10deg)" },
          "100%": { transform: "rotate(190deg)" },
        },
        pop: {
          "0%": { transform: "scale(1)", opacity: "1", color: "#463b53" },
          "12%": { transform: "scale(1.05)", opacity: "0.8" },
          "20%,100%": { transform: "scale(1)", opacity: "1", color: "#463b53" },
        },
      },
      animation: {
        growY: "growY 1.5s ease-in-out forwards",
        growYmobile: "growY60 1.5s ease-in-out forwards",
        growYRed: "growY90 1.5s ease-in-out forwards",
        rotate180: "rotate180 1.5s ease-in-out forwards",
        "pop-by-sec": "pop 1s infinite",
        fadeIn: "fade 125ms ease-in-out forwards",
      },
      fontSize: {
        "3xl": ["32px", "40px"],
        "2xl": ["22px", "30px"],
      },
      spacing: {
        15: "3.75rem",
        5.5: "1.375rem",
      },
    },
  },
  plugins: [require("./src/tailwind-plugins/padded-horizontal")],
};
