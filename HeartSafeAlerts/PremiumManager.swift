import Foundation
import StoreKit

@MainActor
class PremiumManager: ObservableObject {
    @Published var isPremium = false
    @Published var products: [Product] = []
    @Published var purchaseInProgress = false
    @Published var errorMessage: String?
    @Published var isLoadingProducts = false
    
    private var purchaseTask: Task<Void, Never>?
    private var updateListenerTask: Task<Void, Never>?
    
    init() {
        // Check stored purchase state immediately
        isPremium = UserDefaults.standard.bool(forKey: "isPremium")
        
        // Start listening for transactions
        updateListenerTask = listenForTransactions()
        
        // Load products
        Task {
            await loadProducts()
            await updatePurchaseStatus()
        }
    }
    
    deinit {
        purchaseTask?.cancel()
        updateListenerTask?.cancel()
    }
    
    private func listenForTransactions() -> Task<Void, Never> {
        return Task.detached {
            // Listen for transaction updates
            for await result in Transaction.updates {
                await self.handleTransactionUpdate(result)
            }
        }
    }
    
    private func handleTransactionUpdate(_ result: VerificationResult<Transaction>) async {
        switch result {
        case .verified(let transaction):
            // Update purchase status
            if transaction.productID == Constants.premiumProductIdentifier {
                await MainActor.run {
                    self.isPremium = true
                    UserDefaults.standard.set(true, forKey: "isPremium")
                    UserDefaults.standard.set(Date(), forKey: Constants.premiumPurchaseDateKey)
                }
            }
            
            // Always finish transactions
            await transaction.finish()
            
        case .unverified(_, let error):
            // Log error but don't show to user
            print("Transaction verification failed: \(error)")
        }
    }
    
    func loadProducts() async {
        await MainActor.run {
            isLoadingProducts = true
            errorMessage = nil
        }
        
        do {
            products = try await Product.products(for: [Constants.premiumProductIdentifier])
            await MainActor.run {
                isLoadingProducts = false
            }
        } catch {
            await MainActor.run {
                isLoadingProducts = false
                errorMessage = "Unable to load products. Please try again later."
                print("Failed to load products: \(error)")
            }
        }
    }
    
    func purchase() async {
        guard let product = products.first else {
            await MainActor.run {
                errorMessage = "Product not available. Please try again."
            }
            return
        }
        
        await MainActor.run {
            purchaseInProgress = true
            errorMessage = nil
        }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    await MainActor.run {
                        isPremium = true
                        UserDefaults.standard.set(true, forKey: "isPremium")
                        UserDefaults.standard.set(Date(), forKey: Constants.premiumPurchaseDateKey)
                        purchaseInProgress = false
                    }
                    
                case .unverified(_, let error):
                    await MainActor.run {
                        errorMessage = "Purchase could not be verified. Please try again."
                        purchaseInProgress = false
                    }
                    print("Purchase verification failed: \(error)")
                }
                
            case .userCancelled:
                await MainActor.run {
                    purchaseInProgress = false
                }
                
            case .pending:
                await MainActor.run {
                    errorMessage = "Purchase is pending. Please check back later."
                    purchaseInProgress = false
                }
                
            @unknown default:
                await MainActor.run {
                    errorMessage = "Unknown error occurred. Please try again."
                    purchaseInProgress = false
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                purchaseInProgress = false
            }
        }
    }
    
    func restorePurchases() async {
        await MainActor.run {
            purchaseInProgress = true
            errorMessage = nil
        }
        
        do {
            // This will trigger transaction updates for any existing purchases
            try await AppStore.sync()
            
            // Check current entitlements
            await updatePurchaseStatus()
            
            await MainActor.run {
                purchaseInProgress = false
                if !isPremium {
                    errorMessage = "No previous purchases found."
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = "Unable to restore purchases. Please try again."
                purchaseInProgress = false
            }
        }
    }
    
    func updatePurchaseStatus() async {
        var hasPremium = false
        
        // Check current entitlements
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if transaction.productID == Constants.premiumProductIdentifier {
                    hasPremium = true
                }
            case .unverified(_, _):
                // Skip unverified transactions
                break
            }
        }
        
        await MainActor.run {
            self.isPremium = hasPremium
            UserDefaults.standard.set(hasPremium, forKey: "isPremium")
        }
    }
    
    var localizedPrice: String {
        guard let product = products.first else {
            return Constants.premiumPrice
        }
        return product.displayPrice
    }
}
