import Button from "components/Button.js";
import React from "react";

export default function RoomHeader() {
  return (
    <div className="fixed top-0 left-0 flex h-[120px] w-full items-center justify-between px-[40px] backdrop-blur-sm">
      <div className="flex items-center">
        <img
          className="h-[40px] w-[40px]"
          src="/assets/logo-single@2x.png"
          alt="logo"
        />
        <div className="ml-[20px] text-[22px]">Some cool room title</div>
      </div>
      <Button>Finish the session</Button>
    </div>
  );
}
