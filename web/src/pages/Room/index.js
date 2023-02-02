import React, { useEffect } from "react";

import {
  MeetingProvider,
  MeetingConsumer,
  useMeeting,
  useParticipant,
} from "@videosdk.live/react-sdk";
import { useParams } from "react-router-dom";
import { api } from "utils/api.js";
import Container from "pages/Room/Container.js";
import Chat from "pages/Room/Chat.js";
import Controls from "pages/Room/Controls.js";
import HostVideo from "pages/Room/HostVideo.js";
import RoomHeader from "pages/Room/RoomHeader.js";
import Participants from "pages/Room/Participants.js";

export default function Room() {
  const { roomId } = useParams();

  useEffect(() => {
    // async function checkRoom() {
    //   const result = await api.get(`${roomId}`).json();
    //   console.log(result);
    // }
    // if (roomId) checkRoom();
  }, [roomId]);

  if (!roomId) return null;

  return (
    <MeetingProvider
      config={{
        meetingId: roomId,
        micEnabled: true,
        webcamEnabled: true,
        name: "C.V. Raman",
      }}
      token={process.env.REACT_APP_VIDEOSDK_TOKEN}
    >
      <MeetingConsumer>
        {() => (
          <div className="text-white">
            <RoomHeader />
            <div className="flex justify-between gap-[20px] px-[40px]">
              <div className="flex flex-grow flex-col">
                <HostVideo />
                <Participants />
              </div>
              <Chat />
            </div>
            {/* <Container meetingId={roomId} /> */}
            <Controls />
          </div>
        )}
      </MeetingConsumer>
    </MeetingProvider>
  );
}
