import React from "react";
import ReactDOM from "react-dom/client";
import "./index.scss";
import App from "./App";
import reportWebVitals from "./reportWebVitals";

import Landing from "pages/Landing/index.js";
import Launch from "pages/Launch/index.js";
import Join from "pages/Join/index.js";
import {
  createBrowserRouter,
  createRoutesFromElements,
  Route,
  RouterProvider,
} from "react-router-dom";
import Result from "pages/Result/index.js";
import Room from "pages/Room/index.js";

const router = createBrowserRouter([
  {
    path: "/",
    element: <App />,
    children: [
      {
        index: true,
        element: <Landing />,
      },
      {
        path: "launch",
        element: <Launch />,
      },
      {
        path: "join/:wallet/:roomId",
        element: <Join />,
      },
      {
        path: "result/:hash",
        element: <Result />,
      },
      {
        path: "room/:wallet/:roomId",
        element: <Room />,
      },
    ],
  },
]);

export default function Router() {
  return <RouterProvider router={router} />;
}

const root = ReactDOM.createRoot(document.getElementById("root"));
// root.render(<App />);
root.render(<RouterProvider router={router} />);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
