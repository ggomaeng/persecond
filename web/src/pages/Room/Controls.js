import ControlItem from "pages/Room/ControlItem.js";
import ChatIcon from "pages/Room/Icons/ChatIcon.js";
import ClipboardIcon from "pages/Room/Icons/ClipboardIcon.js";
import EndIcon from "pages/Room/Icons/EndIcon.js";
import MicOnIcon from "pages/Room/Icons/MicOnIcon.js";
import ParticipantsIcon from "pages/Room/Icons/ParticipantsIcon.js";
import ScreenShareIcon from "pages/Room/Icons/ScreenShareIcon.js";
import WebcamOnIcon from "pages/Room/Icons/WebcamOnIcon.js";
import { useState } from "react";

const { useMeeting } = require("@videosdk.live/react-sdk");

export default function Controls() {
  const [mics, setMics] = useState([]);
  const [cams, setCams] = useState([]);
  const {
    localParticipant,
    localMicOn,
    localWebcamOn,
    leave,
    toggleMic,
    toggleWebcam,
    changeWebcam,
    changeMic,
    getWebcams,
    getMics,
  } = useMeeting({
    onMeetingJoined,
  });

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
    <div className="fixed bottom-0 flex w-screen justify-between p-[20px]">
      <div>
        <ControlItem
          className="px-3"
          onClick={leave}
          icon={<ClipboardIcon fillcolor="#dfcefd" />}
        >
          <span className="mr-1">Share Link</span>
        </ControlItem>
      </div>
      <div className="flex">
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
        <ControlItem
          className="mr-3"
          onClick={leave}
          icon={<ScreenShareIcon fillcolor="#dfcefd" />}
        />
        <ControlItem
          className="border-red-500 bg-red-500"
          onClick={leave}
          icon={<EndIcon fillcolor="white" />}
        />
      </div>
      <div className="flex">
        <ControlItem onClick={leave} icon={<ChatIcon fillcolor="#dfcefd" />} />
        <ControlItem
          className="ml-3"
          onClick={leave}
          icon={<ParticipantsIcon fillcolor="#dfcefd" />}
        />
      </div>
    </div>
  );
}
