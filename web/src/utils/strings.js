export function getRandomAlphabet() {
  var alphabets = "abcdefghijklmnopqrstuvwxyz";
  var randomIndex = Math.floor(Math.random() * alphabets.length);
  return alphabets[randomIndex];
}
