import { useParticipant } from "@videosdk.live/react-sdk";
import { useEffect, useMemo, useRef } from "react";
import ReactPlayer from "react-player";
import { abbreviateAddress } from "utils/address.js";

export default function VideoComponent(props) {
  const micRef = useRef(null);
  const { webcamStream, micStream, webcamOn, micOn, isLocal } = useParticipant(
    props.participantId
  );

  const { size, displayName } = props;

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
      {micOn && micRef && <audio ref={micRef} autoPlay muted={isLocal} />}
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
        <div className="flex h-full w-full flex-grow flex-col items-center justify-center rounded-md border border-primary/50">
          <div className="rounded-lg bg-primary p-2 text-sm text-bg">
            {abbreviateAddress(displayName)}
          </div>
        </div>
      )}
    </div>
  );
}
