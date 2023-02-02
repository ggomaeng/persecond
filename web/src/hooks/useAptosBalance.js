import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { formatUnits } from "ethers/lib/utils.js";
import { useEffect, useState } from "react";
import { aptosClient } from "utils/aptos.js";

export default function useAptosBalance() {
  const [balance, setBalance] = useState(0);
  const { account } = useWallet();
  async function getBalance() {
    try {
      // const bal = await aptosClient.getAccountResources(account.address);
      const {
        data: {
          coin: { value },
        },
      } = await aptosClient.getAccountResource(
        account.address,
        "0x1::coin::CoinStore<0x1::aptos_coin::AptosCoin>"
      );
      const formatted = formatUnits(value, 8);
      console.log(value, formatted);
      setBalance(formatted);
    } catch (e) {
      console.error(e);
    }
  }

  useEffect(() => {
    if (account) {
      getBalance();
    }
  }, [account]);

  return { balance };
}
