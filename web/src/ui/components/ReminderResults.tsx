import { ReminderResult } from "../../utils/types";
import StatusBadge from "./StatusBadge";

type Props = {
  results: ReminderResult[];
  onClose: () => void;
};

const ReminderResults = ({ results, onClose }: Props) => {
  const updated = results.flatMap((r) => r.updated.map((u) => ({ ...u, clientName: r.clientName })));
  const failed = results.flatMap((r) => r.failedBillCodes);

  return (
    <div className="rounded-xl border border-emerald-200 bg-emerald-50/60 p-5">
      <div className="flex items-start justify-between gap-4">
        <div>
          <p className="font-semibold text-emerald-900">
            {updated.length === 0
              ? "No había facturas en recordatorio"
              : `Se notificaron ${updated.length} facturas`}
          </p>
          {failed.length > 0 && (
            <p className="mt-1 text-sm text-rose-700">
              {failed.length} correos no se pudieron enviar ({failed.join(", ")}); su estado no cambió.
            </p>
          )}
        </div>
        <button className="text-sm text-emerald-800 hover:underline" onClick={onClose}>
          Cerrar
        </button>
      </div>
      {updated.length > 0 && (
        <ul className="mt-4 grid gap-2 sm:grid-cols-2 lg:grid-cols-3">
          {updated.map((u) => (
            <li key={u.billCode} className="rounded-lg bg-white px-3 py-2 text-sm shadow-sm">
              <p className="font-medium">
                {u.billCode} <span className="font-normal text-slate-500">· {u.clientName}</span>
              </p>
              <div className="mt-1.5 flex flex-wrap items-center gap-1.5">
                <StatusBadge value={u.previousStatus} />
                <span className="text-slate-400">→</span>
                <StatusBadge value={u.newStatus} />
              </div>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
};

export default ReminderResults;
