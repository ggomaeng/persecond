import ControlItem from "pages/Room/ControlItem.js";
import ChatIcon from "pages/Room/Icons/ChatIcon.js";
import ClipboardIcon from "pages/Room/Icons/ClipboardIcon.js";
import EndIcon from "pages/Room/Icons/EndIcon.js";
import MicOnIcon from "pages/Room/Icons/MicOnIcon.js";
import ParticipantsIcon from "pages/Room/Icons/ParticipantsIcon.js";
import ScreenShareIcon from "pages/Room/Icons/ScreenShareIcon.js";
import WebcamOnIcon from "pages/Room/Icons/WebcamOnIcon.js";
import { useState } from "react";
import { useRoomStore } from "stores/room.js";

const { useMeeting } = require("@videosdk.live/react-sdk");

export default function Controls() {
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
          onClick={leave}
          icon={<EndIcon fillcolor="white" />}
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
