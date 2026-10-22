import { Bill, Client } from "../../utils/types";
import { findStatus, formatCurrency } from "../../utils/status";

type Props = {
  bills: Bill[];
  clients: Client[];
};

const HEADERS = [
  "Codigo factura",
  "Cliente",
  "Nit",
  "Ciudad",
  "Total Factura",
  "Subtotal",
  "Iva",
  "Retencion",
  "Fecha de creacion",
  "Estado",
  "Pagada",
  "Fecha de pago",
];

const formatDate = (value?: string) => (value ? new Date(value).toLocaleDateString() : "N/A");

const BillTable = ({ bills, clients }: Props) => {
  const clientsById = new Map(clients.map((client) => [client.id, client]));
  const classNameRow = "px-4 py-2 border-b whitespace-nowrap";

  return (
    <div className="overflow-auto bg-white rounded-lg shadow-sm">
      <table className="min-w-full text-sm">
        <thead>
          <tr>
            {HEADERS.map((header) => (
              <th key={header} className="px-4 py-2 border-b-2 border-b-black font-bold uppercase text-left whitespace-nowrap">
                {header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {bills.map((bill) => {
            const client = clientsById.get(bill.clientId ?? "");
            const status = findStatus(bill.status);
            return (
              <tr key={bill.id} className="hover:bg-gray-100">
                <td className={classNameRow}>{bill.billCode}</td>
                <td className={classNameRow}>{client?.name ?? "N/A"}</td>
                <td className={classNameRow}>{client?.nit ?? "N/A"}</td>
                <td className={classNameRow}>{bill.city || "N/A"}</td>
                <td className={classNameRow}>{formatCurrency(bill.billTotal)}</td>
                <td className={classNameRow}>{formatCurrency(bill.subtotal)}</td>
                <td className={classNameRow}>{formatCurrency(bill.vat)}</td>
                <td className={classNameRow}>{formatCurrency(bill.withholding)}</td>
                <td className={classNameRow}>{formatDate(bill.creationDate)}</td>
                <td className={classNameRow}>
                  <span className={`px-2 py-1 rounded-full whitespace-nowrap ${status?.className ?? "bg-gray-100"}`}>
                    {status?.label ?? bill.status ?? "N/A"}
                  </span>
                </td>
                <td className={classNameRow}>{bill.isPaid ? "Si" : "No"}</td>
                <td className={classNameRow}>{formatDate(bill.paymentDate)}</td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
};

export default BillTable;
