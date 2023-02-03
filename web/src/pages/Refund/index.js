import React, { useEffect, useState } from "react";
import Button from "components/Button";
import { Link, useParams } from "react-router-dom";
import FadeInComponent from "components/FadeInComponent";
import ResultItem from "pages/Result/ResultItem.js";
import { useAppStore } from "stores/app.js";
import { aptosClient } from "utils/aptos.js";
import { aptosToDigits, fixDecimalPlaces } from "utils/numbers.js";

export default function Refund() {
  const { hash } = useParams();
  const [data, setData] = useState();
  const setFullLoading = useAppStore((state) => state.setFullLoading);

  async function fetchData() {
    try {
      setFullLoading(true);
      const receipt = await aptosClient.getTransactionByHash(hash);
      if (receipt) {
        setData(
          receipt.events.find((e) => e?.type?.includes?.("DepositEvent"))?.data
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

  return (
    <div className="flex min-h-screen flex-col items-center justify-center py-[40px] pb-[200px] padded-horizontal">
      <Link to="/">
        <Button className="flex w-[200px] justify-center">Go home</Button>
      </Link>
      <FadeInComponent>
        <div className="mt-10 flex flex-col items-center border border-[#4a4a4a] bg-modal-bg py-15 px-10 text-center tablet:w-[480px]">
          <img className="w-[80px]" src="/assets/logo-single@2x.png" alt="" />
          <>
            <div className="mt-5 text-xl text-primary mobile:text-2xl">
              Remaining balance has been refunded
            </div>
            <div className="mt-10 flex w-full flex-col items-center gap-5">
              <ResultItem title="Refund Amount">
                <div className="text-3xl font-bold text-primary">
                  {aptosToDigits(data?.amount)} APT
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
        </div>
      </FadeInComponent>
    </div>
  );
}
