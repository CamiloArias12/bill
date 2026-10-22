import { ReminderResult } from "../../utils/types";
import { findStatus } from "../../utils/status";

type Props = {
  results: ReminderResult[];
};

const ReminderResults = ({ results }: Props) => {
  const updated = results.flatMap((r) => r.updated.map((u) => ({ ...u, clientName: r.clientName })));
  const failed = results.flatMap((r) => r.failedBillCodes);

  return (
    <div className="bg-white rounded-lg p-4 shadow-sm text-sm">
      <p className="font-bold mb-2">
        Resultado del proceso: {updated.length} facturas actualizadas
        {failed.length > 0 && <span className="text-red-700">, {failed.length} con error de envío</span>}
      </p>
      {updated.length === 0 && <p className="text-gray-500">No había facturas en recordatorio.</p>}
      <ul className="space-y-1">
        {updated.map((u) => (
          <li key={u.billCode}>
            {u.billCode} ({u.clientName}): {findStatus(u.previousStatus)?.label} → {findStatus(u.newStatus)?.label}
          </li>
        ))}
        {failed.map((code) => (
          <li key={code} className="text-red-700">
            {code}: no se pudo enviar el correo, el estado no cambió
          </li>
        ))}
      </ul>
    </div>
  );
};

export default ReminderResults;
