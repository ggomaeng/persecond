import Router from "./Router.js";

import { AptosWalletAdapterProvider } from "@aptos-labs/wallet-adapter-react";
import { WALLETS } from "constants/wallets.js";

function App() {
  return (
    <AptosWalletAdapterProvider plugins={WALLETS} autoConnect>
      <>
        <Router />
        <div id="portal" />
      </>
    </AptosWalletAdapterProvider>
  );
}

export default App;
