import { Bill, Client } from "../../utils/types";
import { formatCurrency, formatDate } from "../../utils/status";
import StatusBadge from "./StatusBadge";

type Props = {
  bills: Bill[];
  clients: Client[];
};

const COLUMNS = [
  { label: "Factura" },
  { label: "Cliente" },
  { label: "Ciudad" },
  { label: "Subtotal", numeric: true },
  { label: "IVA", numeric: true },
  { label: "Retención", numeric: true },
  { label: "Total", numeric: true },
  { label: "Creación" },
  { label: "Estado" },
  { label: "Pago" },
];

const BillTable = ({ bills, clients }: Props) => {
  const clientsById = new Map(clients.map((client) => [client.id, client]));
  const cell = "px-4 py-3 whitespace-nowrap";
  const numericCell = `${cell} text-right tabular-nums`;

  if (bills.length === 0) {
    return (
      <div className="rounded-xl border border-slate-200 bg-white px-4 py-12 text-center text-sm text-slate-500">
        No hay facturas que coincidan con los filtros.
      </div>
    );
  }

  return (
    <>
      {/* Móvil: una tarjeta por factura */}
      <ul className="space-y-3 md:hidden">
        {bills.map((bill) => {
          const client = clientsById.get(bill.clientId ?? "");
          return (
            <li key={bill.id} className="rounded-xl border border-slate-200 bg-white p-4">
              <div className="flex items-start justify-between gap-3">
                <div className="min-w-0">
                  <p className="font-semibold">{bill.billCode}</p>
                  <p className="truncate text-sm text-slate-600">{client?.name ?? "—"}</p>
                  <p className="text-xs text-slate-500">NIT {client?.nit ?? "—"}</p>
                </div>
                <StatusBadge value={bill.status} />
              </div>
              <div className="mt-3 flex items-end justify-between border-t border-slate-100 pt-3">
                <div className="text-xs text-slate-500">
                  <p>{bill.city || "—"} · {formatDate(bill.creationDate)}</p>
                  <p className="mt-0.5">
                    Subtotal {formatCurrency(bill.subtotal)} · IVA {formatCurrency(bill.vat)}
                  </p>
                </div>
                <p className="text-lg font-semibold tabular-nums">{formatCurrency(bill.billTotal)}</p>
              </div>
            </li>
          );
        })}
      </ul>

      {/* Escritorio: tabla */}
      <div className="hidden overflow-hidden rounded-xl border border-slate-200 bg-white md:block">
        <div className="overflow-x-auto">
          <table className="min-w-full text-sm">
            <thead className="bg-slate-50 text-xs font-medium uppercase tracking-wide text-slate-500">
              <tr>
                {COLUMNS.map((column) => (
                  <th key={column.label} className={`${cell} ${column.numeric ? "text-right" : "text-left"}`}>
                    {column.label}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {bills.map((bill) => {
                const client = clientsById.get(bill.clientId ?? "");
                return (
                  <tr key={bill.id} className="hover:bg-slate-50">
                    <td className={`${cell} font-medium`}>{bill.billCode}</td>
                    <td className={cell}>
                      <p className="font-medium">{client?.name ?? "—"}</p>
                      <p className="text-xs text-slate-500">NIT {client?.nit ?? "—"}</p>
                    </td>
                    <td className={`${cell} text-slate-600`}>{bill.city || "—"}</td>
                    <td className={`${numericCell} text-slate-600`}>{formatCurrency(bill.subtotal)}</td>
                    <td className={`${numericCell} text-slate-600`}>{formatCurrency(bill.vat)}</td>
                    <td className={`${numericCell} text-slate-600`}>{formatCurrency(bill.withholding)}</td>
                    <td className={`${numericCell} font-semibold`}>{formatCurrency(bill.billTotal)}</td>
                    <td className={`${cell} text-slate-600`}>{formatDate(bill.creationDate)}</td>
                    <td className={cell}>
                      <StatusBadge value={bill.status} />
                    </td>
                    <td className={cell}>
                      {bill.isPaid ? (
                        <span className="text-emerald-700">Pagada · {formatDate(bill.paymentDate)}</span>
                      ) : (
                        <span className="text-slate-500">Pendiente</span>
                      )}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>
    </>
  );
};

export default BillTable;
