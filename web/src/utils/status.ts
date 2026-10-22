export const BILL_STATUSES = [
  { value: "primerrecordatorio", label: "Primer recordatorio", badge: "bg-amber-50 text-amber-700 ring-amber-200", dot: "bg-amber-500" },
  { value: "segundorecordatorio", label: "Segundo recordatorio", badge: "bg-orange-50 text-orange-700 ring-orange-200", dot: "bg-orange-500" },
  { value: "desactivado", label: "Desactivado", badge: "bg-rose-50 text-rose-700 ring-rose-200", dot: "bg-rose-500" },
] as const;

export type BillStatusValue = (typeof BILL_STATUSES)[number]["value"];

export function findStatus(value?: string) {
  return BILL_STATUSES.find((s) => s.value === value?.trim().toLowerCase());
}

export function formatCurrency(value?: number) {
  return value == null
    ? "—"
    : value.toLocaleString("es-CO", { style: "currency", currency: "COP", maximumFractionDigits: 0 });
}

export function formatDate(value?: string) {
  return value
    ? new Date(value).toLocaleDateString("es-CO", { day: "2-digit", month: "short", year: "numeric" })
    : "—";
}
