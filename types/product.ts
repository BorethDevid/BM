/**
 * Product interface
 * Represents a product in the inventory
 */
export interface Product {
  id: number
  name: string
  price: number
  stock_quantity: number
  category: string
  created_at: string
}
