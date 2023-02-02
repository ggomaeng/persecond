import React from "react";
import { twMerge } from "tailwind-merge";

export default function Input({
  className,
  onChange,
  children,
  limit,
  ...props
}) {
  return (
    <div className="relative flex w-full flex-col text-start text-secondary">
      <input
        {...props}
        onChange={(e) => {
          let value = e.target.value;
          if (limit) {
            if (value.length <= limit) {
              onChange(value);
            }
          } else {
            onChange(value);
          }
        }}
        className={twMerge(
          "h-[54px] w-full min-w-[260px] border border-input-border bg-bg px-4 text-lg text-primary outline-none transition-all placeholder:text-secondary focus:outline-none",
          className
        )}
      />
      {children}
    </div>
  );
}
