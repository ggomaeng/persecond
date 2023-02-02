import React, { useState } from "react";
import { twMerge } from "tailwind-merge";

export default function Button({
  className,
  imageClassName,
  children,
  loading,
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
          "relative z-[1] flex h-[40px] min-w-[140px] items-center border border-primary bg-bg px-4 font-bold text-primary transition-all enabled:hover:bg-primary enabled:hover:text-black disabled:opacity-50 ",
          className
        )}
        disabled={props.disabled}
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

        {loading ? (
          <img
            className={`animate-rotate360 ${hovering && "invert"}`}
            src="/assets/spinner.svg"
            width={24}
            height={24}
            alt="spinner"
          />
        ) : (
          children
        )}
      </button>
    </div>
  );
}
