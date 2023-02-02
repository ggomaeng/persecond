import React from "react";
import "css-doodle";

export default function Loading() {
  return (
    <div className="flex h-screen w-full items-center justify-center overflow-clip object-contain">
      <css-doodle use="var(--rule)"></css-doodle>
    </div>
  );
}
