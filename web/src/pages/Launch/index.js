import React from "react";
import StepBase from "./StepBase";
import Button from "components/Button";
import Input from "components/Input";
import Header from "components/Header";
import { fixDecimalPlaces } from "utils/numbers";

export default function Launch() {
  return (
    <div>
      <div className="text-3xl text-primary">Create perSecond Link</div>
      <hr className="mt-5 mb-10 border-input-border" />
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
      <StepBase count={2} title="Title of the session">
        <Input placeholder="Be clear and descriptive.">
          <div className="self-end text-sm">
            {3} / {80}
          </div>
        </Input>
      </StepBase>
      <div className="flex flex-col justify-between mobile:grid mobile:grid-cols-2 mobile:gap-10">
        <StepBase count={3} title="Hourly rate">
          <Input placeholder="0.00">
            <div className="ml-2">{fixDecimalPlaces(0, 2)} USDC / second</div>
          </Input>
        </StepBase>
        <StepBase count={4} title="Session duration">
          <Input placeholder="0.00">
            <div className="ml-2">Session auto-closes after time period.</div>
          </Input>
        </StepBase>
      </div>
      <StepBase count={5} title="Description">
        <textarea
          className="h-[180px] w-full min-w-[260px] resize-none border border-input-border bg-bg p-3 px-4 text-lg text-primary outline-none transition-all placeholder:text-secondary focus:outline-none"
          placeholder="Add more details to your session"
        />
        <div className="self-end text-sm">
          {3} / {360}
        </div>
      </StepBase>
      <Button className="mt-5 flex items-center justify-center font-semibold text-primary">
        Create link to join
      </Button>
    </div>
  );
}
