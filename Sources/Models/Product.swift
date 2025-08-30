import Foundation
import SwiftData

enum ProductCategory: String, Codable, CaseIterable, Identifiable {
    case food = "Food"
    case beverages = "Beverages"
    case household = "Household"
    case personalCare = "Personal Care"
    case health = "Health"
    case petSupplies = "Pet Supplies"
    case cleaning = "Cleaning"
    case other = "Other"
    
    var id: String { rawValue }
    
    var systemImage: String {
        switch self {
        case .food: return "fork.knife"
        case .beverages: return "cup.and.saucer"
        case .household: return "house"
        case .personalCare: return "person.crop.circle"
        case .health: return "cross.case"
        case .petSupplies: return "pawprint"
        case .cleaning: return "bubbles.and.sparkles"
        case .other: return "questionmark.circle"
        }
    }
    
    var color: String {
        switch self {
        case .food: return "green"
        case .beverages: return "blue"
        case .household: return "orange"
        case .personalCare: return "pink"
        case .health: return "red"
        case .petSupplies: return "brown"
        case .cleaning: return "cyan"
        case .other: return "gray"
        }
    }
    
    /// Automatically categorizes a product based on its name using keyword matching
    static func categorize(productName: String) -> ProductCategory {
        let lowercased = productName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Beverages
        let beverageKeywords = ["milk", "juice", "water", "coffee", "tea", "soda", "beer", "wine", "drink", "beverage", "cola", "latte", "smoothie", "coconut water", "sparkling", "bottle"]
        if beverageKeywords.contains(where: { lowercased.contains($0) }) {
            return .beverages
        }
        
        // Food
        let foodKeywords = ["bread", "rice", "pasta", "meat", "egg", "cheese", "fruit", "vegetable", "food", "chicken", "beef", "fish", "cereal", "flour", "sugar", "salt", "oil", "butter", "yogurt", "apple", "banana", "tomato", "onion", "potato", "nuts", "beans", "honey", "sauce"]
        if foodKeywords.contains(where: { lowercased.contains($0) }) {
            return .food
        }
        
        // Household
        let householdKeywords = ["toilet", "paper", "towel", "battery", "bulb", "tissue", "napkin", "candle", "lightbulb", "foil", "wrap", "bag", "garbage", "trash"]
        if householdKeywords.contains(where: { lowercased.contains($0) }) {
            return .household
        }
        
        // Personal Care
        let personalCareKeywords = ["shampoo", "soap", "toothpaste", "deodorant", "lotion", "conditioner", "body wash", "moisturizer", "sunscreen", "toothbrush", "razor", "makeup", "perfume", "nail"]
        if personalCareKeywords.contains(where: { lowercased.contains($0) }) {
            return .personalCare
        }
        
        // Health
        let healthKeywords = ["vitamin", "medicine", "pill", "tablet", "supplement", "aspirin", "bandage", "first aid", "thermometer", "prescription"]
        if healthKeywords.contains(where: { lowercased.contains($0) }) {
            return .health
        }
        
        // Pet Supplies
        let petKeywords = ["dog", "cat", "pet", "puppy", "kitten", "leash", "collar", "litter", "cage", "carrier", "treats", "paw"]
        if petKeywords.contains(where: { lowercased.contains($0) }) {
            return .petSupplies
        }
        
        // Cleaning
        let cleaningKeywords = ["clean", "detergent", "bleach", "disinfectant", "sanitizer", "wipes", "scrub", "mop", "vacuum", "polish", "laundry", "fabric softener"]
        if cleaningKeywords.contains(where: { lowercased.contains($0) }) {
            return .cleaning
        }
        
        return .other
    }
}

@Model
final class Product {
    var id: UUID
    var name: String
    var priceLatest: Double
    var lastsDays: Int
    var lastPurchasedAt: Date
    var notes: String?
    var categoryRawValue: String

    init(
        id: UUID = UUID(),
        name: String,
        priceLatest: Double,
        lastsDays: Int,
        lastPurchasedAt: Date,
        notes: String? = nil,
        category: ProductCategory = .other
    ) {
        self.id = id
        self.name = name
        self.priceLatest = priceLatest
        self.lastsDays = max(1, lastsDays)
        self.lastPurchasedAt = lastPurchasedAt
        self.notes = notes
        self.categoryRawValue = category.rawValue
    }
    
    var category: ProductCategory {
        get { ProductCategory(rawValue: categoryRawValue) ?? .other }
        set { categoryRawValue = newValue.rawValue }
    }
    
    /// Automatically categorizes this product based on its name
    func autoUpdateCategory() {
        self.category = ProductCategory.categorize(productName: name)
    }

    var nextRunOutDate: Date {
        Calendar.current.date(byAdding: .day, value: lastsDays, to: startOfDay(for: lastPurchasedAt)) ?? lastPurchasedAt
    }

    var dailyCost: Double {
        guard lastsDays > 0 else { return 0 }
        return priceLatest / Double(lastsDays)
    }

    var monthlyCostEstimate: Double {
        dailyCost * 30.0
    }

    private func startOfDay(for date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }
}


