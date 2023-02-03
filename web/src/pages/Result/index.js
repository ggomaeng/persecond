import React from "react";
import Button from "components/Button";
import Host from "./Host";
import Expert from "./Expert";
import { Link } from "react-router-dom";
import FadeInComponent from "components/FadeInComponent";

export default function HostResult() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center py-[40px] pb-[200px] padded-horizontal">
      <Link to="/">
        <Button className="flex w-[200px] justify-center">Go home</Button>
      </Link>
      <FadeInComponent>
        <div className="mt-10 flex flex-col items-center border border-[#4a4a4a] bg-modal-bg py-15 px-10 text-center tablet:w-[480px]">
          <img className="w-[80px]" src="/assets/logo-single@2x.png" alt="" />
          {/* {true ? <Host /> : <Expert />} */}
          <Expert />
        </div>
      </FadeInComponent>
    </div>
  );
}
