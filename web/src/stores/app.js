import { create } from "zustand";

export const useAppStore = create((set) => ({
  fullLoading: false,
  walletModalVisible: false,
  setWalletModalVisible: (visible) => set({ walletModalVisible: visible }),
  setFullLoading: (loading) => set({ fullLoading: loading }),
}));
