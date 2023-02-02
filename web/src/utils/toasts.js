import { toast } from "react-hot-toast";

export function toastError(e) {
  console.error(e);
  toast.error(e.message || e);
}
