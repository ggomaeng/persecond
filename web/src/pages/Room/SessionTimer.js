import React, { useState, useEffect } from "react";
import { toast } from "react-hot-toast";
import { useRoomStore } from "stores/room.js";
import { getHourMinuteSeconds } from "utils/numbers";

export default function SessionTimer({ delay = 0, onTick }) {
  const session = useRoomStore((state) => state.session);
  console.log(session);
  const { started_at, max_duration } = session;
  const [timeState, setTimeState] = useState({
    hours: 0,
    minutes: 0,
    seconds: 0,
  });

  const [shouldAnimate, setShouldAnimate] = useState({
    hours: false,
    minutes: false,
    seconds: false,
  });

  useEffect(() => {
    let interval;
    if (started_at && started_at !== "0") {
      console.log(started_at);
      let hours = 0;
      let minutes = 0;
      let seconds = 0;
      interval = setInterval(() => {
        const currentTime = new Date();
        const elapsed = currentTime - started_at * 1000;
        if (elapsed > max_duration * 1000) {
          console.log("should end");
          toast(
            'Session ended. Any participant can click "Finish the session" button above for the payout.',
            { icon: "👋" }
          );
          clearInterval(interval);
          return;
        }

        const { h, m, s } = getHourMinuteSeconds(Math.floor(elapsed / 1000));

        setShouldAnimate({
          hours: isEqual(hours, h),
          minutes: isEqual(minutes, m),
          seconds: isEqual(seconds, s),
        });

        hours = h;
        minutes = m;
        seconds = s;

        setTimeState({ hours, minutes, seconds });
        onTick?.(elapsed / 1000);
      }, 1000);
    }

    return () => {
      interval && clearInterval(interval);
    };
  }, [started_at]);

  function isEqual(prev, curr) {
    if (prev === curr) return false;
    return true;
  }

  return (
    <div className="flex">
      <div className={`${shouldAnimate.hours ? "animate-pop-by-sec" : ""}`}>
        {timeState.hours < 10 ? `0${timeState.hours}` : timeState.hours}
      </div>
      :
      <div className={`${shouldAnimate.minutes ? "animate-pop-by-sec" : ""}`}>
        {timeState.minutes < 10 ? `0${timeState.minutes}` : timeState.minutes}
      </div>
      :
      <div className={`${shouldAnimate.seconds ? "animate-pop-by-sec" : ""}`}>
        <div>
          {timeState.seconds < 10 ? `0${timeState.seconds}` : timeState.seconds}
        </div>
      </div>
    </div>
  );
}
