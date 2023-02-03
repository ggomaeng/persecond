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
        mobile: "500px",
      },
      keyframes: {
        fade: {
          "0%": { opacity: "0" },
          "100%": { opacity: "1" },
        },
        fadeO: {
          "0%": { opacity: "1" },
          "50%": { opacity: "1" },
          "100%": { opacity: "0" },
        },
        growY: {
          "0%": { minHeight: 0 },
          "100%": { minHeight: "100%" },
        },
        growY75: {
          "0%": { minHeight: 0 },
          "100%": { minHeight: "87%" },
        },
        growY71: {
          "0%": { minHeight: 0 },
          "100%": { minHeight: "76%" },
        },
        growY90: {
          "0%": { minHeight: 0 },
          "100%": { minHeight: "87%" },
        },
        rotate180: {
          "0%": { transform: "rotate(0deg)" },
          "100%": { transform: "rotate(180deg)" },
        },
        rotate360: {
          "0%": { transform: "rotate(0deg)" },
          "100%": { transform: "rotate(360deg)" },
        },
        pop: {
          "0%": { transform: "scale(1)", opacity: "1" },
          "3%": { transform: "scale(1.05)", opacity: "0.8" },
          "15%,100%": { transform: "scale(1)", opacity: "1" },
        },
      },
      animation: {
        growY: "growY 1.5s ease-in-out forwards",
        growYmobile: "growY75 1.5s ease-in-out forwards",
        growYmobileRed: "growY71 1.5s ease-in-out forwards",
        growYRed: "growY90 1.5s ease-in-out forwards",
        rotate180: "rotate180 1.5s ease-in-out forwards",
        rotate360: "rotate360 1.5s linear infinite forwards",
        "pop-by-sec": "pop 1s infinite",
        fadeIn: "fade 125ms ease-in-out forwards",
        fadeOut: "fadeO 1s ease-in-out forwards",
      },
      fontSize: {
        "4xl": ["44px", "54px"],
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
