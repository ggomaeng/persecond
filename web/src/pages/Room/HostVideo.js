import Invite from "pages/Room/Invite.js";
import React from "react";

export default function HostVideo() {
  return (
    <div className="relative flex h-[70vh] flex-grow flex-wrap gap-[20px] mobile:aspect-video mobile:h-auto fullscreen:aspect-auto fullscreen:h-[70vh]">
      <div
        className={`relative flex h-full w-full flex-grow flex-col items-center justify-center border border-primary/50 mobile:w-[calc(50%-10px)]`}
      />
      <Invite />
    </div>
  );
}
