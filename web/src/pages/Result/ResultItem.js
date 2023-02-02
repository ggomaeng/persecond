import React from "react";

export default function ResultItem({ title, children }) {
  return (
    <div className="flex w-full flex-col items-start border border-option-border p-3 text-secondary">
      <div className="mb-2 text-lg text-secondary">{title}</div>
      <div className="self-end text-end">{children}</div>
    </div>
  );
}
