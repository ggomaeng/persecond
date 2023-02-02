export function fixDecimalPlaces(num, places) {
  // return Number(num).toFixed(places);
  return num.toLocaleString("en-US", {
    maximumFractionDigits: places,
  });
}

export function aptosToDigits(str, digits = 8) {
  return fixDecimalPlaces(Number(str) / 1e8, digits);
}

export function formatHours(time) {
  if (!time) return;
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

export function getTotalSeconds(h, m, s) {
  return h * 3600 + m * 60 + s;
}

export function controlDecimal(num) {
  let decimalPlaces;

  if (num >= 1000) {
    decimalPlaces = 2;
  } else if (num >= 10) {
    decimalPlaces = 3;
  } else if (num >= 1) {
    decimalPlaces = 4;
  } else if (num >= 0.1) {
    decimalPlaces = 5;
  } else if (num >= 0.01) {
    decimalPlaces = 6;
  } else {
    decimalPlaces = 7;
  }

  return num.toLocaleString("en-US", {
    maximumFractionDigits: decimalPlaces,
  });
}
