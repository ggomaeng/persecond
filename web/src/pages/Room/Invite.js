import React from "react";
import CopyToClipboard from "react-copy-to-clipboard";
import { toast } from "react-hot-toast";
import { useParams } from "react-router-dom";

export default function Invite() {
  const { roomId } = useParams();
  const link = `${window.location.origin}/join/${roomId}}`;
  return (
    <div
      className={`relative flex h-full w-full flex-grow flex-col items-center justify-center border border-primary/50 mobile:w-[calc(50%-10px)]`}
    >
      <img
        className="h-[80px] w-[80px]"
        src="/assets/empty-person@2x.png"
        alt=""
      />
      <div className="absolute bottom-0 left-0 w-full border border-primary bg-[#170726] p-[20px] text-lg">
        <div className="text-[#8a6eaa]">Share this meeting link</div>
        <div className="relative mt-[12px] flex items-center justify-between border-b border-primary pb-[5px]">
          <div className="max-w-[calc(100%-24px)] overflow-hidden text-ellipsis whitespace-nowrap text-primary">
            {link}
          </div>
          <CopyToClipboard
            text={link}
            onCopy={() => toast.success("Copied to clipboard!")}
          >
            <img
              className="h-4 w-4 cursor-pointer"
              src="/assets/copy@2x.png"
              alt=""
            />
          </CopyToClipboard>
        </div>
      </div>
    </div>
  );
}
