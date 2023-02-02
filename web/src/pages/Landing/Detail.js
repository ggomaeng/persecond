import React from "react";
import Button from "components/Button";
import Box from "./Box";

const BOX_DATA = [
  {
    image: "/assets/num-1@2x.png",
    title: "Request a meeting through a simple link.",
    detail:
      "Generate a perSecond meeting link and share it with the intended person with the time-based payment stream set.",
  },
  {
    image: "/assets/num-2@2x.png",
    title: "Pay for the meeting by the second, with ease.",
    detail:
      "Just set the desired rate for the meeting and the rest will be automatically handled by the perSecond protocol.",
  },
  {
    image: "/assets/num-3@2x.png",
    title: "Don't search for help, ask for it.",
    detail:
      "Have you found the right person to ask for help? Simply send the per-second link and have a productive meeting!",
  },
];

export default function Detail() {
  return (
    <div className="relative mt-32 flex h-screen flex-col items-center justify-center text-primary">
      <div className="flex flex-col items-center text-3xl">
        <div>
          Simply create a link for someone to join, pay them by the second via
        </div>
        <div>Aptos Blockchain.</div>
      </div>
      <div className="mt-7 text-2xl">with the break-through benefits</div>
      <div className="mt-5 flex flex-wrap justify-center gap-10">
        {BOX_DATA.map((data, index) => {
          const { image, title, detail } = data;
          return (
            <Box key={index} image={image} title={title} detail={detail} />
          );
        })}
      </div>
      <div className="mt-[120px] text-center text-2xl font-bold italic text-primary mobile:text-5xl mobile:leading-snug">
        <div>"Best resource</div>
        <div>is fast resource."</div>
      </div>
      <Button className="mt-5 flex w-[200px] items-center justify-center font-semibold text-primary">
        Begin new meeting
      </Button>
    </div>
  );
}
