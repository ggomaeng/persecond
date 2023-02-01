import Header from "components/Header.js";
import React from "react";
import LandingSectionOne from "./LandingSectionOne.js";
import LandingSectionTwo from "./LandingSectionTwo";

export default function Landing() {
  return (
    <div>
      <Header />
      <LandingSectionOne />
      <LandingSectionTwo />
    </div>
  );
}
