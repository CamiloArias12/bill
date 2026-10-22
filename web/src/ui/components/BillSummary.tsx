import { Bill } from "../../utils/types";
import { BILL_STATUSES, findStatus, formatCurrency } from "../../utils/status";

type Props = {
  bills: Bill[];
};

const BillSummary = ({ bills }: Props) => {
  const total = bills.reduce((sum, bill) => sum + (bill.billTotal ?? 0), 0);
  const cards = [
    { label: "Facturas", value: bills.length.toString() },
    { label: "Valor total", value: formatCurrency(total) },
    ...BILL_STATUSES.map((status) => ({
      label: status.label,
      value: bills.filter((bill) => findStatus(bill.status)?.value === status.value).length.toString(),
    })),
  ];

  return (
    <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
      {cards.map((card) => (
        <div key={card.label} className="bg-white rounded-lg p-4 shadow-sm">
          <p className="text-xs uppercase text-gray-500">{card.label}</p>
          <p className="text-2xl font-bold mt-1">{card.value}</p>
        </div>
      ))}
    </div>
  );
};

export default BillSummary;
