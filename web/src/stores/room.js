import { create } from "zustand";

export const useRoomStore = create((set) => ({
  activeOption: null,
  setActiveOption: (option) => set({ activeOption: option }),
  started: false,
}));
