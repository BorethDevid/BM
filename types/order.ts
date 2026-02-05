/**
 * Order interface
 * Represents a customer order
 */
export interface Order {
  id: number
  customer_name: string
  customer_email: string
  product_name?: string // Keep for backward compatibility
  quantity?: number // Keep for backward compatibility
  unit_price?: number // Keep for backward compatibility
  total_amount: number
  status: string
  channel?: string
  location?: string
  order_date?: string
  notes?: string
  created_at: string
  items?: OrderItem[] // New: array of order items
}

/**
 * Order Item interface
 * Represents an item within an order
 */
export interface OrderItem {
  id: number
  order_id: number
  product_id: number
  product_name: string
  quantity: number
  unit_price: number
  total_price: number
}
