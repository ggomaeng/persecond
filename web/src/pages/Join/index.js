import Button from "components/Button";
import ConnectWalletButton from "components/ConnectWalletButton.js";
import Header from "components/Header";
import { BigNumber } from "ethers";
import { formatUnits } from "ethers/lib/utils.js";
import { useEffect, useState } from "react";
import ReactPlayer from "react-player";
import { useParams } from "react-router-dom";
import Webcam from "react-webcam";
import { useAppStore } from "stores/app.js";
import { abbreviateAddress } from "utils/address";
import { getSession } from "utils/aptos.js";
import { fixDecimalPlaces } from "utils/numbers.js";
import StepBase from "../Launch/StepBase";

export default function Join() {
  const { roomId } = useParams();
  const setFullLoading = useAppStore((state) => state.setFullLoading);
  const [data, setData] = useState({});

  // const data = {
  //   title: "Aptos' Mo Shaikh on the Move Moment",
  //   description:
  //     "Aptos' Mo Shaikh on the Move Moment - Messari Mainnet 2022. Libra died, but its smart-contract language lives on. Move is used by the buzziest chains of the moment, including Aptos. Its co-founder Mo Shaikh tells us why it's worth billions despite publishing its whitepaper last month.",
  //   price: 0.02,
  //   duration: 16,
  // };

  useEffect(() => {
    async function getRoomInfo() {
      console.log(roomId);
      setFullLoading(true);
      const session = await getSession(roomId);
      setFullLoading(false);
      setData(session);
      console.log("session", session);
    }

    if (roomId) {
      getRoomInfo();
    }
  }, []);

  return (
    <div className="flex min-h-screen flex-col items-center justify-center padded-horizontal">
      <div className="flex w-[800px] max-w-full flex-col">
        <Header />
        <h1 className="text-3xl text-primary">Join the perSecond meeting</h1>
        <h2 className="mt-1 text-lg text-secondary">
          You have received a request for a perSecond meeting. You will be paid
          according to the rate set by the requester for the exact amount of
          time spent in the meeting.
        </h2>
        <hr className="mt-5 mb-10 border-input-border" />
        <div className="flex flex-col gap-[40px] tablet:flex-row">
          <div className="flex flex-col gap-[20px]">
            <div className="relative flex min-h-[300px] w-[440px] items-center justify-center overflow-hidden border border-[#2a1636]">
              <Webcam videoConstraints={{ facingMode: "user" }} widith={440} />
            </div>
            <div className="border-1 w-full border border-primary bg-modal-bg p-5 text-lg text-secondary">
              <div className="text-2xl text-primary">Meeting information</div>
              <div className="mt-2">
                Price:
                <span className="font-bold text-primary">
                  {" "}
                  {fixDecimalPlaces(data?.second_rate / 1e8, 8)} APT
                </span>
                <span>
                  {" "}
                  /sec ({fixDecimalPlaces(
                    (data?.second_rate / 1e8) * 3600,
                    8
                  )}{" "}
                  APT/hr)
                </span>
              </div>
              <div>Max duration: {data?.max_duration / 3600} hours</div>
              <div>Requestor: {abbreviateAddress(roomId)}</div>
            </div>
          </div>
          <div className="flex flex-col">
            <StepBase count={1} title="Connect wallet">
              <div className="text-secondary">
                Connect your Aptos wallet to proceed
              </div>
              <ConnectWalletButton className="mt-5" />
            </StepBase>
            <StepBase count={2} title="Join the meeting">
              <div>
                By making this transaction, you are agreeing to participate in
                the meeting and receive the time-based payment.
              </div>
              <Button className="mt-5 flex items-center justify-center font-semibold">
                Proceed to join
              </Button>
            </StepBase>
          </div>
        </div>
      </div>
    </div>
  );
}
