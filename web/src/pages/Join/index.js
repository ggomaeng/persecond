import React from "react";
import StepBase from "../Launch/StepBase";
import Button from "components/Button";
import Header from "components/Header";
import { fixDecimalPlaces } from "utils/numbers";

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
      <div className="text-3xl text-primary">{dummy.title}</div>
      <div className="mt-1 text-lg text-secondary">{dummy.description}</div>
      <hr className="mt-5 mb-10 border-input-border" />
      <div className="flex flex-col tablet:flex-row tablet:gap-10">
        <div className="flex w-3/5 flex-col ">
          <img src="/assets/aptos-logo@2x.png" alt="" />
        </div>
        <div className="flex w-2/5 flex-col">
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
          <StepBase count={2} title="Validation check">
            <div className="flex gap-2">
              <img src="/assets/check.svg" className="w-5.5" alt="" />
              <div>Sufficent balance to make a deposit to join</div>
            </div>
          </StepBase>
          <div className="flex flex-col tablet:grid tablet:grid-cols-2 tablet:gap-[80px]">
            <StepBase count={3} title="Hourly rate"></StepBase>
            <Button className="mt-5 flex items-center justify-center font-semibold">
              Create link to join
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}
