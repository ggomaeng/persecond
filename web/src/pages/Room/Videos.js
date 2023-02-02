import { useMeeting } from "@videosdk.live/react-sdk";
import { take } from "lodash";
import Invite from "pages/Room/Invite.js";
import VideoComponent from "pages/Room/VideoComponent.js";
import React, { useEffect, useState } from "react";
import { toast } from "react-hot-toast";
import { useNavigate, useParams } from "react-router-dom";
import { useAppStore } from "stores/app.js";
import { useRoomStore } from "stores/room.js";
import { getSession } from "utils/aptos.js";
import { toastError } from "utils/toasts.js";

export default function Videos(props) {
  const { roomId, wallet } = useParams();
  const setFullLoading = useAppStore((state) => state.setFullLoading);
  const setCanStart = useRoomStore((state) => state.setCanStart);
  const setSession = useRoomStore((state) => state.setSession);
  const navigate = useNavigate();
  const [joined, setJoined] = useState(false);
  const { join, participants, leave } = useMeeting({
    onConnectionOpen: (e) => {
      console.log("connection open", e);
    },
    onMeetingStateChanged: (e) => {
      console.log("meeting state changed", e);
    },
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
    return () => {
      leave?.();
      console.log("unmount, leaving");
    };
  }, []);

  useEffect(() => {
    let interval;
    async function checkSigned() {
      try {
        const session = await getSession(wallet);
        const { started_at } = session;
        console.log(session);
        setSession(session);
        if (started_at !== "0" && participants.size >= 2) {
          toast.success("Session started");
          setCanStart(true);
          clearInterval(interval);
        }
      } catch (e) {
        toastError(e);
      }
    }

    console.log(participants.size);
    checkSigned();
    interval = setInterval(checkSigned, 2000);

    return () => interval && clearInterval(interval);
  }, [participants]);

  useEffect(() => {
    //TODO - add logic to check data with aptos blockchain and then join automatically if valid
    console.log("joined", joined);
    if (!joined) {
      console.log("joining");
      setFullLoading(true);
      setTimeout(() => joinMeeting(), 1500);
    }
  }, [joined]);

  const joinMeeting = async () => {
    setFullLoading(true);
    try {
      const session = await getSession(wallet);
      if (session.finished_at !== "0") {
        setFullLoading(false);
        toast.error("This session has been finished", { icon: "⏰" });
        navigate("/");
        return;
      } else if (session.room_id !== roomId) {
        setFullLoading(false);
        toast.error("This link is not valid", { icon: "🔗" });
        navigate("/");
      }
      setSession(session);
      await join();
    } catch (e) {
      toastError(e);
      setFullLoading(false);
    }
  };

  return (
    <div className="relative flex h-full flex-grow flex-wrap tablet:gap-[20px]">
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
