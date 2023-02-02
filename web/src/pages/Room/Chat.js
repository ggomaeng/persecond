import { useMeeting, usePubSub } from "@videosdk.live/react-sdk";
import ChatItem from "pages/Room/ChatItem.js";
import ChatIcon from "pages/Room/Icons/ChatIcon.js";
import React, { useEffect, useRef, useState } from "react";

export default function Chat() {
  const ref = useRef();
  const [message, setMessage] = useState("");
  const { publish, messages } = usePubSub("CHAT");
  const { localParticipant } = useMeeting();

  useEffect(() => {
    ref?.current?.scrollTo?.(0, ref?.current?.scrollHeight);
  }, [messages]);

  return (
    <div className="flex w-[280px] flex-1 flex-col border border-primary/50 p-5">
      <div className="border-b border-primary/50 pb-[10px]">Chat</div>
      <div
        className="hide-scrollbar flex-[1_1_1px] flex-col overflow-y-scroll py-[20px]"
        ref={ref}
      >
        {messages.map((msg, i) => {
          return (
            <ChatItem
              key={i}
              message={msg.message}
              mine={msg?.senderId === localParticipant?.id}
            />
          );
        })}
      </div>
      <form
        className="flex w-full border border-primary/50 p-4"
        onSubmit={(e) => {
          e.preventDefault();
          // console.log("send", message);
          publish(message);
          setMessage("", { persist: true });
        }}
      >
        <div className="flex w-full items-center justify-between">
          <input
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            className="flex flex-grow bg-transparent outline-none"
            placeholder="Wirte your message"
          />
          <ChatIcon fillcolor="#dfcefd" />
        </div>
      </form>
    </div>
  );
}
