export function fixDecimalPlaces(num, places) {
  return Number(num).toFixed(places);
  // return num.toLocaleString("en-US", {
  //   fractionalDigits: places,
  // });
}

export function formatHours(time) {
  const hours = Math.floor(time);
  const minutes = Math.floor((time - hours) * 60);
  const seconds = Math.floor(((time - hours) * 60 - minutes) * 60);

  return `${hours.toString().padStart(2, "0")}:${minutes
    .toString()
    .padStart(2, "0")}:${seconds.toString().padStart(2, "0")}`;
}

export function getHourMinuteSeconds(seconds) {
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = seconds % 60;

  return {
    h,
    m,
    s,
  };
}
