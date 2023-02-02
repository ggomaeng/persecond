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

  // if (!roomId) return null;

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
          <div className="relative flex h-screen flex-col text-white ">
            <RoomHeader />

            <div className="flex flex-1 flex-col justify-between gap-[20px] tablet:flex-row tablet:px-[40px]">
              <div className="hide-scrollbar flex h-[70vh] flex-grow flex-col">
                <Videos />
                {/* <HostVideo /> */}
                {/* <Participants /> */}
              </div>

              <div className="flex max-w-full flex-col gap-[20px] fullscreen:max-w-[280px]">
                <SessionBoard />
                <div className="hidden h-full fullscreen:flex">
                  <Chat />
                </div>
              </div>
            </div>
            <Controls />
            {/* <Container meetingId={roomId} /> */}
          </div>
        )}
      </MeetingConsumer>
    </MeetingProvider>
  );
}
