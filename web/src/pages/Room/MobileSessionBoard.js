import React, { useState } from "react";
import { fixDecimalPlaces, formatHours } from "utils/numbers";
import SessionTimer from "pages/Room/SessionTimer.js";
import { useRoomStore } from "stores/room.js";

export default function MobileSessionBoard({ isHost = true }) {
  const [spent, setSpent] = useState(0);
  const session = useRoomStore((state) => state.session);

  return (
    <div className="border-1 mt-[10px] flex w-full items-center justify-between border border-primary bg-modal-bg p-2 text-sm text-secondary">
      <div className="text-lg font-bold">
        <SessionTimer
          onTick={(secondsSpent) => {
            setSpent((session?.second_rate * secondsSpent) / 1e8);
          }}
        />
        <div className="text-sm">
          Max Duration: {formatHours(session.max_duration / 3600)}
        </div>
      </div>
      <div className="flex font-bold text-primary">
        {fixDecimalPlaces(spent, 8)} APT
      </div>
    </div>
  );
}
