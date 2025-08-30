import type { Product, AppSettings } from '../types/models';
import { Currency, ProductCategory } from '../types/models';

const STORAGE_KEYS = {
  PRODUCTS: 'smarket_products',
  SETTINGS: 'smarket_settings'
};

// Default settings
const DEFAULT_SETTINGS: AppSettings = {
  id: 'default',
  currency: Currency.COP,
  headsUpDays: 2,
  reminderHour: 9,
  budgetEnabled: false,
  budgetAmount: 0,
  lastBudgetAlertAt: undefined
};

// Storage service
export class StorageService {
  // Products
  static getProducts(): Product[] {
    if (typeof window === 'undefined') return [];
    
    const stored = localStorage.getItem(STORAGE_KEYS.PRODUCTS);
    if (!stored) return [];
    
    try {
      const products = JSON.parse(stored) as Product[];
      // Convert date strings back to Date objects
      return products.map(p => ({
        ...p,
        lastPurchasedAt: new Date(p.lastPurchasedAt)
      }));
    } catch {
      return [];
    }
  }
  
  static saveProducts(products: Product[]): void {
    if (typeof window === 'undefined') return;
    localStorage.setItem(STORAGE_KEYS.PRODUCTS, JSON.stringify(products));
  }
  
  static addProduct(product: Product): void {
    const products = this.getProducts();
    products.push(product);
    this.saveProducts(products);
  }
  
  static updateProduct(id: string, updates: Partial<Product>): void {
    const products = this.getProducts();
    const index = products.findIndex(p => p.id === id);
    
    if (index !== -1) {
      products[index] = { ...products[index], ...updates };
      this.saveProducts(products);
    }
  }
  
  static deleteProduct(id: string): void {
    const products = this.getProducts();
    const filtered = products.filter(p => p.id !== id);
    this.saveProducts(filtered);
  }
  
  static getProduct(id: string): Product | null {
    const products = this.getProducts();
    return products.find(p => p.id === id) || null;
  }
  
  // Settings
  static getSettings(): AppSettings {
    if (typeof window === 'undefined') return DEFAULT_SETTINGS;
    
    const stored = localStorage.getItem(STORAGE_KEYS.SETTINGS);
    if (!stored) return DEFAULT_SETTINGS;
    
    try {
      const settings = JSON.parse(stored) as AppSettings;
      // Convert date strings back to Date objects if present
      if (settings.lastBudgetAlertAt) {
        settings.lastBudgetAlertAt = new Date(settings.lastBudgetAlertAt);
      }
      return settings;
    } catch {
      return DEFAULT_SETTINGS;
    }
  }
  
  static saveSettings(settings: AppSettings): void {
    if (typeof window === 'undefined') return;
    localStorage.setItem(STORAGE_KEYS.SETTINGS, JSON.stringify(settings));
  }
  
  static updateSettings(updates: Partial<AppSettings>): void {
    const current = this.getSettings();
    const updated = { ...current, ...updates };
    this.saveSettings(updated);
  }
  
  // Bulk operations
  static markProductPurchased(id: string): void {
    this.updateProduct(id, { lastPurchasedAt: new Date() });
  }
  
  static markAllDuePurchased(headsUpDays: number): void {
    const products = this.getProducts();
    const now = new Date();
    now.setHours(0, 0, 0, 0);
    
    const updatedProducts = products.map(product => {
      const runOutDate = new Date(product.lastPurchasedAt);
      runOutDate.setDate(runOutDate.getDate() + product.lastsDays);
      runOutDate.setHours(0, 0, 0, 0);
      
      const days = Math.floor((runOutDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));
      
      if (days <= headsUpDays) {
        return { ...product, lastPurchasedAt: new Date() };
      }
      return product;
    });
    
    this.saveProducts(updatedProducts);
  }
  
  // Clear all data
  static clearAll(): void {
    if (typeof window === 'undefined') return;
    localStorage.removeItem(STORAGE_KEYS.PRODUCTS);
    localStorage.removeItem(STORAGE_KEYS.SETTINGS);
  }
}
