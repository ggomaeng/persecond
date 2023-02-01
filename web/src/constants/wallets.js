import { MartianWallet } from "@martianwallet/aptos-wallet-adapter";
import { PontemWallet } from "@pontem/wallet-adapter-plugin";
import { RiseWallet } from "@rise-wallet/wallet-adapter";
// import { SpikaWallet } from "@spika/aptos-plugin";
import { TrustWallet } from "@trustwallet/aptos-wallet-adapter";
import { FewchaWallet } from "fewcha-plugin-wallet-adapter";
import { MSafeWalletAdapter } from "msafe-plugin-wallet-adapter";
import { PetraWallet } from "petra-plugin-wallet-adapter";

export const WALLETS = [
  new PetraWallet(),
  new MSafeWalletAdapter(),
  new RiseWallet(),
  new TrustWallet(),
  new PontemWallet(),
  new MartianWallet(),
  // new SpikaWallet(),
  new FewchaWallet(),
  // new BloctoWallet(),
];
