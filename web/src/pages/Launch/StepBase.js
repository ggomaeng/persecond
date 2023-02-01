import React from "react";

export default function StepBase({ title, count, children }) {
  return (
    <div className="relative mb-10 flex flex-col justify-start text-secondary">
      <div className="mb-2 text-2xl text-primary">
        0{count}. {title}
      </div>
      {children}
    </div>
  );
}
