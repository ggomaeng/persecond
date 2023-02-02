import React from "react";
import ResultItem from "./ResultItem";
import Button from "components/Button";
import { abbreviateAddress } from "utils/address";

export default function Expert() {
  return (
    <>
      <div className="mt-5 text-xl text-primary mobile:text-2xl">
        Congrats! You have received payment from{" "}
        <span className="font-bold">
          {abbreviateAddress("2384819234bndfjgbsdlfkj2l34h")}
        </span>{" "}
        for the meeting.
      </div>
      <div className="mt-10 flex w-full flex-col items-center gap-5">
        <ResultItem title="Amount of meeting time">
          <div className="text-3xl font-bold text-primary">06:00:00</div>
        </ResultItem>
        <ResultItem title="Final amount you earned">
          <div className="text-end text-sm">{1322} APT / sec</div>
          <div className="text-3xl font-bold text-primary">{102.4223} APT</div>
        </ResultItem>
        <Button className="mt-2 flex w-[200px] justify-center text-base">
          View transaction
        </Button>
      </div>
    </>
  );
}
