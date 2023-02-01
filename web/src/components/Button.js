import React, { useState } from "react";
import { twMerge } from "tailwind-merge";

export default function Button({ className, children, icon, ...props }) {
  const [hovering, setHovering] = useState(false);
  return (
    <div className="relative">
      {icon && (
        <div
          className={`absolute left-1/2 z-[0] -translate-x-1/2 text-[24px] transition-all ${
            hovering ? "bottom-3/4" : "bottom-0"
          }`}
        >
          {icon}
        </div>
      )}

      <button
        {...props}
        onPointerEnter={() => setHovering(true)}
        onPointerLeave={() => setHovering(false)}
        className={twMerge(
          "relative z-[1] h-[40px] min-w-[200px] border border-primary bg-bg text-primary transition-all hover:bg-primary hover:text-black",
          className
        )}
      >
        {children}
      </button>
    </div>
  );
}
