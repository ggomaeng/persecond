import Landing from "pages/Landing/index.js";
import Launch from "pages/Launch/index.js";
import Join from "pages/Join/index.js";
import { createBrowserRouter, RouterProvider } from "react-router-dom";
import Result from "pages/Result/index.js";
import Room from "pages/Room/index.js";

const router = createBrowserRouter([
  {
    path: "/",
    element: <Landing />,
  },
  {
    path: "/launch",
    element: <Launch />,
  },
  {
    path: "/join/:roomId",
    element: <Join />,
  },
  {
    path: "/result",
    element: <Result />,
  },
  {
    path: "/room/:roomId",
    element: <Room />,
  },
]);

export default function Router() {
  return <RouterProvider router={router} />;
}
