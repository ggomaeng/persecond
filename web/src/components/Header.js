import Button from "components/Button.js";
import React from "react";
import { Link } from "react-router-dom";

export default function Header() {
  return (
    <header className="fixed top-0 left-0 z-[99999] flex w-screen justify-between p-8">
      <Link to="/">
        <img className="h-8 w-8" src="/assets/logo-single@2x.png" alt="" />
      </Link>
      <Link to="/launch">
        <Button icon="🚀">Launch perSecond</Button>
      </Link>
    </header>
  );
}
