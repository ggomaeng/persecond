export function abbreviateAddress(address, length = 6) {
  if (!address) return;
  if (address === "Guest") return "Guest";
  let start = address.substring(0, length);
  let end = address.substring(address.length - length);

  let result = start + "..." + end;

  return result;
}
