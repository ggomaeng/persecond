import { AptosClient } from "aptos";

// Create an AptosClient to interact with devnet.
export const aptosClient = new AptosClient(
  "https://fullnode.devnet.aptoslabs.com/v1"
);
