import { useWallet } from "@aptos-labs/wallet-adapter-react";
import ControlItem from "pages/Room/ControlItem.js";
import ChatIcon from "pages/Room/Icons/ChatIcon.js";
import EndIcon from "pages/Room/Icons/EndIcon.js";
import MicOnIcon from "pages/Room/Icons/MicOnIcon.js";
import WebcamOnIcon from "pages/Room/Icons/WebcamOnIcon.js";
import { useState } from "react";
import { toast } from "react-hot-toast";
import { useParams } from "react-router-dom";
import { useRoomStore } from "stores/room.js";
import { aptosClient, CONTRACT_ADDRESS } from "utils/aptos.js";
import { toastError } from "utils/toasts.js";

const { useMeeting, usePubSub } = require("@videosdk.live/react-sdk");

export default function Controls() {
  const { wallet } = useParams();
  const { network, signAndSubmitTransaction } = useWallet();
  const { publish } = usePubSub("TRANSACTION_END");
  const [closing, setClosing] = useState(false);
  const [mics, setMics] = useState([]);
  const [cams, setCams] = useState([]);
  const {
    localParticipant,
    localMicOn,
    localWebcamOn,
    localScreenShareOn,
    leave,
    toggleMic,
    toggleWebcam,
    changeWebcam,
    changeMic,
    toggleScreenShare,
    getWebcams,

    getMics,
  } = useMeeting({
    onMeetingJoined,
  });

  const setMobileChatVisible = useRoomStore(
    (state) => state.setMobileChatVisible
  );
  const messageCount = useRoomStore((state) => state.messageCount);

  async function onMeetingJoined() {
    try {
      const mics = await getMics();
      const cams = await getWebcams();
      setMics(mics);
      setCams(cams);
    } catch (e) {
      console.error(e);
    }
  }

  const activeDeviceIds =
    localParticipant?.streams &&
    [...localParticipant?.streams?.values?.()].map(
      (item) => item?.track?.label
    );

  return (
    <div className="flex w-screen justify-between p-[20px] backdrop-blur-sm tablet:p-[40px]">
      <div className="flex flex-grow" />

      <div className="flex flex-grow justify-center">
        <ControlItem
          id="mic"
          className="mr-3 px-1"
          onClick={toggleMic}
          icon={<MicOnIcon fillcolor={localMicOn ? "#dfcefd" : "#453f50"} />}
          options={mics}
          activeOptions={activeDeviceIds}
          onOptionClick={(option) => changeMic(option)}
        />
        <ControlItem
          id="cam"
          className="mr-3 px-1"
          onClick={toggleWebcam}
          icon={
            <WebcamOnIcon fillcolor={localWebcamOn ? "#dfcefd" : "#453f50"} />
          }
          options={cams}
          activeOptions={activeDeviceIds}
          onOptionClick={(option) => changeWebcam(option)}
        />
        {/* <ControlItem
          className="mr-3"
          onClick={toggleScreenShare}
          icon={
            <ScreenShareIcon
              fillcolor={localScreenShareOn ? "#dfcefd" : "#453f50"}
            />
          }
        /> */}
        <ControlItem
          className="border-red-500 bg-red-500"
          icon={<EndIcon fillcolor="white" />}
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
        />
      </div>

      <div className="flex flex-grow justify-end">
        <div className="relative">
          {messageCount > 0 && (
            <div className="absolute right-[-12px] top-[-12px] flex h-[24px] w-[24px] items-center justify-center rounded-full bg-red-500 text-xs tablet:hidden">
              {messageCount}
            </div>
          )}
          <ControlItem
            className="flex tablet:hidden"
            icon={<ChatIcon fillcolor="#dfcefd" />}
            onClick={() => {
              setMobileChatVisible(true);
            }}
          />
        </div>
        {/* <ControlItem
          className="ml-3"
          icon={<ParticipantsIcon fillcolor="#dfcefd" />}
        /> */}
      </div>
    </div>
  );
}
