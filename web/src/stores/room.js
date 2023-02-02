import { create } from "zustand";

export const useRoomStore = create((set) => ({
  session: {},
  setSession: (session) => set({ session }),
  activeOption: null,
  setActiveOption: (option) => set({ activeOption: option }),
  canStart: false,
  setCanStart: (canStart) => set({ canStart }),
}));
