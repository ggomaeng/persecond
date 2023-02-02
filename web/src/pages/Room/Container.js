import { useMeeting } from "@videosdk.live/react-sdk";
import VideoComponent from "pages/Room/VideoComponent.js";
import React, { useState } from "react";

export default function Container(props) {
  const [joined, setJoined] = useState(false);
  const { join, participants } = useMeeting();

  console.log(participants);

  const joinMeeting = () => {
    setJoined(true);
    join();
  };

  return joined ? (
    <div>
      {[...participants.keys()].map((participantId) => (
        <VideoComponent key={participantId} participantId={participantId} />
      ))}
    </div>
  ) : (
    <button onClick={joinMeeting}>Join</button>
  );
}
