import React from "react";
import StepBase from "../Launch/StepBase";
import Button from "components/Button";
import Header from "components/Header";
import { formatHours } from "utils/numbers";
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
      <div className="flex flex-col tablet:flex-row">
        <div className="flex flex-col gap-5.5 tablet:w-1/2">
          <img src="/assets/aptos-logo@2x.png" alt="" />
          <div className="border-1 w-full border border-primary bg-[#170726] p-5 text-secondary">
            <div className="text-2xl text-primary">Session information</div>
            <div className="mt-2">
              Price:
              <span className="font-bold text-primary"> ${dummy.price} </span>/
              sec
            </div>
            <div>Current: {3} audiences</div>
            <div>Total: {17} audiences</div>
            <div>
              Duration: {`15:04:31 `} / {formatHours(dummy.duration)}
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
          <StepBase count={2} title="Validation check">
            <div className="flex items-start gap-2">
              <img src="/assets/check-green.svg" className="w-5.5" alt="" />
              <div className="flex flex-col">
                <div>Sufficent balance to make a deposit to join</div>
                <div>
                  My balance:
                  <span className="font-bold text-primary">
                    {" "}
                    {fixDecimalPlaces(152, 2)} APT
                  </span>
                </div>
              </div>
            </div>
            <div className="mt-2 flex items-start gap-2">
              <img src="/assets/check-grey.svg" className="w-5.5" alt="" />
              <div className="flex flex-col">
                <div>Need to approve USDC</div>
                <Button className="mt-2.5 flex items-center justify-center font-semibold">
                  Approve APTOS
                </Button>
              </div>
            </div>
          </StepBase>
          <StepBase count={3} title="Join the session">
            <div>
              <span className="font-bold text-primary">50.23 USDC</span> held as
              full-duration deposit to join session. Any remaining balance
              refunded based on actual session time.
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
