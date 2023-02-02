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
    <div className="flex h-[80px] w-screen items-center justify-between px-[20px] backdrop-blur-sm tablet:h-[120px] tablet:px-[40px]">
      <div className="flex items-center">
        <img
          className="mr-[20px] h-[40px] w-[40px]"
          src="/assets/logo-single@2x.png"
          alt="logo"
        />
        <ConnectWalletButton className="hidden tablet:flex" />
        {/* <div className="ml-[20px] text-[22px]">Some cool room title</div> */}
      </div>
      {/* {session?.started_at === "0" ? (
        <Button
          loading={starting}
          onClick={async () => {
            if (network?.name !== "Testnet") {
              toast("Please switch your network to Testnet", {
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
      <ConnectWalletButton className="flex tablet:hidden" />
      <Button
        containerClassName={"hidden tablet:block"}
        loading={closing}
        onClick={async () => {
          if (network?.name !== "Testnet") {
            toast("Please switch your network to Testnet", {
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
