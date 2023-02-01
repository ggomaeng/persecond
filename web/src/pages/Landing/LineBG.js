import React, { useEffect, useState } from "react";

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
      <div className="absolute left-[25vw] max-h-0 w-[1px] animate-growY bg-white/10" />
      <div
        className={`absolute left-[50vw] max-h-0 w-[2px] animate-growY bg-white/10 transition-colors duration-500 ${
          animationDone ? "bg-red-500" : "bg-white/10"
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
        className="absolute left-[75vw] max-h-0 w-[1px] animate-growY bg-white/10"
        style={{
          animationDelay: "1s",
        }}
      />
      <div className="flex-grow bg-transparent" />
      <div
        className={`absolute left-0 top-[60%] w-screen animate-rotate180 rounded-full border-b-2 border-dashed border-white/10 bg-transparent pb-[100%] transition-colors duration-500 ${
          animationDone ? "border-white" : "border-white/10"
        }`}
        style={{
          animationDelay: "1.5s",
        }}
      />
    </div>
  );
}
