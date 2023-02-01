import React from "react";
import { createPortal } from "react-dom";

export default function Modal({
  children,
  containerClassName = "",
  contentClassName = "",
  visible,
  close,
}) {
  const portal = document.getElementById("portal");

  if (!portal || !visible) return null;

  return createPortal(
    <div
      className={`bg-black-65 fixed left-0 top-0 z-[9999] flex h-full w-screen p-2.5 ${containerClassName}`}
      onClick={(e) => {
        close?.();
      }}
    >
      <div
        className={`relative m-auto flex h-full w-[480px] max-w-full flex-col border border-[#4a4a4a] bg-[#170726] p-[30px] text-white mobile:h-auto ${contentClassName}`}
      >
        <img
          className="absolute top-5 right-5 h-[18px] w-[18px] cursor-pointer"
          src="/assets/close-grey.svg"
          alt=""
          onClick={() => close?.()}
        />
        <div
          className="hide-scrollbar flex flex-grow overflow-y-scroll"
          onClick={(e) => e.stopPropagation()}
        >
          <div className="h-full w-full">{children}</div>
        </div>
      </div>
    </div>,
    portal
  );
}
