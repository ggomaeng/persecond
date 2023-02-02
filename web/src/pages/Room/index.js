import React, { useEffect } from "react";

import {
  MeetingProvider,
  MeetingConsumer,
  useMeeting,
  useParticipant,
} from "@videosdk.live/react-sdk";
import { useParams } from "react-router-dom";
import { api } from "utils/api.js";
import Videos from "pages/Room/Videos.js";
import Chat from "pages/Room/Chat.js";
import Controls from "pages/Room/Controls.js";
import HostVideo from "pages/Room/HostVideo.js";
import RoomHeader from "pages/Room/RoomHeader.js";
import Participants from "pages/Room/Participants.js";
import SessionBoard from "pages/Room/SessionBoard.js";
import { useWallet } from "@aptos-labs/wallet-adapter-react";

export default function Room() {
  const { roomId } = useParams();
  const { account } = useWallet();

  console.log(account);

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
        name: account?.address || "Guest",
      }}
      token={process.env.REACT_APP_VIDEOSDK_TOKEN}
    >
      <MeetingConsumer>
        {() => (
          <div className="relative text-white">
            <RoomHeader />

            <div className="flex flex-grow justify-between gap-[20px] px-[40px] py-[120px]">
              <div className="hide-scrollbar flex max-w-[calc(100vw-380px)] flex-grow flex-col">
                <Videos />
                {/* <HostVideo /> */}
                {/* <Participants /> */}
              </div>

              <div className="fixed right-[40px] top-[120px] flex h-full max-h-[calc(100vh-240px)] w-[280px] flex-grow flex-col gap-[20px]">
                <SessionBoard />
                <Chat />
              </div>
            </div>
            {/* <Container meetingId={roomId} /> */}
            <Controls />
          </div>
        )}
      </MeetingConsumer>
    </MeetingProvider>
  );
}
