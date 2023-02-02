import React, { useState, useEffect } from "react";
import { getHourMinuteSeconds } from "utils/numbers";

export default function Counter() {
  const defaultStartTime = 2 * 60 * 60 * 1000 + 30 * 60 * 1000 + 50 * 1000;
  const [timeState, setTimeState] = useState({
    hours: 2,
    minutes: 30,
    seconds: 50,
  });

  const [shouldAnimate, setShouldAnimate] = useState({
    hours: false,
    minutes: false,
    seconds: false,
  });

  useEffect(() => {
    const startTime = new Date();
    let hours = 2;
    let minutes = 30;
    let seconds = 50;

    const intervalId = setInterval(() => {
      const currentTime = new Date();
      const elapsed = currentTime - startTime + defaultStartTime;
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
    }, 1000);

    return () => clearInterval(intervalId);
  }, []);

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
