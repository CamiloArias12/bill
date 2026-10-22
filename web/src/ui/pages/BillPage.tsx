import { useCallback, useEffect, useState } from "react";

import BillTable from "../components/BillTable";
import BillSummary from "../components/BillSummary";
import ReminderResults from "../components/ReminderResults";
import { Bill, Client, ReminderResult } from "../../utils/types";
import { BillStatusValue, findStatus } from "../../utils/status";
import {
  billAllGetService,
  clientAllGetService,
  processRemindersService,
} from "../../services/services";

const BillPage = () => {
  const [bills, setBills] = useState<Bill[]>([]);
  const [clients, setClients] = useState<Client[]>([]);
  const [clientId, setClientId] = useState("");
  const [status, setStatus] = useState<BillStatusValue | null>(null);
  const [search, setSearch] = useState("");
  const [results, setResults] = useState<ReminderResult[] | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    try {
      const [dataBills, dataClients] = await Promise.all([billAllGetService(), clientAllGetService()]);
      setBills(dataBills);
      setClients(dataClients);
      setError(null);
    } catch (e) {
      setError(`No se pudo cargar la información: ${(e as Error).message}`);
    }
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  const processReminders = async () => {
    setLoading(true);
    try {
      setResults(await processRemindersService(clientId || undefined));
      await load();
    } catch (e) {
      setError(`No se pudo ejecutar el proceso: ${(e as Error).message}`);
    } finally {
      setLoading(false);
    }
  };

  const clientBills = clientId ? bills.filter((bill) => bill.clientId === clientId) : bills;
  const term = search.trim().toLowerCase();
  const visibleBills = clientBills.filter(
    (bill) =>
      (!status || findStatus(bill.status)?.value === status) &&
      (!term || bill.billCode.toLowerCase().includes(term) || bill.city?.toLowerCase().includes(term)),
  );
  const selectedClient = clients.find((client) => client.id === clientId);

  return (
    <div className="min-h-screen">
      <header className="border-b border-slate-200 bg-white">
        <div className="mx-auto flex max-w-7xl flex-col gap-4 px-4 py-4 sm:flex-row sm:items-center sm:px-6">
          <div className="flex items-center gap-3 sm:mr-auto">
            <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-indigo-600 text-white">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="h-5 w-5">
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                <path d="M14 2v6h6M8 13h8M8 17h5" />
              </svg>
            </div>
            <div>
              <h1 className="text-lg font-semibold leading-tight">Facturas</h1>
              <p className="text-sm text-slate-500">Seguimiento de recordatorios de pago</p>
            </div>
          </div>
          <div className="flex gap-2">
            <select
              className="min-w-0 flex-1 rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-2 focus:ring-indigo-100"
              value={clientId}
              onChange={(e) => setClientId(e.target.value)}
            >
              <option value="">Todos los clientes</option>
              {clients.map((client) => (
                <option key={client.id} value={client.id}>
                  {client.name}
                </option>
              ))}
            </select>
            <button
              className="inline-flex shrink-0 items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-indigo-500 disabled:opacity-60"
              disabled={loading}
              onClick={processReminders}
            >
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="h-4 w-4">
                <path d="M22 2 11 13M22 2l-7 20-4-9-9-4z" />
              </svg>
              <span className="sm:hidden">{loading ? "Enviando..." : "Enviar"}</span>
              <span className="hidden sm:inline">
                {loading ? "Enviando..." : selectedClient ? `Enviar recordatorios a ${selectedClient.name}` : "Enviar recordatorios"}
              </span>
            </button>
          </div>
        </div>
      </header>

      <main className="mx-auto max-w-7xl space-y-6 px-4 py-6 sm:px-6">
        {error && <div className="rounded-xl border border-rose-200 bg-rose-50 p-4 text-sm text-rose-800">{error}</div>}
        <BillSummary bills={clientBills} selectedStatus={status} onSelectStatus={setStatus} />
        {results && <ReminderResults results={results} onClose={() => setResults(null)} />}
        <section className="space-y-3">
          <div className="flex flex-wrap items-center justify-between gap-3">
            <h2 className="font-semibold">
              Detalle <span className="font-normal text-slate-500">({visibleBills.length})</span>
            </h2>
            <input
              type="search"
              placeholder="Buscar por código o ciudad"
              className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm sm:w-72 focus:border-indigo-500 focus:outline-none focus:ring-2 focus:ring-indigo-100"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>
          <BillTable bills={visibleBills} clients={clients} />
        </section>
      </main>
    </div>
  );
};

export default BillPage;
