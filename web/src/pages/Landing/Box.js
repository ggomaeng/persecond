import FadeInComponent from "components/FadeInComponent";
import React from "react";

export default function Box(data) {
  const { detail, image, title } = data;

  return (
    <FadeInComponent>
      <div className="mx-3 flex h-[220px] w-full max-w-[360px] flex-col justify-start bg-option-border p-5 mobile:mx-0 mobile:h-[300px] mobile:w-[300px]">
        <img
          src={image}
          className="h-[30px] w-[30px] mobile:h-[40px] mobile:w-[40px]"
          alt=""
        />
        <div className="mt-2 text-xl font-normal mobile:text-2xl">{title}</div>
        <div className="mt-3 flex justify-end text-base text-secondary mobile:text-lg">
          {detail}
        </div>
      </div>
    </FadeInComponent>
  );
}
