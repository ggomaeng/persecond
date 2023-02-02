import CaretDownIcon from "pages/Room/Icons/CaretDownIcon.js";
import React, { useState } from "react";
import { useRoomStore } from "stores/room.js";
import { twMerge } from "tailwind-merge";

export default function ControlItem({
  id,
  className,
  activeOptions,
  options,
  icon,
  onClick,
  onOptionClick,
  children,
}) {
  const setActiveOption = useRoomStore((state) => state.setActiveOption);
  const activeOption = useRoomStore((state) => state.activeOption);
  return (
    <div
      className={twMerge(
        "flex h-[40px] min-w-[40px] cursor-pointer items-center justify-center rounded-md border-[2px] border-primary",
        className
      )}
      onClick={onClick}
    >
      {children}
      {icon}
      {options?.length > 0 && (
        <div className="relative">
          <CaretDownIcon
            onClick={(e) => {
              e.stopPropagation();
              if (activeOption === id) setActiveOption(false);
              else setActiveOption(id);
            }}
            className="ml-1"
            fill="#dfcedf"
          />
          {activeOption === id && (
            <div className="absolute bottom-[calc(100%+20px)] left-1/2 min-w-[200px] -translate-x-1/2 rounded-md border border-primary bg-bg p-5">
              {options?.map?.((option, i) => {
                return (
                  <div
                    className={`border-white/10 py-2 text-xs ${
                      i > 0 && "border-t"
                    } ${
                      activeOptions?.includes(option.label)
                        ? " text-white"
                        : "text-white/50"
                    }`}
                    key={i}
                    onClick={(e) => {
                      e.stopPropagation();
                      onOptionClick(option);
                      setActiveOption(false);
                    }}
                  >
                    {option.label}
                  </div>
                );
              })}
            </div>
          )}
        </div>
      )}
    </div>
  );
}
