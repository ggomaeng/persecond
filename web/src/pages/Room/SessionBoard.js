import React from "react";
import { formatHours } from "utils/numbers";
import Counter from "components/Counter";

export default function SessionBoard({ isHost = true }) {
  return (
    <div className="border-1 w-full border border-primary bg-modal-bg p-5 text-lg text-secondary">
      <div className="text-5xl font-bold">
        <Counter />
      </div>
      <div className="mt-2.5 flex font-bold text-primary">
        {13.31} APT
        <span className="ml-1 font-normal text-secondary">spent</span>
      </div>
      <div>Max Duration: {formatHours(4)}</div>
    </div>
  );
}
