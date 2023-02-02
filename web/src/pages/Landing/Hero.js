import ConnectWalletButton from "components/ConnectWalletButton.js";
import TestBalance from "components/TestBalance.js";
import AnimatedNumbers from "react-animated-numbers";
import { fixDecimalPlaces } from "utils/numbers";
import Counter from "components/Counter";
import React, { useEffect, useState } from "react";
import LineBG from "./LineBG.js";

export default function Hero() {
  const [num, setNum] = useState(0);

  useEffect(() => {
    setTimeout(() => {
      const interval = setInterval(() => {
        setNum((prev) => prev + 0.13);
      }, 1000);
      return () => clearInterval(interval);
    }, 3500);
  }, []);

  return (
    <div className="relative h-screen">
      <div className="absolute left-0 top-0 z-0 h-full w-full overflow-hidden">
        <LineBG />
      </div>
      <div className="pointer-events-none relative z-[1] flex h-full w-full flex-col items-center pt-[200px] mobile:pt-[250px]">
        <img
          className="h-auto w-[240px]"
          src="/assets/logo-full-white@2x.png"
          alt=""
        />
        {/* <ConnectWalletButton /> */}
        {/* <TestBalance /> */}
        <div className="mt-[60px] text-center text-3xl font-bold text-primary mobile:text-[60px] mobile:leading-[72px]">
          <div>Ask for resource,</div>
          <div>pay by the second</div>
          <div className="mt-[10px] text-[24px] font-normal">
            on Aptos Blockchain
          </div>
        </div>
      </div>
      <div className="absolute bottom-[13%] left-1/2 flex -translate-x-1/2 flex-col items-center justify-center text-center text-primary mobile:bottom-[3%]">
        <div className="text-4xl font-bold text-dark-purple mobile:text-6xl">
          <Counter delay={3500} />
        </div>
        <div className="mt-2 flex justify-center text-2xl font-bold">
          <div>$</div>
          <AnimatedNumbers
            includeComma
            animateToNumber={fixDecimalPlaces(num, 2)}
          ></AnimatedNumbers>
          <div className="ml-1">paid</div>
        </div>
      </div>
    </div>
  );
}
