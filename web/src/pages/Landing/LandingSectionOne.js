import ConnectWalletButton from "components/ConnectWalletButton.js";
import TestBalance from "components/TestBalance.js";
import React from "react";
import LineBG from "./LineBG.js";

export default function LandingSectionOne() {
  return (
    <div className="relative h-screen">
      <div className="absolute left-0 top-0 z-0 h-full w-full overflow-hidden">
        <LineBG />
      </div>
      <div className="absolute bottom-0 z-10 h-[50%] w-full bg-gradient-to-b from-transparent to-bg mobile:h-[70px]" />
      <div className="pointer-events-none relative z-[1] flex h-full w-full flex-col items-center pt-[180px]">
        <img
          className="h-auto w-[240px]"
          src="/assets/logo-full-white@2x.png"
          alt=""
        />
        {/* <ConnectWalletButton /> */}
        {/* <TestBalance /> */}
        <div className="mt-[80px] text-center text-3xl font-bold text-primary mobile:text-[60px] mobile:leading-[72px]">
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
