import { create } from "zustand";

export const useCreateStore = create((set) => ({
  title: "",
  rate: "",
  duration: 0.25,
  description: "",
  setTitle: (title) => set({ title }),
  setRate: (num) => set({ rate: num }),
  setDuration: (num) => set({ duration: num }),
  setDescription: (description) => set({ description }),
}));
