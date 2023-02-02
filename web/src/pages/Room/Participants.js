import React from "react";

export default function Participants() {
  return (
    <div className="mt-[20px] flex flex-wrap justify-center gap-[20px]">
      {Array.from({ length: 100 }, (_, index) => {
        return (
          <div
            key={index}
            className="h-[100px] w-[100px] rounded-full border border-primary/50"
          ></div>
        );
      })}
    </div>
  );
}
