import { Bill } from "../../utils/types";
import { BILL_STATUSES, BillStatusValue, findStatus, formatCurrency } from "../../utils/status";

type Props = {
  bills: Bill[];
  selectedStatus: BillStatusValue | null;
  onSelectStatus: (status: BillStatusValue | null) => void;
};

const sum = (bills: Bill[]) => bills.reduce((total, bill) => total + (bill.billTotal ?? 0), 0);

const BillSummary = ({ bills, selectedStatus, onSelectStatus }: Props) => {
  const cardBase = "rounded-xl border bg-white p-5 text-left transition hover:shadow-md";

  return (
    <div className="grid grid-cols-2 gap-4 md:grid-cols-4">
      <button
        className={`${cardBase} ${selectedStatus === null ? "border-indigo-500 ring-2 ring-indigo-100" : "border-slate-200"}`}
        onClick={() => onSelectStatus(null)}
      >
        <p className="text-sm font-medium text-slate-500">Todas las facturas</p>
        <p className="mt-2 text-3xl font-semibold tracking-tight">{bills.length}</p>
        <p className="mt-1 text-sm text-slate-500">{formatCurrency(sum(bills))}</p>
      </button>
      {BILL_STATUSES.map((status) => {
        const statusBills = bills.filter((bill) => findStatus(bill.status)?.value === status.value);
        const selected = selectedStatus === status.value;
        return (
          <button
            key={status.value}
            className={`${cardBase} ${selected ? "border-indigo-500 ring-2 ring-indigo-100" : "border-slate-200"}`}
            onClick={() => onSelectStatus(selected ? null : status.value)}
          >
            <p className="flex items-center gap-2 text-sm font-medium text-slate-500">
              <span className={`h-2 w-2 rounded-full ${status.dot}`} />
              {status.label}
            </p>
            <p className="mt-2 text-3xl font-semibold tracking-tight">{statusBills.length}</p>
            <p className="mt-1 text-sm text-slate-500">{formatCurrency(sum(statusBills))}</p>
          </button>
        );
      })}
    </div>
  );
};

export default BillSummary;
