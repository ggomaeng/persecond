import React, { useEffect, useState } from "react";

import {
  MeetingProvider,
  MeetingConsumer,
  useMeeting,
  useParticipant,
} from "@videosdk.live/react-sdk";
import { useParams } from "react-router-dom";
import { api, serverApi } from "utils/api.js";
import Videos from "pages/Room/Videos.js";
import Chat from "pages/Room/Chat.js";
import Controls from "pages/Room/Controls.js";
import HostVideo from "pages/Room/HostVideo.js";
import RoomHeader from "pages/Room/RoomHeader.js";
import Participants from "pages/Room/Participants.js";
import SessionBoard from "pages/Room/SessionBoard.js";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import MobileSessionBoard from "pages/Room/MobileSessionBoard.js";
import MobileChat from "pages/Room/MobileChat.js";

export default function Room() {
  const { roomId } = useParams();
  const { account } = useWallet();
  // const [token, setToken] = useState(null);

  // console.log(account);

  // useEffect(() => {
  //   async function checkRoom() {
  //     const { token } = await serverApi.get(`get-token`).json();
  //     setToken(token);
  //   }
  //   checkRoom();
  // }, [roomId]);

  if (!roomId) return null;

  return (
    <MeetingProvider
      config={{
        meetingId: roomId,
        micEnabled: true,
        webcamEnabled: true,
        name: account?.address || "Guest",
        quality: "high",
      }}
      token={process.env.REACT_APP_VIDEOSDK_TOKEN}

      // token={token}
    >
      <MeetingConsumer>
        {() => (
          <div className="relative flex h-screen flex-col text-white">
            <RoomHeader />

            <div className="flex flex-1 flex-col items-center justify-center px-[20px] tablet:flex-row tablet:items-stretch tablet:justify-between tablet:gap-[20px] tablet:px-[40px]">
              <div className="hide-scrollbar flex w-full flex-grow flex-col">
                <Videos />
                {/* <HostVideo /> */}
                {/* <Participants /> */}
              </div>

              <div className="hidden h-full max-w-[280px] flex-col gap-[20px] tablet:flex">
                <SessionBoard />
                <Chat />
              </div>

              <div className="flex w-full flex-col tablet:hidden">
                <MobileSessionBoard />
                <MobileChat />
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
