/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.{js,jsx,ts,tsx}"],
  theme: {
    extend: {
      colors: {
        primary: "#dfcefd",
        bg: "#150c1d",
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
      },
      animation: {
        growY: "growY 1.5s ease-in-out forwards",
        rotate180: "rotate180 1.5s ease-in-out forwards",
      },
    },
  },
  plugins: [require("./src/tailwind-plugins/padded-horizontal")],
};
