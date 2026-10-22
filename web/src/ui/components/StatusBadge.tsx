import { findStatus } from "../../utils/status";

const StatusBadge = ({ value }: { value?: string }) => {
  const status = findStatus(value);
  return (
    <span
      className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-xs font-medium ring-1 ring-inset whitespace-nowrap ${
        status?.badge ?? "bg-slate-50 text-slate-600 ring-slate-200"
      }`}
    >
      <span className={`h-1.5 w-1.5 rounded-full ${status?.dot ?? "bg-slate-400"}`} />
      {status?.label ?? value ?? "Sin estado"}
    </span>
  );
};

export default StatusBadge;
