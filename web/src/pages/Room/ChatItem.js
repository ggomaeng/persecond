import React from "react";

export default function ChatItem({ mine, message }) {
  return (
    <div
      className={`mt-2 flex w-full flex-col text-sm ${
        mine ? "items-end" : "items-start"
      }`}
    >
      <div
        className={`max-w-[60%] border px-2 py-1 ${
          mine
            ? "bg-primary text-end text-black"
            : "border-primary text-primary"
        }
			`}
      >
        {message}
      </div>
    </div>
  );
}
