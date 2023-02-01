import React from "react";
import ResultItem from "./ResultItem";
import Button from "components/Button";

export default function Audience() {
  return (
    <div className="mt-10 flex w-full flex-col gap-5">
      <ResultItem title="Amount of time you spent">
        <div className="text-3xl font-bold text-primary">06:00:00</div>
      </ResultItem>
      <ResultItem title="Final payment">
        <div className="text-3xl font-bold text-primary">06:00:00</div>
      </ResultItem>
      <ResultItem title="Transaction breakdown">
        <div className="text-sm">
          Your initlal deposit:
          <span className="font-bold text-primary"></span>
        </div>
        <div className="text-sm">
          You got refunded:
          <span className="font-bold text-primary"></span>
        </div>
        <div className="text-sm">
          <span className="font-bold text-primary"></span>
        </div>
        <Button className="mt-2 h-[18px] min-w-0 px-2 text-xs font-bold">
          View transaction
        </Button>
      </ResultItem>
    </div>
  );
}
