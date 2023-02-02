import { useMeeting, usePubSub } from "@videosdk.live/react-sdk";
import ChatItem from "pages/Room/ChatItem.js";
import ChatIcon from "pages/Room/Icons/ChatIcon.js";
import React, { useEffect, useRef, useState } from "react";
import { useRoomStore } from "stores/room.js";

export default function MobileChat() {
  const ref = useRef();
  const [message, setMessage] = useState("");
  const { publish, messages } = usePubSub("CHAT");
  const { localParticipant } = useMeeting();
  const mobileChatVisible = useRoomStore((state) => state.mobileChatVisible);
  const setMobileChatVisible = useRoomStore(
    (state) => state.setMobileChatVisible
  );
  const setMessageCount = useRoomStore((state) => state.setMessageCount);

  useEffect(() => {
    ref?.current?.scrollTo?.(0, ref?.current?.scrollHeight);
    setMessageCount(messages.length);
  }, [messages]);

  return (
    <div
      className={`fixed top-0 z-[999999] flex h-screen w-screen flex-1 flex-col bg-bg p-5 transition-all ${
        mobileChatVisible ? "right-0" : "-right-[100%]"
      }`}
    >
      <div className="flex w-full items-center justify-between border-b border-primary/50 pb-[10px]">
        <div>Chat</div>
        <img
          className="h-[16px] w-[16px] cursor-pointer"
          src="/assets/close-grey.svg"
          alt=""
          onClick={() => {
            setMobileChatVisible(false);
          }}
        />
      </div>
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
          <ChatIcon
            fillcolor="#dfcefd"
            onClick={() => {
              publish(message);
              setMessage("", { persist: true });
            }}
          />
        </div>
      </form>
    </div>
  );
}
