import React, { useState } from "react";
import { fixDecimalPlaces, formatHours } from "utils/numbers";
import SessionTimer from "pages/Room/SessionTimer.js";
import { useRoomStore } from "stores/room.js";

export default function SessionBoard({ isHost = true }) {
  const [spent, setSpent] = useState(0);
  const session = useRoomStore((state) => state.session);

  return (
    <div className="border-1 w-full border border-primary bg-modal-bg p-5 text-lg text-secondary">
      <div className="text-5xl font-bold">
        <SessionTimer
          onTick={(secondsSpent) => {
            setSpent((session?.second_rate * secondsSpent) / 1e8);
          }}
        />
      </div>
      <div className="mt-2.5 flex font-bold text-primary">
        {fixDecimalPlaces(spent, 8)} APT
      </div>
      <div>Max Duration: {formatHours(session.max_duration / 3600)}</div>
    </div>
  );
}
