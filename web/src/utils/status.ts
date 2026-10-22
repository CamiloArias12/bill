export const BILL_STATUSES = [
  { value: "primerrecordatorio", label: "Primer recordatorio", className: "bg-amber-100 text-amber-800" },
  { value: "segundorecordatorio", label: "Segundo recordatorio", className: "bg-orange-100 text-orange-800" },
  { value: "desactivado", label: "Desactivado", className: "bg-red-100 text-red-800" },
] as const;

export function findStatus(value?: string) {
  return BILL_STATUSES.find((s) => s.value === value?.trim().toLowerCase());
}

export function formatCurrency(value?: number) {
  return value == null
    ? "N/A"
    : value.toLocaleString("es-CO", { style: "currency", currency: "COP", maximumFractionDigits: 0 });
}
