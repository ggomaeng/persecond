import React, { useEffect } from "react";
import "css-doodle";
import { useAppStore } from "stores/app.js";
import { useLocation } from "react-router-dom";

export default function Loading() {
  const fullLoading = useAppStore((state) => state.fullLoading);
  const setFullLoading = useAppStore((state) => state.setFullLoading);
  const location = useLocation();

  // useEffect(() => {
  //   setFullLoading(false);
  // }, [location]);

  return null;
  if (!fullLoading) return null;

  return (
    <div className="fixed top-0 left-0 z-[9999999999999] flex h-screen w-screen items-center justify-center overflow-clip bg-bg object-contain">
      <div className="absolute">
        <css-doodle use="var(--rule)"></css-doodle>
      </div>
      <img
        className="h-20 w-20 animate-pulse opacity-50"
        src="/assets/logo-single@2x.png"
        alt=""
      />
    </div>
  );
}
