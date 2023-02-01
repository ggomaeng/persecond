import ControlItem from "pages/Room/ControlItem.js";
import ChatIcon from "pages/Room/Icons/ChatIcon.js";
import ClipboardIcon from "pages/Room/Icons/ClipboardIcon.js";
import EndIcon from "pages/Room/Icons/EndIcon.js";
import MicOnIcon from "pages/Room/Icons/MicOnIcon.js";
import ParticipantsIcon from "pages/Room/Icons/ParticipantsIcon.js";
import ScreenShareIcon from "pages/Room/Icons/ScreenShareIcon.js";
import WebcamOnIcon from "pages/Room/Icons/WebcamOnIcon.js";

const { useMeeting } = require("@videosdk.live/react-sdk");

export default function Controls() {
  const { leave, toggleMic, toggleWebcam } = useMeeting();
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
          className="mr-3 px-1"
          onClick={toggleMic}
          icon={<MicOnIcon fillcolor="#dfcefd" />}
          options
        />
        <ControlItem
          className="mr-3 px-1"
          onClick={toggleWebcam}
          icon={<WebcamOnIcon fillcolor="#dfcefd" />}
          options
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
