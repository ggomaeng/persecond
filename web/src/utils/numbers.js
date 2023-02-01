export function fixDecimalPlaces(num, places) {
  return Number(num).toFixed(places);
  // return num.toLocaleString("en-US", {
  //   fractionalDigits: places,
  // });
}
