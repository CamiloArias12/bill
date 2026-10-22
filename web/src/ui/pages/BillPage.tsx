import { useCallback, useEffect, useState } from "react";

import BillTable from "../components/BillTable";
import BillSummary from "../components/BillSummary";
import ReminderResults from "../components/ReminderResults";
import { Bill, Client, ReminderResult } from "../../utils/types";
import {
  billAllGetService,
  clientAllGetService,
  processRemindersService,
} from "../../services/services";

const BillPage = () => {
  const [bills, setBills] = useState<Bill[]>([]);
  const [clients, setClients] = useState<Client[]>([]);
  const [clientId, setClientId] = useState("");
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

  const visibleBills = clientId ? bills.filter((bill) => bill.clientId === clientId) : bills;

  return (
    <div className="min-h-screen bg-[#ebeff3] flex flex-col">
      <div className="border-b-2 bg-[#ebeff3] p-4 sticky top-0 z-10 flex flex-wrap items-center gap-4">
        <h1 className="text-3xl font-bold m-4 mr-auto">Facturas</h1>
        <select
          className="border rounded px-3 py-2 bg-white"
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
          className="bg-blue-600 text-white rounded px-4 py-2 disabled:opacity-50"
          disabled={loading}
          onClick={processReminders}
        >
          {loading ? "Procesando..." : "Enviar recordatorios"}
        </button>
      </div>
      <div className="p-6 space-y-6">
        {error && <div className="bg-red-100 text-red-800 rounded-lg p-4">{error}</div>}
        <BillSummary bills={visibleBills} />
        {results && <ReminderResults results={results} />}
        <BillTable bills={visibleBills} clients={clients} />
      </div>
    </div>
  );
};

export default BillPage;
