import React from "react";
import StepBase from "../Join/StepBase";
import Button from "components/Button";
import Header from "components/Header";
import Input from "components/Input";
import { fixDecimalPlaces } from "utils/numbers";
import { useCreateStore } from "stores/create";

export default function Launch() {
  const {
    title,
    price,
    duration,
    description,
    setTitle,
    setPrice,
    setDuration,
    setDescription,
  } = useCreateStore((state) => state);
  const [isModal, setIsModal] = React.useState(false);

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
      <StepBase count={2} title="Title of the session">
        <Input
          value={title}
          onChange={setTitle}
          placeholder="Be clear and descriptive."
        >
          <div className="self-end text-sm">
            {title.length} / {80}
          </div>
        </Input>
      </StepBase>
      <div className="flex flex-col tablet:grid tablet:grid-cols-2 tablet:gap-[80px]">
        <StepBase count={3} title="Hourly price">
          <Input
            type="number"
            value={price}
            onChange={setPrice}
            placeholder="0.00"
          >
            <div className="ml-2 mt-1">
              {fixDecimalPlaces(price, 2)} USDC / second
            </div>
            <div className="absolute right-4 top-3 text-lg">USDC</div>
          </Input>
        </StepBase>
        <StepBase count={4} title="Session duration">
          <Button
            onClick={() => setIsModal(!isModal)}
            className="h-[54px] w-full border-input-border px-4 text-start text-lg text-secondary"
            image="/assets/arrow-down.svg"
            imageClassName={`absolute right-4 top-4 ${isModal && "rotate-180"}`}
          >
            {handleDurationTitle(duration)}
          </Button>
          <div className="relative h-full">
            <div
              className={`absolute top-0 left-0 z-10 w-full flex-col border border-input-border bg-bg transition-opacity duration-500 ${
                isModal ? "opacity-1" : "opacity-0"
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
          <div className="ml-2 mt-1">
            Session auto-closes after time period.
          </div>
        </StepBase>
      </div>
      <StepBase count={5} title="Description">
        <textarea
          value={description}
          onChange={(e) => {
            if (e.target.value.length <= 360) {
              setDescription(e.target.value);
            }
          }}
          className="h-[180px] w-full min-w-[260px] resize-none border border-input-border bg-bg p-3 px-4 text-lg text-primary outline-none transition-all placeholder:text-secondary focus:outline-none"
          placeholder="Add more details to your session"
        />
        <div className="self-end text-sm text-secondary">
          {description.length} / {360}
        </div>
      </StepBase>
      <Button className="mt-5 flex items-center justify-center font-semibold">
        Create link to join
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
