/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.{js,jsx,ts,tsx}"],
  theme: {
    extend: {
      colors: {
        primary: "#dfcefd",
        bg: "#150c1d",
        "dark-purple": "#463b53",
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
        rotate180: {
          "0%": { transform: "rotate(0deg)" },
          "100%": { transform: "rotate(180deg)" },
        },
        pop: {
          "0%": { transform: "scale(1)", opacity: "1", color: "#463b53" },
          "15%": { transform: "scale(1.08)", opacity: "0.8", color: "#463b53" },
          "25%,100%": { transform: "scale(1)", opacity: "1", color: "#463b53" },
        },
      },
      animation: {
        growY: "growY 1.5s ease-in-out forwards",
        rotate180: "rotate180 1.5s ease-in-out forwards",
        "pop-by-sec": "pop 1s infinite",
      },
      fontSize: {
        "3xl": ["32px", "40px"],
      },
      spacing: {
        15: "3.75rem",
      },
    },
  },
  plugins: [require("./src/tailwind-plugins/padded-horizontal")],
};
