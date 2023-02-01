import Landing from "pages/Landing/index.js";
import Launch from "pages/Launch/index.js";
import { createBrowserRouter, RouterProvider } from "react-router-dom";

const router = createBrowserRouter([
  {
    path: "/",
    element: <Landing />,
  },
  {
    path: "/launch",
    element: <Launch />,
  },
]);

export default function Router() {
  return <RouterProvider router={router} />;
}
