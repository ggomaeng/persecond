import React from "react";

export default function StepBase({ title, count, children }) {
  return (
    <div className="mb-10 flex flex-col justify-start text-primary">
      <div className="mb-2 text-2xl">
        0{count}. {title}
      </div>
      {children}
    </div>
  );
}
