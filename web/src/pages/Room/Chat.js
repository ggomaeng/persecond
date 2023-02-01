import React from "react";

export default function Chat() {
  return (
    <div className="flex min-h-[300px] max-w-[280px] flex-grow flex-col border border-[#2a1636] p-5">
      <div className="border-b border-[#2a1636] pb-[10px]">Chat</div>
      <div className="chat-container flex flex-grow flex-col"></div>
      <form className="flex w-full border border-[#2a1636] p-4">
        <input
          className="flex flex-grow bg-transparent outline-none"
          placeholder="Wirte your message"
        />
      </form>
    </div>
  );
}
