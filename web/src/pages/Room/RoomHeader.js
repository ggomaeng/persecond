import Button from "components/Button.js";
import React from "react";

export default function RoomHeader() {
  return (
    <div className="flex w-full items-center justify-between p-[40px]">
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
