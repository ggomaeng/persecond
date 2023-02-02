import ky from "ky";
console.log(process.env);

export const api = ky.create({
  prefixUrl: "https://api.videosdk.live/v2/rooms",
  headers: {
    "Content-Type": "application/json",
    Authorization: process.env.REACT_APP_VIDEOSDK_TOKEN,
  },
});

export const serverApi = ky.create({
  prefixUrl: "http://localhost:9000",
  headers: {
    "Content-Type": "application/json",
  },
});
