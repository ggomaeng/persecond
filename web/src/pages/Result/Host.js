import React from "react";
import ResultItem from "./ResultItem";
import Button from "components/Button";
import { abbreviateAddress } from "utils/address";

export default function Host() {
  return (
    <>
      <div className="mt-5 text-2xl text-primary">
        Successfully completed the meeting with{" "}
        <span className="font-bold">
          {abbreviateAddress("2384819234bndfjgbsdlfkj2l34h")}
        </span>
      </div>
      <div className="mt-10 flex w-full flex-col gap-5">
        <ResultItem title="Amount of the meeting time">
          <div className="text-3xl font-bold text-primary">06:00:00</div>
        </ResultItem>
        <ResultItem title="Final payment">
          <div className="text-3xl font-bold text-primary">{102.4223} APT</div>
        </ResultItem>
        <ResultItem title="Transaction breakdown">
          <div className="text-sm">
            Your initial deposit:
            <span className="font-bold text-primary"> {2323} </span>
            APT
          </div>
          <div className="text-sm">
            You got refunded:
            <span className="font-bold text-primary"> {2323} </span>
            APT
          </div>
          <Button className="mt-2 h-[18px] min-w-0 px-2 text-xs font-bold">
            View transaction
          </Button>
        </ResultItem>
      </div>
    </>
  );
}
