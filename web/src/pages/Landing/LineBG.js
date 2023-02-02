import React, { useEffect, useState } from "react";
import { twMerge } from "tailwind-merge";

export default function LineBG() {
  const [animationDone, setAnimationDone] = useState(false);
  const [tick, setTick] = useState(0);

  useEffect(() => {
    let timeout, interval;
    timeout = setTimeout(() => {
      setAnimationDone(true);
      let counter = 0;
      interval = setInterval(() => {
        if (counter >= 91) counter *= -1;
        setTick(++counter);
      }, 1000);
    }, 3500);

    return () => {
      if (timeout) clearTimeout(timeout);
      if (interval) clearInterval(interval);
    };
  }, []);

  return (
    <div className="relative flex h-full w-full overflow-hidden bg-bg">
      <div
        className={twMerge(
          "absolute left-[25vw] max-h-0 w-[1px] animate-growYmobile bg-white/10 mobile:left-[25vw] mobile:animate-growY",
          animationDone && "translate-x-[25vw] opacity-0 duration-700"
        )}
      />
      <div
        className={`absolute left-[50vw] max-h-0 w-[2px] animate-growYmobileRed bg-white/10 transition-colors duration-500 mobile:animate-growYRed ${
          animationDone
            ? "bg-gradient-to-t from-red-500 via-red-500 to-transparent"
            : "bg-white/10"
        }`}
        style={
          animationDone
            ? {
                animationDelay: "0.5s",
                transform: `rotate(${tick}deg)`,
                transformOrigin: "center bottom",
              }
            : {
                animationDelay: "0.5s",
              }
        }
      />
      <div
        className={twMerge(
          "absolute right-[25vw] max-h-0 w-[1px] animate-growYmobile bg-white/10 mobile:animate-growY",
          animationDone && "-translate-x-[25vw] opacity-0 duration-700"
        )}
        style={{
          animationDelay: "1s",
        }}
      />
      <div className="flex-grow bg-transparent" />
      <div
        className={`absolute left-0 top-[60%] w-[100%] animate-rotate180 rounded-full border-b-2 border-dashed border-white/10 bg-transparent pb-[100%] transition-colors duration-500 mobile:top-[53%] ${
          animationDone ? "border-white" : "border-white/10"
        }`}
        style={{
          animationDelay: "1.5s",
        }}
      />
    </div>
  );
}
