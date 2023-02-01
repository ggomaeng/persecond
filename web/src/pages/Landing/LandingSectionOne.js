import ConnectWalletButton from "components/ConnectWalletButton.js";
import React from "react";
import LineBG from "./LineBG.js";

export default function LandingSectionOne() {
  return (
    <div className="relative h-screen">
      <div className="absolute left-0 top-0 z-0 h-full w-full overflow-hidden">
        <LineBG />
      </div>
      <div className="pointer-events-none relative z-[1] flex h-full w-full flex-col items-center pt-[180px]">
        <img
          className="h-auto w-[240px]"
          src="/assets/logo-full-white@2x.png"
          alt=""
        />
        <ConnectWalletButton />
        <div className="mt-[80px] text-center text-[60px] font-bold text-primary">
          <div>Connect in seconds,</div>
          <div>get paid by seconds</div>
          <div className="mt-[20px] text-[24px] font-normal">
            on Aptos Blockchain
          </div>
        </div>
      </div>
    </div>
  );
}
