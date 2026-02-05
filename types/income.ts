/**
 * Income Record interface
 * Represents an income transaction
 */
export interface IncomeRecord {
  id: number
  income_date: string
  category: string
  description: string
  order_id?: number
  amount: number
  cost: number
  profit: number
  source?: string
  payment_method?: string
  payment_status: string
  reference_number?: string
  notes?: string
  created_at: string
}
