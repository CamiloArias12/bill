import { apiGet, apiPost } from "./api";
import { Bill, Client, ReminderResult } from "../utils/types";

export function billAllGetService(): Promise<Bill[]> {
  return apiGet<Bill[]>("/api/bill");
}

export function clientAllGetService(): Promise<Client[]> {
  return apiGet<Client[]>("/api/client");
}

export function processRemindersService(clientId?: string): Promise<ReminderResult[]> {
  return clientId
    ? apiPost<ReminderResult>(`/api/bill/status/${clientId}`).then((r) => [r])
    : apiPost<ReminderResult[]>("/api/bill/status");
}
