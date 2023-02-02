import React from "react";

export default function TokenBoxItem(data) {
  const { detail, image, title } = data;

  return (
    <div className="mx-3 flex h-[220px] w-full max-w-[360px] flex-col justify-start bg-option-border p-5 mobile:mx-0 mobile:h-[300px] mobile:w-[300px]">
      <img
        src={image}
        className="h-[40px] w-[40px] mobile:h-[40px] mobile:w-[40px]"
        alt=""
      />
      <div className=" text-2xl font-normal mobile:mt-2">{title}</div>
      <div className="mt-3 flex justify-end text-lg text-secondary">
        {detail}
      </div>
    </div>
  );
}
