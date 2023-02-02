import { useMeeting } from "@videosdk.live/react-sdk";
import { take } from "lodash";
import Invite from "pages/Room/Invite.js";
import VideoComponent from "pages/Room/VideoComponent.js";
import React, { useEffect, useState } from "react";
import { useAppStore } from "stores/app.js";
import { toastError } from "utils/toasts.js";

export default function Videos(props) {
  const setFullLoading = useAppStore((state) => state.setFullLoading);
  const [joined, setJoined] = useState(false);
  const { join, participants, leave } = useMeeting({
    onError: (e) => {
      toastError(e);
    },
    onMeetingJoined: () => {
      console.log("Meeting Joined");
      setFullLoading(false);
      setJoined(true);
    },
  });

  useEffect(() => {
    return () => leave?.();
  }, []);

  useEffect(() => {
    //TODO - add logic to check data with aptos blockchain and then join automatically if valid
    console.log("joined", joined);
    if (!joined) {
      console.log("joining");
      joinMeeting();
    }
  }, [joined]);

  const joinMeeting = async () => {
    setFullLoading(true);
    try {
      await join();
    } catch (e) {
      toastError(e);
      setFullLoading(false);
    }
  };

  if (!joined) return null;

  return (
    <div className="relative flex h-full flex-grow flex-wrap gap-[20px]">
      {take([...participants.values()], 2).map(({ id, displayName }) => (
        <VideoComponent
          displayName={displayName}
          key={id}
          participantId={id}
          size={participants?.size}
        />
      ))}
      {participants.size === 1 && <Invite />}
    </div>
  );
}
