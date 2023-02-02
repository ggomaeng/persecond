import React from "react";
import StepBase from "../Join/StepBase";
import Button from "components/Button";
import Header from "components/Header";
import Input from "components/Input";
import { fixDecimalPlaces } from "utils/numbers";
import { useLaunchStore } from "stores/create";
import { api, serverApi } from "utils/api.js";
import { useNavigate } from "react-router-dom";
import { aptosClient, CONTRACT_ADDRESS } from "utils/aptos.js";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import ConnectWalletButton from "components/ConnectWalletButton.js";
import useAptosBalance from "hooks/useAptosBalance.js";
import { commify, formatUnits, parseUnits } from "ethers/lib/utils.js";
import { BigNumber } from "ethers";
import { toast } from "react-hot-toast";
import { toastError } from "utils/toasts.js";

export default function Launch() {
  const { price, duration, setPrice, setDuration } = useLaunchStore(
    (state) => state
  );
  const { balance } = useAptosBalance();

  const { account, signAndSubmitTransaction } = useWallet();

  const [isModal, setIsModal] = React.useState(false);
  const [loading, setLoading] = React.useState(false);
  const navigate = useNavigate();
  const notEnoughBalance = +balance < duration * price;

  return (
    <div className="flex h-screen flex-col justify-center padded-horizontal">
      <Header />
      <div className="text-3xl text-primary">Create perSecond Link</div>
      <hr className="mt-5 mb-10 border-input-border" />
      <StepBase count={1} title="Connect wallet">
        <div className="text-secondary">
          Connect your Aptos wallet to proceed
        </div>
        <ConnectWalletButton className="mt-5" />
      </StepBase>
      <StepBase count={2} title="Set details for your meeting">
        <div className="text-secondary">
          You will get charged by the exact amount of the meeting performed
          within the max duration time you set.
        </div>

        <div className="flex flex-col text-lg tablet:grid tablet:grid-cols-2 tablet:gap-[80px]">
          <div className="flex flex-col">
            <div className="mb-2.5 mt-5 text-lg text-primary">Hourly rate</div>
            <Input
              type="number"
              value={price}
              onChange={setPrice}
              placeholder="0.00"
            >
              <div className="ml-4 mt-1">
                {fixDecimalPlaces(price / 3600, 8)} APT / second
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
          <span className="font-bold"> {duration * price} APT </span>
          required
        </div>
        <div>
          Your balance:
          <span
            className={`font-bold text-${notEnoughBalance ? "[#e02020]" : ""}`}
          >
            {" "}
            {commify(balance)} APT{" "}
          </span>
        </div>
      </div>
      {notEnoughBalance && (
        <div
          className={`mt-2.5 flex items-center gap-1.5 text-lg text-[#e02020] ${
            true ? "opacity-1" : "pointer-events-none opacity-0"
          } `}
        >
          <img src="assets/not-valid@2x.png" className="w-5.5" alt="" />
          Not sufficient balance to make a deposit to begin the meeting.
        </div>
      )}
      <div className="mt-5 text-lg text-secondary">
        The deposit tokens will be kept as a full-duration deposit for the
        meeting. Any unused balance will be refunded based on the actual
        duration of the meeting.
      </div>
      <Button
        className="mt-5 flex items-center justify-center font-semibold"
        disabled={!account || !balance || !price || price === 0}
        loading={loading}
        onClick={async () => {
          try {
            setLoading(true);
            const result = await api.post("").json();
            // const result = await serverApi
            //   .post("create-meeting", {
            //     json: {
            //       token: process.env.REACT_APP_VIDEOSDK_TOKEN,
            //     },
            //   })
            //   .json();
            const { roomId } = result;
            console.log(result);
            const args = [
              3600 * duration,
              BigNumber.from(price).mul(1e8).div(3600).toNumber(),
              roomId,
            ];

            const payload = {
              type: "entry_function_payload",
              function: `${CONTRACT_ADDRESS}::create_session`,
              type_arguments: ["0x1::aptos_coin::AptosCoin"],
              arguments: args,
            };
            // const payload = {
            //   type: "entry_function_payload",
            //   function: `${CONTRACT_ADDRESS}::close_session`,
            //   type_arguments: ["0x1::aptos_coin::AptosCoin"],
            //   arguments: [account.address],
            // };
            const response = await signAndSubmitTransaction(payload);
            // if you want to wait for transaction
            await aptosClient.waitForTransaction(response?.hash || "");
            console.log(response, response?.hash);
            navigate(`/room/${roomId}`);
          } catch (e) {
            toastError(e);
          } finally {
            setLoading(false);
          }
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
