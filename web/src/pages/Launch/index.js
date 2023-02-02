import React from "react";
import StepBase from "../Join/StepBase";
import Button from "components/Button";
import Header from "components/Header";
import Input from "components/Input";
import { fixDecimalPlaces } from "utils/numbers";
import { useLaunchStore } from "stores/create";
import { api } from "utils/api.js";
import { useNavigate } from "react-router-dom";

export default function Launch() {
  const { price, duration, setPrice, setDuration } = useLaunchStore(
    (state) => state
  );
  const [isModal, setIsModal] = React.useState(false);
  const navigate = useNavigate();

  return (
    <div className="flex h-screen flex-col justify-center padded-horizontal">
      <Header />
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
      <StepBase count={2} title="Set details for your meeting">
        <div className="text-secondary">
          You will get charged by the exact amount of the meeting performed
          within the max duration time you set.
        </div>

        <div className="flex flex-col text-lg tablet:grid tablet:grid-cols-2 tablet:gap-[80px]">
          <div className="flex flex-col">
            <div className="mb-2.5 mt-5 text-lg text-primary">
              Create perSecond Link
            </div>
            <Input
              type="number"
              value={price}
              onChange={setPrice}
              placeholder="0.00"
            >
              <div className="ml-4 mt-1">
                {fixDecimalPlaces(price, 2)} APT / second
              </div>
              <div className="absolute right-4 top-3 text-lg">APT</div>
            </Input>
          </div>
          <div className="flex flex-col">
            <div className="mb-2.5 mt-5 text-lg text-primary">Max duration</div>
            <Button
              onClick={() => setIsModal(!isModal)}
              className="h-[54px] w-full border-input-border px-4 text-start text-lg text-secondary"
              image="/assets/arrow-down.svg"
              imageClassName={`absolute right-4 top-4 ${
                isModal && "rotate-180"
              }`}
            >
              {handleDurationTitle(duration)}
            </Button>
            <div className="relative">
              <div
                className={`absolute top-0 left-0 z-10 w-full flex-col bg-bg transition-opacity duration-500 ${
                  isModal ? "opacity-1" : "pointer-events-none opacity-0"
                }`}
              >
                <DurationOptionButton value={0.25} />
                <DurationOptionButton value={0.5} />
                <DurationOptionButton value={1} />
                <DurationOptionButton value={2} />
                <DurationOptionButton value={3} />
                <DurationOptionButton value={4} />
              </div>
            </div>
            <div className="ml-4 mt-1 text-secondary">
              Session auto-closes after time period.
            </div>
          </div>
        </div>
      </StepBase>
      <div className="flex flex-col text-lg text-primary">
        <div>
          Deposit amount:
          <span className="font-bold"> {200} APT </span>
          required
        </div>
        <div>
          Your balance:
          <span className={`font-bold text-${true ? "[#e02020]" : ""}`}>
            {" "}
            {200} APT{" "}
          </span>
        </div>
      </div>
      <div
        className={`mt-2.5 flex items-center gap-1.5 text-lg text-[#e02020] ${
          true ? "opacity-1" : "pointer-events-none opacity-0"
        } `}
      >
        <img src="assets/not-valid@2x.png" className="w-5.5" alt="" />
        Not sufficient balance to make a deposit to begin the meeting.
      </div>
      <div className="mt-5 text-lg text-secondary">
        The deposit tokens will be kept as a full-duration deposit for the
        meeting. Any unused balance will be refunded based on the actual
        duration of the meeting.
      </div>
      <Button
        className="mt-5 flex items-center justify-center font-semibold"
        onClick={async () => {
          const result = await api.post("").json();
          const { roomId, id } = result;
          navigate(`/rooms/${roomId}`);
          console.log(result);
        }}
      >
        Launch meeting
      </Button>
    </div>
  );

  function DurationOptionButton({ value }) {
    return (
      <Button
        onClick={() => {
          setDuration(value);
          setIsModal(false);
        }}
        className="h-[54px] w-full border-input-border px-4 text-start text-lg text-secondary"
      >
        {handleDurationTitle(value)}
      </Button>
    );
  }

  function handleDurationTitle(num) {
    if (num === 0.25) return "15 minutes";
    if (num === 0.5) return "30 minutes";
    if (num === 1) return "1 hour";
    if (num === 2) return "2 hours";
    if (num === 3) return "3 hours";
    if (num === 4) return "4 hours";
  }
}
