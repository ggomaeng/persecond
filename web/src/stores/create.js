import { create } from "zustand";

export const useCreateStore = create((set) => ({
  title: "",
  price: "",
  duration: 0.25,
  description: "",
  setTitle: (title) => set({ title }),
  setPrice: (num) => set({ price: num }),
  setDuration: (num) => set({ duration: num }),
  setDescription: (description) => set({ description }),
}));
