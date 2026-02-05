/**
 * Province interface
 * Represents a geographical location (province or city)
 */
export interface Province {
  name: string
  type: 'Province' | 'City'
  description: string
}
