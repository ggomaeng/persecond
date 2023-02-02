import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { useParticipant } from "@videosdk.live/react-sdk";
import Button from "components/Button.js";
import { useEffect, useMemo, useRef, useState } from "react";
import ReactPlayer from "react-player";
import { useParams } from "react-router-dom";
import { useRoomStore } from "stores/room.js";
import { abbreviateAddress } from "utils/address.js";
import { aptosClient, CONTRACT_ADDRESS } from "utils/aptos.js";

export default function VideoComponent(props) {
  const micRef = useRef(null);
  const { wallet } = useParams();
  const [starting, setStarting] = useState(false);
  const { account, signAndSubmitTransaction } = useWallet();
  const { webcamStream, micStream, setQuality, webcamOn, micOn, isLocal } =
    useParticipant(props.participantId);

  const canStart = useRoomStore((state) => state.canStart);
  const { size, displayName } = props;

  useEffect(() => {
    setQuality("high");
  }, []);

  const videoStream = useMemo(() => {
    if (webcamOn && webcamStream?.track) {
      const mediaStream = new MediaStream();
      mediaStream.addTrack(webcamStream.track);
      return mediaStream;
    }
  }, [webcamStream, webcamOn]);

  useEffect(() => {
    if (micRef.current) {
      if (micOn && micStream?.track) {
        const mediaStream = new MediaStream();
        mediaStream.addTrack(micStream.track);

        micRef.current.srcObject = mediaStream;
        micRef.current
          .play()
          .catch((error) =>
            console.error("videoElem.current.play() failed", error)
          );
      } else {
        micRef.current.srcObject = null;
      }
    }
  }, [micStream, micOn]);

  return (
    <div
      key={props.participantId}
      className={`video-cover relative flex w-full flex-grow flex-col mobile:w-[calc(50%-10px)]`}
    >
      {micOn && micRef && (
        <audio ref={micRef} autoPlay muted={isLocal || !canStart} />
      )}
      {webcamOn ? (
        <ReactPlayer
          //
          playsinline // very very imp prop
          pip={false}
          light={false}
          controls={false}
          muted={true}
          playing={true}
          //
          url={videoStream}
          //
          height={"100%"}
          width={"100%"}
          onError={(err) => {
            console.log(err, "participant video error");
          }}
        />
      ) : (
        <div className="flex h-full w-full flex-grow flex-col items-center justify-center border border-primary/50">
          <div className="rounded-lg bg-primary p-2 text-sm text-bg">
            {abbreviateAddress(displayName)}
          </div>
        </div>
      )}

      <div className="absolute top-5 left-5 rounded-md bg-black px-2 py-1 text-sm text-white">
        {abbreviateAddress(displayName)}
      </div>

      {size >= 2 && !canStart && (
        <>
          {account?.address === wallet && isLocal && (
            <div className="absolute bottom-0 w-full border border-primary bg-[#170726] p-5 text-lg">
              The meeting is ready. 200 APT will be held as full-duration
              deposit for this meeting. Any remaining balance will be refunded
              to the requestee based on actual meeting time.
              <Button
                className="mt-5"
                loading={starting}
                onClick={async () => {
                  try {
                    setStarting(true);
                    const payload = {
                      type: "entry_function_payload",
                      function: `${CONTRACT_ADDRESS}::start_session`,
                      type_arguments: ["0x1::aptos_coin::AptosCoin"],
                      arguments: [], // 1 is in Octas
                    };

                    const response = await signAndSubmitTransaction(payload);
                    // if you want to wait for transaction
                    await aptosClient.waitForTransaction(response?.hash || "");
                    console.log(response, response?.hash);
                  } catch (error) {
                    console.log("error", error);
                  } finally {
                    setStarting(false);
                  }
                  // const result = await api.post("").json();
                  // const { wallet, id } = result;
                  // navigate(`/rooms/${wallet}`);
                  // console.log(result);
                }}
              >
                Start payment stream
              </Button>
            </div>
          )}

          {isLocal && wallet !== account?.address && (
            <div className="absolute bottom-0 w-full border border-primary bg-[#170726] p-5 text-lg">
              Waiting for meeting to start. Once the requestee signs the
              transaction for the payment stream, you will be able to hear each
              other.
            </div>
          )}
        </>
      )}
    </div>
  );
}
