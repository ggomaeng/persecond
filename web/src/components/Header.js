import Button from "components/Button.js";
import React from "react";
import { Link } from "react-router-dom";

export default function Header() {
  return (
    <header className="fixed top-0 left-0 z-[999] flex w-screen items-center justify-between p-8">
      <Link to="/">
        <div className="flex items-center">
          <img className="h-8 w-8" src="/assets/logo-single@2x.png" alt="" />
          <div className="ml-[10px] rounded-full bg-primary px-2 py-1 text-xs text-black">
            Testnet
          </div>
        </div>
      </Link>
      <Link to="/launch">
        <Button className="font-bold" icon="🚀">
          Launch perSecond
        </Button>
      </Link>
    </header>
  );
}
