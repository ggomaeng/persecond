import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { usePubSub } from "@videosdk.live/react-sdk";
import Button from "components/Button.js";
import ConnectWalletButton from "components/ConnectWalletButton.js";
import React, { useEffect, useState } from "react";
import { toast } from "react-hot-toast";
import { useNavigate, useParams } from "react-router-dom";
import { useRoomStore } from "stores/room.js";
import { aptosClient, CONTRACT_ADDRESS } from "utils/aptos.js";
import { toastError } from "utils/toasts.js";

export default function RoomHeader() {
  const { wallet } = useParams();
  const { network, signAndSubmitTransaction } = useWallet();
  const { publish, messages } = usePubSub("TRANSACTION_END");
  const [starting, setStarting] = useState(false);
  const session = useRoomStore((state) => state.session);
  const navigate = useNavigate();
  const [closing, setClosing] = useState(false);

  useEffect(() => {
    if (messages.length > 0) {
      console.log(messages);
      navigate(`/result/${messages?.[0]?.message}`);
    }
  }, [messages]);

  return (
    <div className="flex h-[80px] w-full items-center justify-between px-5 backdrop-blur-sm tablet:h-[120px] tablet:px-[40px]">
      <div className="flex w-full justify-between tablet:items-center">
        <img
          className="mr-2 h-[40px] w-[40px] tablet:mr-[20px]"
          src="/assets/logo-single@2x.png"
          alt="logo"
        />
        {/* <div className="ml-[20px] text-[22px]">Some cool room title</div> */}
        <ConnectWalletButton />
      </div>
      {/* {session?.started_at === "0" ? (
        <Button
          loading={starting}
          className="hidden tablet:flex"
          onClick={async () => {
            if (network?.name !== "Devnet") {
              toast("Please switch your network to Devnet", {
                icon: "⚠️",
              });
              return;
            }
            try {
              setStarting(true);
              const payload = {
                type: "entry_function_payload",
                function: `${CONTRACT_ADDRESS}::start_session`,
                type_arguments: ["0x1::aptos_coin::AptosCoin"],
                arguments: [], // 1 is in Octas
              };

              const response = await signAndSubmitTransaction(payload);
              // if you want to wait for transaction
              await aptosClient.waitForTransaction(response?.hash || "");
              console.log(response, response?.hash);
            } catch (error) {
              console.log("error", error);
            } finally {
              setStarting(false);
            }
            // const result = await api.post("").json();
            // const { wallet, id } = result;
            // navigate(`/rooms/${wallet}`);
            // console.log(result);
          }}
        >
          Start Session
        </Button>
      ) : ( */}
      <Button
        loading={closing}
        onClick={async () => {
          if (network?.name !== "Devnet") {
            toast("Please switch your network to Devnet", {
              icon: "⚠️",
            });
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
            await publish(response.hash);
            console.log(response, response?.hash);
          } catch (error) {
            toastError(error);
          } finally {
            setClosing(false);
          }
        }}
      >
        Finish Session
      </Button>
      {/* )} */}
    </div>
  );
}
