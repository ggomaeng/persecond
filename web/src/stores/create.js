import { create } from "zustand";

export const useLaunchStore = create((set) => ({
  price: "",
  duration: 0.25,
  setPrice: (num) => set({ price: num }),
  setDuration: (num) => set({ duration: num }),
}));
