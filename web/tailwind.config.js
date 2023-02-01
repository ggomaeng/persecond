/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.{js,jsx,ts,tsx}"],
  theme: {
    extend: {
      colors: {
        primary: "#dfcefd",
      },
    },
  },
  plugins: [require("./src/tailwind-plugins/padded-horizontal")],
};
