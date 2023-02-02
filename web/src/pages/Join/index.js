import React from "react";
import StepBase from "../Launch/StepBase";
import Button from "components/Button";
import Header from "components/Header";
import { formatHours } from "utils/numbers";
import { fixDecimalPlaces } from "utils/numbers";
import { abbreviateAddress } from "utils/address";

export default function Join() {
  const dummy = {
    title: "Aptos' Mo Shaikh on the Move Moment",
    description:
      "Aptos' Mo Shaikh on the Move Moment - Messari Mainnet 2022. Libra died, but its smart-contract language lives on. Move is used by the buzziest chains of the moment, including Aptos. Its co-founder Mo Shaikh tells us why it's worth billions despite publishing its whitepaper last month.",
    price: 0.02,
    duration: 16,
  };

  return (
    <div className="flex h-screen flex-col justify-center padded-horizontal">
      <Header />
      <h1 className="text-3xl text-primary">Join the perSecond meeting</h1>
      <h2 className="mt-1 text-lg text-secondary">
        You have received a request for a perSecond meeting. You will be paid
        according to the rate set by the requester for the exact amount of time
        spent in the meeting.
      </h2>
      <hr className="mt-5 mb-10 border-input-border" />
      <div className="flex flex-col tablet:flex-row">
        <div className="flex flex-col gap-5.5 tablet:w-1/2">
          <img src="/assets/aptos-logo@2x.png" alt="" />
          <div className="border-1 w-full border border-primary bg-modal-bg p-5 text-lg text-secondary">
            <div className="text-2xl text-primary">Meeting information</div>
            <div className="mt-2">
              Price:
              <span className="font-bold text-primary"> {dummy.price} APT</span>
              <span> / sec ({dummy.price} APT / hour)</span>
            </div>
            <div>Max duration: 2 hours</div>
            <div>
              Requestor:{" "}
              {abbreviateAddress(
                "0xe5a07359699b5457ab8db5f285765e7e115061b9b00de4ebca6a9d943e086d1e"
              )}
            </div>
          </div>
        </div>
        <div className="flex flex-col tablet:w-1/2 tablet:pl-10">
          <StepBase count={1} title="Connect wallet">
            <div className="text-secondary">
              Connect your Aptos wallet to proceed
            </div>
            <Button
              image="/assets/aptos-logo@2x.png"
              className="mt-5 flex items-center justify-center font-semibold text-primary"
            >
              Connect wallet
            </Button>
          </StepBase>
          <StepBase count={2} title="Join the meeting">
            <div>
              By making this transaction, you are agreeing to participate in the
              meeting and receive the time-based payment.
            </div>
            <Button className="mt-5 flex items-center justify-center font-semibold">
              Proceed to join
            </Button>
          </StepBase>
        </div>
      </div>
    </div>
  );
}
