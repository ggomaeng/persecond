import React from "react";
import { formatHours } from "utils/numbers";
import Counter from "components/Counter";

export default function SessionBoard({ isHost = true }) {
  return (
    <div className="border-1 w-full border border-primary bg-modal-bg p-5 text-secondary">
      <div className="text-5xl font-bold text-dark-purple">
        <Counter />
      </div>
      <div className="flex text-2xl font-bold text-primary">
        <div>$</div>
        {13.31}
        <div className="ml-1">{isHost ? "earned" : "paid"}</div>
      </div>
      <div className="mt-10">Current: {3} audiences</div>
      <div>Total: {17} audiences</div>
      {isHost && <div>Avg.payment: ${17}</div>}
      <div>
        Duration: {`15:04:31 `} / {formatHours(4)}
      </div>
    </div>
  );
}
