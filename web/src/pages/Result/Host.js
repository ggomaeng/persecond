import React from "react";
import ResultItem from "./ResultItem";

export default function Host() {
  return (
    <div className="mt-10 flex w-full flex-col gap-5">
      <ResultItem title="Total duration">
        <div className="text-3xl font-bold">06:00:00</div>
      </ResultItem>
      <ResultItem title="Final amount you earned">
        <div className="text-3xl font-bold">06:00:00</div>
      </ResultItem>
      <ResultItem title="Audiences breakdown">
        <div className="text-sm">
          Total number of audiences
          <span className="font-bold text-primary"></span>
        </div>
        <div className="text-sm">
          Highest amount paid out:
          <span className="font-bold text-primary"></span>
        </div>
        <div className="text-sm">
          Avg. duration per audience:
          <span className="font-bold text-primary"></span>
        </div>
      </ResultItem>
    </div>
  );
}
