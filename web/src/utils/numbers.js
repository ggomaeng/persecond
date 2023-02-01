export function fixDecimalPlaces(num, places) {
  // return num.toFixed(places);
  return num.toLocaleString("en-US", {
    fractionalDigits: places,
  });
}
