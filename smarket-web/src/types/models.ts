export enum ProductCategory {
  Food = "Food",
  Beverages = "Beverages",
  Household = "Household",
  PersonalCare = "Personal Care",
  Health = "Health",
  PetSupplies = "Pet Supplies",
  Cleaning = "Cleaning",
  Other = "Other"
}

export interface Product {
  id: string;
  name: string;
  priceLatest: number;
  lastsDays: number;
  lastPurchasedAt: Date;
  notes?: string;
  category: ProductCategory;
}

export enum Currency {
  COP = "COP",
  USD = "USD"
}

export interface AppSettings {
  id: string;
  currency: Currency;
  headsUpDays: number;
  reminderHour: number;
  budgetEnabled: boolean;
  budgetAmount: number;
  lastBudgetAlertAt?: Date;
}

// Category helpers
export const categoryIcons: Record<ProductCategory, string> = {
  [ProductCategory.Food]: "🍴",
  [ProductCategory.Beverages]: "☕",
  [ProductCategory.Household]: "🏠",
  [ProductCategory.PersonalCare]: "👤",
  [ProductCategory.Health]: "🏥",
  [ProductCategory.PetSupplies]: "🐾",
  [ProductCategory.Cleaning]: "🧹",
  [ProductCategory.Other]: "❓"
};

export const categoryColors: Record<ProductCategory, string> = {
  [ProductCategory.Food]: "green",
  [ProductCategory.Beverages]: "blue",
  [ProductCategory.Household]: "orange",
  [ProductCategory.PersonalCare]: "pink",
  [ProductCategory.Health]: "red",
  [ProductCategory.PetSupplies]: "amber",
  [ProductCategory.Cleaning]: "cyan",
  [ProductCategory.Other]: "gray"
};

// Auto-categorize function
export function categorizeProduct(productName: string): ProductCategory {
  const lowercased = productName.toLowerCase().trim();
  
  // Beverages
  const beverageKeywords = ["milk", "juice", "water", "coffee", "tea", "soda", "beer", "wine", "drink", "beverage", "cola", "latte", "smoothie", "coconut water", "sparkling", "bottle"];
  if (beverageKeywords.some(keyword => lowercased.includes(keyword))) {
    return ProductCategory.Beverages;
  }
  
  // Food
  const foodKeywords = ["bread", "rice", "pasta", "meat", "egg", "cheese", "fruit", "vegetable", "food", "chicken", "beef", "fish", "cereal", "flour", "sugar", "salt", "oil", "butter", "yogurt", "apple", "banana", "tomato", "onion", "potato", "nuts", "beans", "honey", "sauce"];
  if (foodKeywords.some(keyword => lowercased.includes(keyword))) {
    return ProductCategory.Food;
  }
  
  // Household
  const householdKeywords = ["toilet", "paper", "towel", "battery", "bulb", "tissue", "napkin", "candle", "lightbulb", "foil", "wrap", "bag", "garbage", "trash"];
  if (householdKeywords.some(keyword => lowercased.includes(keyword))) {
    return ProductCategory.Household;
  }
  
  // Personal Care
  const personalCareKeywords = ["shampoo", "soap", "toothpaste", "deodorant", "lotion", "conditioner", "body wash", "moisturizer", "sunscreen", "toothbrush", "razor", "makeup", "perfume", "nail"];
  if (personalCareKeywords.some(keyword => lowercased.includes(keyword))) {
    return ProductCategory.PersonalCare;
  }
  
  // Health
  const healthKeywords = ["vitamin", "medicine", "pill", "tablet", "supplement", "aspirin", "bandage", "first aid", "thermometer", "prescription"];
  if (healthKeywords.some(keyword => lowercased.includes(keyword))) {
    return ProductCategory.Health;
  }
  
  // Pet Supplies
  const petKeywords = ["dog", "cat", "pet", "puppy", "kitten", "leash", "collar", "litter", "cage", "carrier", "treats", "paw"];
  if (petKeywords.some(keyword => lowercased.includes(keyword))) {
    return ProductCategory.PetSupplies;
  }
  
  // Cleaning
  const cleaningKeywords = ["clean", "detergent", "bleach", "disinfectant", "sanitizer", "wipes", "scrub", "mop", "vacuum", "polish", "laundry", "fabric softener"];
  if (cleaningKeywords.some(keyword => lowercased.includes(keyword))) {
    return ProductCategory.Cleaning;
  }
  
  return ProductCategory.Other;
}
