import React, { useState } from "react";
import { twMerge } from "tailwind-merge";

export default function Input({ className, children, limit, ...props }) {
  return (
    <div className="flex w-full flex-col text-start text-secondary">
      <input
        {...props}
        className={twMerge(
          "h-[54px] w-full min-w-[260px] border border-input-border bg-bg px-4 text-lg text-primary outline-none transition-all placeholder:text-secondary focus:outline-none",
          className
        )}
      />
      {children}
    </div>
  );
}
