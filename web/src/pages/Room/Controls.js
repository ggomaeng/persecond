const { useMeeting } = require("@videosdk.live/react-sdk");

export default function Controls() {
  const { leave, toggleMic, toggleWebcam } = useMeeting();
  return (
    <div>
      <button onClick={leave}>Leave</button>
      <button onClick={toggleMic}>toggleMic</button>
      <button onClick={toggleWebcam}>toggleWebcam</button>
    </div>
  );
}
