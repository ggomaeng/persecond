export default function isMobile() {
  return /iPhone|iPad|iPod|Android/i.test(window.navigator.userAgent);
}
