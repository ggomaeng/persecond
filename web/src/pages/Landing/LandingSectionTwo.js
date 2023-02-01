import React, { useState, useEffect, useReducer } from "react";
import AnimatedNumbers from "react-animated-numbers";
import { fixDecimalPlaces } from "utils/numbers";

export default function LandingSectionTwo() {
  const [num, setNum] = useState(15.11);

  useEffect(() => {
    const interval = setInterval(() => {
      setNum((prev) => prev + 0.12);
    }, 1000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="flex flex-col text-primary justify-center h-full text-center items-center">
      <div>
        <div className="text-6xl font-bold text-dark-purple">
          <Timer />
        </div>
        <div className="flex justify-center text-2xl font-bold">
          <div>$</div>
          <AnimatedNumbers
            includeComma
            animateToNumber={fixDecimalPlaces(num, 2)}
            // configs={[{ mass: 3, tension: 18, friction: 13 }]}
          ></AnimatedNumbers>
          <div className="ml-1">paid</div>
        </div>
      </div>
      <div className="text-3xl mt-15">
        Create paid conference channel in second, share via link, gets paid by
        every second using blazing fast crypto payment on Aptos blockchain.
      </div>
    </div>
  );
}

function Timer() {
  const passedTime = 2 * 60 * 60 * 1000 + 30 * 60 * 1000 + 50 * 1000;
  const [timeState, setTimeState] = useState({ hours: 2, minutes: 30, seconds: 50 });

  const [shouldAnimate, setShouldAnimate] = useState({
    hours: false,
    minutes: false,
    seconds: false,
  });

  useEffect(() => {
    const startTime = new Date();
    let hours = 2
    let minutes = 30;
    let seconds = 50;

    const intervalId = setInterval(() => {
      const currentTime = new Date();
      const elapsed = currentTime - startTime + passedTime;
       const nhours = Math.floor(elapsed / (1000 * 60 * 60));
       const nminutes = Math.floor((elapsed % (1000 * 60 * 60)) / (1000 * 60));
       const nseconds = Math.floor((elapsed % (1000 * 60)) / 1000);

       setShouldAnimate({
          hours: checkShouldAnimate(hours, nhours),
          minutes: checkShouldAnimate(nminutes, minutes),
          seconds: checkShouldAnimate(nseconds, seconds),
        });

        hours = nhours;
        minutes = nminutes;
        seconds = nseconds;



      setTimeState({ hours, minutes, seconds });
    }, 1000);
  }, []);

  function checkShouldAnimate(prev, curr) {
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
        <div>{timeState.seconds < 10 ? `0${timeState.seconds}` : timeState.seconds}</div>
      </div>
    </div>
  );
}
