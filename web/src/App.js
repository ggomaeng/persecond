import { AptosWalletAdapterProvider } from "@aptos-labs/wallet-adapter-react";
import Loading from "components/Loading.js";
import { WALLETS } from "constants/wallets.js";
import { Toaster } from "react-hot-toast";
import { Outlet } from "react-router-dom";

function App() {
  return (
    <AptosWalletAdapterProvider plugins={WALLETS} autoConnect>
      <>
        <Outlet />
        <Loading />
        <div id="portal" />
        <Toaster />
      </>
    </AptosWalletAdapterProvider>
  );
}

export default App;
