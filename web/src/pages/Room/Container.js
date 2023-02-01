import { useMeeting } from "@videosdk.live/react-sdk";
import Controls from "pages/Room/Controls.js";
import VideoComponent from "pages/Room/VideoComponent.js";
import React, { useState } from "react";

export default function Container(props) {
  const [joined, setJoined] = useState(false);
  const { join, participants } = useMeeting();

  const joinMeeting = () => {
    setJoined(true);
    join();
  };

  return (
    <div className="container">
      <h3 className="text-white">Meeting Id: {props.meetingId}</h3>
      {joined ? (
        <div>
          <Controls />
          {[...participants.keys()].map((participantId) => (
            <VideoComponent participantId={participantId} />
          ))}
        </div>
      ) : (
        <button onClick={joinMeeting}>Join</button>
      )}
    </div>
  );
}
