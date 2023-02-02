import React, { useState } from "react";
import { fixDecimalPlaces, formatHours } from "utils/numbers";
import SessionTimer from "pages/Room/SessionTimer.js";
import { useRoomStore } from "stores/room.js";

export default function SessionBoard({ isHost = true }) {
  const [spent, setSpent] = useState(0);
  const session = useRoomStore((state) => state.session);

  return (
    <div className="border-1 flex w-full items-center justify-between border border-primary bg-modal-bg px-5 py-1 text-lg text-secondary fullscreen:flex-col fullscreen:items-start">
      <div className="text-3xl font-bold fullscreen:text-5xl">
        <SessionTimer
          onTick={(secondsSpent) => {
            setSpent((session?.second_rate * secondsSpent) / 1e8);
          }}
        />
      </div>
      <div className="flex flex-col">
        <div className="mr-10 flex font-bold text-primary">
          {fixDecimalPlaces(spent, 8)} APT
        </div>
        <div>Max Duration: {formatHours(session.max_duration / 3600)}</div>
      </div>
    </div>
  );
}
