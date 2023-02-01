import React from "react";
import StepBase from "./StepBase";
import Button from "components/Button";

export default function StepConnect() {
  return (
    <StepBase count={1} title="Connect wallet">
      <div className="text-secondary">Connect your Aptos wallet to proceed</div>
      <Button className="mt-5 text-primary">Connect wallet</Button>
    </StepBase>
  );
}
