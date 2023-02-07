import { useCallback, useEffect, useRef } from "react";

export default function FadeInComponent(props) {
  const { className, direction, duration, delay, children } = props;
  const fadeIn = useScrollFadeIn(direction, duration, delay);
  return (
    <div className={className} {...props} {...fadeIn}>
      {children}
    </div>
  );
}

function useScrollFadeIn(direction = "up", duration = 1, delay) {
  const dom = useRef();

  function handleDirection(name) {
    switch (name) {
      case "up":
        // return "translateY(30px)";
        return "translate3d(0, 20%, 0 )";
      case "down":
        return "translate3d(0, -20%, 0 )";
      case "left":
        return "translate3d(20%, 0, 0 )";
      case "right":
        return "translate3d(-20%, 0 , 0 )";
      default:
        return;
    }
  }

  const onScroll = useCallback(
    ([entry]) => {
      const { current } = dom;

      if (entry.isIntersecting) {
        current.style.transitionProperty = "opacity transform";
        current.style.transitionDuration = `${duration}s`;
        current.style.transitionTimingFunction = "cubic-bezier(0,0,0.2, 1) ";
        current.style.transitionDelay = `${delay || 0}s`;
        current.style.opacity = 1;
        current.style.transform = "translate3d(0,0,0)";
      }
    },
    [delay, duration]
  );

  useEffect(() => {
    let observer;
    const { current } = dom;

    if (current) {
      observer = new IntersectionObserver(onScroll, { threshold: 0.6 });
      observer.observe(current);
    }
    return () => observer && observer.disconnect();
  }, [onScroll]);

  return {
    ref: dom,
    style: {
      opacity: 0,
      transform: handleDirection(direction),
    },
  };
}
