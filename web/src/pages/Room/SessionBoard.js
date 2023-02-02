import React, { useState } from "react";
import { fixDecimalPlaces, formatHours } from "utils/numbers";
import SessionTimer from "pages/Room/SessionTimer.js";
import { useRoomStore } from "stores/room.js";

export default function SessionBoard({ isHost = true }) {
  const [spent, setSpent] = useState(0);
  const session = useRoomStore((state) => state.session);

  return (
    <div className="border-1 flex w-full items-center justify-between border border-primary bg-modal-bg px-5 py-1 text-lg text-secondary tablet:flex-col tablet:items-start">
      <div className="text-3xl font-bold tablet:text-5xl">
        <SessionTimer
          onTick={(secondsSpent) => {
            setSpent((session?.second_rate * secondsSpent) / 1e8);
          }}
        />
      </div>
      <div className="mt-2.5 flex font-bold text-primary">
        {fixDecimalPlaces(spent, 8)} APT
      </div>
    </div>
  );
}
