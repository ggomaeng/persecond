import React, { useState } from "react";
import { twMerge } from "tailwind-merge";

export default function Button({
  className,
  imageClassName,
  children,
  icon,
  image,
  ...props
}) {
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
          "relative z-[1] h-[40px] min-w-[140px] border border-primary bg-bg px-4 font-bold text-primary transition-all hover:bg-primary hover:text-black",
          className
        )}
      >
        {image && (
          <img
            src={image}
            className={twMerge(
              `mr-2 h-5 w-5 ${hovering && "invert"}`,
              imageClassName
            )}
            alt={image}
          />
        )}
        {children}
      </button>
    </div>
  );
}
