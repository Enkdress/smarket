import type { Product, Currency } from '../types/models';

// Product calculations
export function getNextRunOutDate(product: Product): Date {
  const purchaseDate = new Date(product.lastPurchasedAt);
  const runOutDate = new Date(purchaseDate);
  runOutDate.setDate(runOutDate.getDate() + product.lastsDays);
  return runOutDate;
}

export function getDaysUntilRunOut(product: Product): number {
  const now = new Date();
  now.setHours(0, 0, 0, 0);
  const runOutDate = getNextRunOutDate(product);
  runOutDate.setHours(0, 0, 0, 0);
  
  const diffTime = runOutDate.getTime() - now.getTime();
  return Math.floor(diffTime / (1000 * 60 * 60 * 24));
}

export function getDailyCost(product: Product): number {
  if (product.lastsDays <= 0) return 0;
  return product.priceLatest / product.lastsDays;
}

export function getMonthlyCostEstimate(product: Product): number {
  return getDailyCost(product) * 30;
}

// Date formatting
export function formatDate(date: Date | string): string {
  const d = typeof date === 'string' ? new Date(date) : date;
  return d.toLocaleDateString('en-US', { 
    month: 'short', 
    day: 'numeric', 
    year: 'numeric' 
  });
}

export function formatShortDate(date: Date | string): string {
  const d = typeof date === 'string' ? new Date(date) : date;
  return d.toLocaleDateString('en-US', { 
    month: 'short', 
    day: 'numeric' 
  });
}

// Currency formatting
export function formatCurrency(amount: number, currency: Currency): string {
  const formatter = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: currency,
    minimumFractionDigits: 0,
    maximumFractionDigits: 2,
  });
  
  return formatter.format(amount);
}

// Product status helpers
export function getProductStatus(product: Product, headsUpDays: number): 'overdue' | 'today' | 'tomorrow' | 'soon' | 'ok' {
  const days = getDaysUntilRunOut(product);
  
  if (days < 0) return 'overdue';
  if (days === 0) return 'today';
  if (days === 1) return 'tomorrow';
  if (days <= headsUpDays) return 'soon';
  return 'ok';
}

export function getStatusLabel(days: number): string {
  if (days < 0) return 'Overdue';
  if (days === 0) return 'Due today';
  if (days === 1) return 'Due tomorrow';
  return `In ${days} days`;
}

export function getStatusColor(status: 'overdue' | 'today' | 'tomorrow' | 'soon' | 'ok'): string {
  switch (status) {
    case 'overdue':
    case 'today':
      return 'red';
    case 'tomorrow':
    case 'soon':
      return 'orange';
    case 'ok':
      return 'green';
  }
}

// Sort helpers
export function sortProductsByName(products: Product[]): Product[] {
  return [...products].sort((a, b) => a.name.localeCompare(b.name));
}

export function sortProductsByDueDate(products: Product[]): Product[] {
  return [...products].sort((a, b) => {
    const dateA = getNextRunOutDate(a);
    const dateB = getNextRunOutDate(b);
    return dateA.getTime() - dateB.getTime();
  });
}

export function sortProductsByCategory(products: Product[]): Product[] {
  return [...products].sort((a, b) => {
    if (a.category !== b.category) {
      return a.category.localeCompare(b.category);
    }
    return a.name.localeCompare(b.name);
  });
}
