import { create } from "zustand";

export const useRoomStore = create((set) => ({
  messageCount: 0,
  setMessageCount: (count) => set({ messageCount: count }),
  mobileChatVisible: false,
  setMobileChatVisible: (visible) => set({ mobileChatVisible: visible }),
  session: {},
  setSession: (session) => set({ session }),
  activeOption: null,
  setActiveOption: (option) => set({ activeOption: option }),
  canStart: false,
  setCanStart: (canStart) => set({ canStart }),
}));
