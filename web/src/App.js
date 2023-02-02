import Router from "./Router.js";

import { AptosWalletAdapterProvider } from "@aptos-labs/wallet-adapter-react";
import Loading from "components/Loading.js";
import { WALLETS } from "constants/wallets.js";
import { Toaster } from "react-hot-toast";

function App() {
  return (
    <AptosWalletAdapterProvider plugins={WALLETS} autoConnect>
      <>
        <Router />
        <Loading />
        <div id="portal" />
        <Toaster />
      </>
    </AptosWalletAdapterProvider>
  );
}

export default App;
