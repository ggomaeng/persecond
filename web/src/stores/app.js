import { create } from "zustand";

export const useAppStore = create((set) => ({
  walletModalVisible: false,
  setWalletModalVisible: (visible) => set({ walletModalVisible: visible }),
}));
