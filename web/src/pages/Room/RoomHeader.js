import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { usePubSub } from "@videosdk.live/react-sdk";
import Button from "components/Button.js";
import ConnectWalletButton from "components/ConnectWalletButton.js";
import React, { useEffect, useState } from "react";
import { toast } from "react-hot-toast";
import { useNavigate, useParams } from "react-router-dom";
import { aptosClient, CONTRACT_ADDRESS } from "utils/aptos.js";
import { toastError } from "utils/toasts.js";

export default function RoomHeader() {
  const { wallet } = useParams();
  const { network, signAndSubmitTransaction } = useWallet();
  const { publish, messages } = usePubSub("TRANSACTION_END");
  const navigate = useNavigate();
  const [closing, setClosing] = useState(false);

  useEffect(() => {
    if (messages.length > 0) {
      console.log(messages);
      navigate(`/result/${messages?.[0]}`);
    }
  }, [messages]);

  return (
    <div className="flex h-[120px] w-full items-center justify-between px-[40px] backdrop-blur-sm">
      <div className="flex items-center">
        <img
          className="mr-[20px] h-[40px] w-[40px]"
          src="/assets/logo-single@2x.png"
          alt="logo"
        />
        {/* <div className="ml-[20px] text-[22px]">Some cool room title</div> */}
        <ConnectWalletButton />
      </div>
      <Button
        loading={closing}
        onClick={async () => {
          if (network?.name !== "Devnet") {
            toast("Please switch your network to Devnet");
            return;
          }
          setClosing(true);

          try {
            const payload = {
              type: "entry_function_payload",
              function: `${CONTRACT_ADDRESS}::close_session`,
              type_arguments: ["0x1::aptos_coin::AptosCoin"],
              arguments: [wallet], // 1 is in Octas
            };
            const response = await signAndSubmitTransaction(payload);
            // if you want to wait for transaction
            await aptosClient.waitForTransaction(response?.hash || "");
            navigate(`/result/${wallet}`);
            await publish(response.hash);
            console.log(response, response?.hash);
          } catch (error) {
            toastError(error);
          } finally {
            setClosing(false);
          }
        }}
      >
        Finish the session
      </Button>
    </div>
  );
}
