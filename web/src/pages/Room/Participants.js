import React from "react";
import { getRandomAlphabet } from "utils/strings.js";

export default function Participants() {
  return (
    <div className="mt-[20px] flex flex-wrap justify-center gap-[20px]">
      {Array.from({ length: 8 }, (_, index) => {
        return (
          <div
            key={index}
            className="flex h-[100px] w-[100px] items-center justify-center rounded-full border border-primary/50 text-[40px] font-bold uppercase"
          >
            {getRandomAlphabet()}
          </div>
        );
      })}
    </div>
  );
}
