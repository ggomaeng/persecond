import useScrollFadeIn from "hooks/useScrollFadeIn";
import React from "react";

export default function FadeInComponent(props) {
  const { className, direction, duration, delay, children } = props;
  const fadeIn = useScrollFadeIn(direction, duration, delay);
  return (
    <div className={className} {...props} {...fadeIn}>
      {children}
    </div>
  );
}
