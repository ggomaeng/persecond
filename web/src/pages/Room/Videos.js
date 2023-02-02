import { useMeeting } from "@videosdk.live/react-sdk";
import VideoComponent from "pages/Room/VideoComponent.js";
import React, { useEffect, useState } from "react";

export default function Videos(props) {
  const [joined, setJoined] = useState(false);
  const { join, participants } = useMeeting();

  useEffect(() => {
    //TODO - add logic to check data with aptos blockchain and then join automatically if valid
  }, []);

  const joinMeeting = () => {
    setJoined(true);
    join();
  };

  return joined ? (
    <div className="relative flex h-[420px] flex-grow flex-wrap gap-[20px]">
      {[...participants.values()].map(({ id, displayName }) => (
        <VideoComponent
          displayName={displayName}
          key={id}
          participantId={id}
          size={participants?.size}
        />
      ))}
    </div>
  ) : (
    <button onClick={joinMeeting}>Join</button>
  );
}
