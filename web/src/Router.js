import { createBrowserRouter, RouterProvider } from "react-router-dom";
import Landing from "./pages/Landing/index.js";

const router = createBrowserRouter([
  {
    path: "/",
    element: <Landing />,
  },
]);

export default function Router() {
  return <RouterProvider router={router} />;
}
