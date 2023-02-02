import React from "react";
import Button from "components/Button";
import Box from "./Box";
import FadeInComponent from "components/FadeInComponent";

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
    <div className="relative mt-10 flex h-full flex-col items-center justify-center px-3 text-primary mobile:mt-20">
      <div className="flex flex-col items-center text-center text-2xl mobile:text-3xl">
        <FadeInComponent>
          Simply create a link for someone to join, pay them by the second
        </FadeInComponent>
        <FadeInComponent>via Aptos Blockchain</FadeInComponent>
      </div>
      <div className="mt-7 text-xl mobile:text-2xl">
        with the break-through benefits
      </div>
      <div className="mt-5 flex flex-wrap justify-center gap-10">
        {BOX_DATA.map((data, index) => {
          const { image, title, detail } = data;
          return (
            <Box key={index} image={image} title={title} detail={detail} />
          );
        })}
      </div>
      <FadeInComponent className="flex flex-col items-center">
        <div className="mt-15 text-center text-2xl font-bold italic text-primary mobile:mt-[120px] mobile:text-5xl mobile:leading-snug">
          <div>"Best resource</div>
          <div>is fast resource."</div>
        </div>
        <Button className="mb-[120px] mt-10 flex w-[200px] items-center justify-center font-semibold text-primary mobile:mt-5">
          Begin new meeting
        </Button>
      </FadeInComponent>
    </div>
  );
}
