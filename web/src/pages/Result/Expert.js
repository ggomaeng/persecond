import React, { useEffect, useState } from "react";
import ResultItem from "./ResultItem";
import Button from "components/Button";
import { abbreviateAddress } from "utils/address";
import { useParams } from "react-router-dom";
import { aptosClient, getSession } from "utils/aptos.js";
import { useAppStore } from "stores/app.js";
import { aptosToDigits, fixDecimalPlaces, formatHours } from "utils/numbers.js";

export default function Expert() {
  const [data, setData] = useState();
  const setFullLoading = useAppStore((state) => state.setFullLoading);
  const { hash } = useParams();

  async function fetchData() {
    try {
      setFullLoading(true);
      const receipt = await aptosClient.getTransactionByHash(hash);
      console.log(receipt);
      if (receipt) {
        setData(
          receipt.events.find((e) => e?.type?.includes?.("CloseSessionEvent"))
            ?.data
        );
      }
    } catch (e) {
    } finally {
      setFullLoading(false);
    }
  }

  useEffect(() => {
    if (hash) fetchData();
  }, []);

  const diff = data?.finished_at - data?.started_at;
  console.log(data);

  return (
    <>
      <div className="mt-5 text-xl text-primary mobile:text-2xl">
        Successfully completed the meeting
        {/* <span className="font-bold">
          {abbreviateAddress("2384819234bndfjgbsdlfkj2l34h")}
        </span>{" "}
        for the meeting. */}
      </div>
      <div className="mt-10 flex w-full flex-col items-center gap-5">
        <ResultItem title="Requester">
          <div className="text-3xl font-bold text-primary">
            {abbreviateAddress(data?.requester)}
          </div>
        </ResultItem>
        <ResultItem title="Requestee">
          <div className="text-3xl font-bold text-primary">
            {abbreviateAddress(data?.receiver)}
          </div>
        </ResultItem>
        <ResultItem title="Amount of meeting time">
          <div className="text-3xl font-bold text-primary">
            {formatHours(diff / 3600)}
          </div>
        </ResultItem>
        <ResultItem title="Final amount you earned">
          <div className="text-end text-sm">
            {aptosToDigits(data?.second_rate)} APT / sec
          </div>
          <div className="text-3xl font-bold text-primary">
            {fixDecimalPlaces(data?.paid_amount / 1e8, 8)} APT
          </div>
        </ResultItem>
        <a
          href={`https://explorer.aptoslabs.com/txn/${hash}?network=Testnet`}
          target="_blank"
          rel="noreferrer noopener"
        >
          <Button className="mt-2 flex w-[200px] justify-center text-base">
            View transaction
          </Button>
        </a>
      </div>
    </>
  );
}
