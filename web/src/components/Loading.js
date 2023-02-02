import React from "react";
import "css-doodle";

export default function Loading() {
  return (
    <div className="absolute flex h-screen w-screen animate-fadeIn items-center justify-center overflow-clip object-contain">
      <div className="absolute">
        <css-doodle use="var(--rule)"></css-doodle>
      </div>
      <img
        className="h-20 w-20 animate-pulse opacity-50"
        src="/assets/logo-single@2x.png"
        alt=""
      />
    </div>
  );
}
