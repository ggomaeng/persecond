import CaretDownIcon from "pages/Room/Icons/CaretDownIcon.js";
import React from "react";
import { twMerge } from "tailwind-merge";

export default function ControlItem({
  className,
  options,
  icon,
  onClick,
  children,
}) {
  return (
    <div
      className={twMerge(
        "flex h-[40px] min-w-[40px] items-center justify-center rounded-md border-[2px] border-primary",
        className
      )}
      onClick={onClick}
    >
      {children}
      {icon}
      {options && <CaretDownIcon fill="#dfcedf" />}
    </div>
  );
}
