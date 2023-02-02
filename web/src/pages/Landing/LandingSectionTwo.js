import React, { useState, useEffect } from "react";
import AnimatedNumbers from "react-animated-numbers";
import { fixDecimalPlaces } from "utils/numbers";
import Counter from "components/Counter";

export default function LandingSectionTwo() {
  const [num, setNum] = useState(15.11);

  useEffect(() => {
    const interval = setInterval(() => {
      setNum((prev) => prev + 0.12);
    }, 1000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="flex h-screen flex-col items-center justify-center text-center text-primary">
      <div>
        <div className="text-6xl font-bold text-dark-purple">
          <Counter />
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
      <div className="mt-15 text-3xl">
        Create paid conference channel in second, share via link, gets paid by
        every second using blazing fast crypto payment on Aptos blockchain.
      </div>
    </div>
  );
}
