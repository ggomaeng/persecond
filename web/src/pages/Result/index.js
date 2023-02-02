import React, { useState, useEffect } from "react";
import Button from "components/Button";
import Host from "./Host";
import Expert from "./Expert";
import Loading from "components/Loading";
import { Link } from "react-router-dom";
import { abbreviateAddress } from "utils/address";

export default function HostResult() {
  const [isLoading, setIsLoading] = useState(true);
  const dummy = {
    title: "Aptos' Mo Shaikh on the Move Moment",
    duration: 16,
  };

  useEffect(() => {
    setTimeout(() => {
      setIsLoading(false);
    }, 3000);
  }, []);

  return (
    <div className="flex h-screen flex-col items-center justify-center padded-horizontal">
      {!isLoading ? (
        <>
          <Link to="/">
            <Button className="w-[200px]">Go home</Button>
          </Link>
          <div className="mt-10 flex w-[480px] flex-col items-center border border-[#4a4a4a] bg-modal-bg py-15 px-10 text-center">
            <img className="w-[80px]" src="/assets/logo-single@2x.png" alt="" />
            {false ? <Host /> : <Expert />}
          </div>
        </>
      ) : (
        <Loading />
      )}
    </div>
  );
}
