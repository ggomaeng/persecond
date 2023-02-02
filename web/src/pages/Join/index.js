import { useWallet } from "@aptos-labs/wallet-adapter-react";
import Button from "components/Button";
import ConnectWalletButton from "components/ConnectWalletButton.js";
import Header from "components/Header";
import { useEffect, useState } from "react";
import { toast } from "react-hot-toast";
import { Link, useNavigate, useParams } from "react-router-dom";
import Webcam from "react-webcam";
import { useAppStore } from "stores/app.js";
import { abbreviateAddress } from "utils/address";
import { aptosClient, CONTRACT_ADDRESS, getSession } from "utils/aptos.js";
import { fixDecimalPlaces } from "utils/numbers.js";
import { toastError } from "utils/toasts.js";
import StepBase from "../Launch/StepBase";

export default function Join() {
  const { wallet, roomId } = useParams();
  const setFullLoading = useAppStore((state) => state.setFullLoading);
  const [data, setData] = useState({});
  const [joining, setJoining] = useState(false);
  const { signAndSubmitTransaction, network } = useWallet();
  const navigate = useNavigate();

  console.log(network);

  useEffect(() => {
    async function getRoomInfo() {
      console.log(wallet);
      setFullLoading(true);
      const session = await getSession(wallet);
      setFullLoading(false);
      setData(session);
      console.log("session", session);
    }

    if (wallet) {
      getRoomInfo();
    }
  }, []);

  console.log(data);

  return (
    <div className="my-[100px] flex flex-col items-center justify-center padded-horizontal tablet:pt-[100px]">
      <div className="flex w-[800px] max-w-full flex-col">
        <Header />
        <h1 className="text-2xl text-primary mobile:text-3xl">
          Join the perSecond meeting
        </h1>

        {data?.room_id !== roomId || !data?.room_id ? (
          <>
            <div className="mt-2 text-base text-secondary mobile:text-lg">
              This link seems to be invalid. Please check the link and try
              again.
            </div>
            <Link to="/">
              <Button className="mt-5">Go Home</Button>
            </Link>
          </>
        ) : (
          <>
            <hr className="mt-5 mb-10 border-input-border" />
            <h2 className="mt-1 text-base text-secondary mobile:text-lg">
              You have received a request for a perSecond meeting. You will be
              paid according to the rate set by the requester for the exact
              amount of time spent in the meeting.
            </h2>
            <div className="flex flex-col gap-[40px] detail:flex-row">
              <div className="flex flex-col items-center gap-[20px]">
                <div className="relative flex min-h-[300px] w-[440px] items-center justify-center overflow-hidden border border-[#2a1636]">
                  <Webcam
                    videoConstraints={{ facingMode: "user" }}
                    widith={440}
                  />
                </div>
                <div className="border-1 w-full border border-primary bg-modal-bg p-5 text-lg text-secondary">
                  <div className="text-2xl text-primary">
                    Meeting information
                  </div>
                  <div className="mt-2">
                    Price:
                    <span className="font-bold text-primary">
                      {" "}
                      {fixDecimalPlaces(data?.second_rate / 1e8, 8)} APT
                    </span>
                    <span>
                      {" "}
                      /sec (
                      {fixDecimalPlaces(
                        (data?.second_rate / 1e8) * 3600,
                        8
                      )}{" "}
                      APT/hr)
                    </span>
                  </div>
                  <div>Max duration: {data?.max_duration / 3600} hours</div>
                  <div>Requestor: {abbreviateAddress(wallet)}</div>
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
                    By making this transaction, you are agreeing to participate
                    in the meeting and receive the time-based payment.
                  </div>
                  <Button
                    className="mt-5 flex items-center justify-center font-semibold"
                    loading={joining}
                    onClick={async () => {
                      if (network?.name !== "Devnet") {
                        toast("Please switch your network to Devnet", {
                          icon: "⚠️",
                        });
                        return;
                      }
                      const payload = {
                        type: "entry_function_payload",
                        function: `${CONTRACT_ADDRESS}::join_session`,
                        type_arguments: ["0x1::aptos_coin::AptosCoin"],
                        arguments: [wallet], // 1 is in Octas
                      };

                      try {
                        setJoining(true);
                        const response = await signAndSubmitTransaction(
                          payload
                        );
                        // if you want to wait for transaction
                        await aptosClient.waitForTransaction(
                          response?.hash || ""
                        );
                        navigate(`/room/${wallet}/${data?.room_id}`);
                        console.log(response, response?.hash);
                      } catch (error) {
                        toastError(error);
                      } finally {
                        setJoining(false);
                      }
                    }}
                  >
                    Proceed to join
                  </Button>
                </StepBase>
              </div>
            </div>
          </>
        )}
      </div>
    </div>
  );
}
