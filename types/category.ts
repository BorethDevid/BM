/**
 * Category interface
 * Represents a product category
 */
export interface Category {
  id: number
  name: string
  description?: string
  created_at: string
}

/**
 * Income Category interface
 * Represents a category for income records
 */
export interface IncomeCategory {
  id: number
  name: string
  description: string
  icon: string
  color: string
}
