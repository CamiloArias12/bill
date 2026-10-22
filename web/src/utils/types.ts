export type Bill = {
  id: string;
  billCode: string;
  clientId?: string;
  city?: string;
  billTotal?: number;
  subtotal?: number;
  vat?: number;
  withholding?: number;
  creationDate: string;
  status?: string;
  isPaid?: boolean;
  paymentDate?: string;
};

export type Client = {
  id: string;
  name: string;
  nit: string;
  email: string;
};

export type BillTransition = {
  billCode: string;
  previousStatus: string;
  newStatus: string;
};

export type ReminderResult = {
  clientId: string;
  clientName: string;
  updated: BillTransition[];
  failedBillCodes: string[];
};
