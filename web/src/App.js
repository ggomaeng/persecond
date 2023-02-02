import Router from "./Router.js";

import { AptosWalletAdapterProvider } from "@aptos-labs/wallet-adapter-react";
import { WALLETS } from "constants/wallets.js";
import Loading from "components/Loading.js";

function App() {
  return (
    <AptosWalletAdapterProvider plugins={WALLETS} autoConnect>
      <>
        <Router />
        <Loading />
        <div id="portal" />
      </>
    </AptosWalletAdapterProvider>
  );
}

export default App;
