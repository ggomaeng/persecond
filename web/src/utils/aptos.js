import { AptosClient } from "aptos";

export const CONTRACT_ADDRESS =
  "0xe53f73c034591efbd8c4d4e469f7bcbf03426bff3f5267a38a0837d2899f896c::per_second_v8";

// Create an AptosClient to interact with devnet.
export const aptosClient = new AptosClient(
  "https://fullnode.devnet.aptoslabs.com/v1"
);

export async function getSession(address) {
  try {
    const { data } = await aptosClient.getAccountResource(
      address,
      `${CONTRACT_ADDRESS}::Session<0x1::aptos_coin::AptosCoin>`
    );
    return data;
  } catch (e) {
    console.error(e);
    return null;
  }
}
