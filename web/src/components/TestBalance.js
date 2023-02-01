import { useWallet } from "@aptos-labs/wallet-adapter-react";
import React, { useEffect } from "react";
import { aptosClient } from "utils/aptos.js";

export default function TestBalance() {
  const { account } = useWallet();

  console.log(account);

  useEffect(() => {
    async function get() {
      const bal = await aptosClient.getAccountResources(account.address);
      const bal2 = await aptosClient.getAccountResource(
        account.address,
        "0x1::coin::CoinStore<0xaf456058b85b52bc8c9f5c04c40df95a7375adcafdc2d30c5af9648894851016::faucet::USDC>"
      );
      console.log(bal, bal2);
    }
    if (account) {
      get();
    }
  }, [account]);

  return <div>TestBalance</div>;
}
