//
//  IAPManager.swift
//  WarrantyApp
//
//  Created by Pedro Henrique on 05/01/22.
//

import StoreKit

fileprivate struct IAPConstants {

    fileprivate static let kIAPFullVersionProductId = "br.pedroh.WarrantyApp.fullVersion"

    fileprivate static let kIAPIdentifiers = Set([kIAPFullVersionProductId])
}


class IAPManager: NSObject, ObservableObject {
    public typealias ReceiveProductsHandler = ((Result<[SKProduct], IAPManagerError>) -> Void)
    public typealias BuyProductHandler = ((Result<Bool, Error>) -> Void)

    static let shared = IAPManager()

    private override init() {
        super.init()
    }

    private var onReceiveProductsHandler: ReceiveProductsHandler?
    private var onBuyProductHandler: BuyProductHandler?

    @Published
    var totalRestoredPurchases = 0

    // MARK: General Methods
    func formattedPrice(for product: SKProduct) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price)
    }

    func startObserving() {
        SKPaymentQueue.default().add(self)
    }


    func stopObserving() {
        SKPaymentQueue.default().remove(self)
    }


    var canMakePayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }

    // MARK: Get IAP Products

    func getProducts(withHandler productsReceiveHandler: @escaping ReceiveProductsHandler) {
        // Keep the handler (closure) that will be called when requesting for
        // products on the App Store is finished.
        onReceiveProductsHandler = productsReceiveHandler

        // Initialize a product request.
        let request = SKProductsRequest(productIdentifiers: IAPConstants.kIAPIdentifiers)

        // Set self as the its delegate.
        request.delegate = self

        // Make the request.
        request.start()
    }

    // MARK: - Purchase Products

    func buy(product: SKProduct, withHandler handler: @escaping BuyProductHandler) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)

        // Keep the completion handler.
        onBuyProductHandler = handler
    }


    func restorePurchases(withHandler handler: @escaping BuyProductHandler) {
        onBuyProductHandler = handler
        totalRestoredPurchases = 0
        SKPaymentQueue.default().restoreCompletedTransactions()
    }


    // MARK: Error Enum
    enum IAPManagerError: LocalizedError {
        case noProductIDsFound
        case noProductsFound
        case paymentWasCancelled
        case productRequestFailed

        var errorDescription: String? {
            switch self {
                case .noProductIDsFound: return "No In-App Purchase product identifiers were found."
                case .noProductsFound: return "No In-App Purchases were found."
                case .productRequestFailed: return "Unable to fetch available In-App Purchase products at the moment."
                case .paymentWasCancelled: return "In-App Purchase process was cancelled."
            }
        }
    }
}

// MARK: - SKPaymentTransactionObserver
extension IAPManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { (transaction) in
            switch transaction.transactionState {
            case .purchased:
                onBuyProductHandler?(.success(true))
                SKPaymentQueue.default().finishTransaction(transaction)

            case .restored:
                totalRestoredPurchases += 1
                SKPaymentQueue.default().finishTransaction(transaction)

            case .failed:
                if let error = transaction.error as? SKError {
                    if error.code != .paymentCancelled {
                        onBuyProductHandler?(.failure(error))
                    } else {
                        onBuyProductHandler?(.failure(IAPManagerError.paymentWasCancelled))
                    }
                    print("IAP Error:", error.localizedDescription)
                }
                SKPaymentQueue.default().finishTransaction(transaction)

            case .deferred, .purchasing: break
            @unknown default: break
            }
        }
    }


    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if totalRestoredPurchases != 0 {
            onBuyProductHandler?(.success(true))
        } else {
            print("IAP: No purchases to restore!")
            onBuyProductHandler?(.success(false))
        }
    }


    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if let error = error as? SKError {
            if error.code != .paymentCancelled {
                print("IAP Restore Error:", error.localizedDescription)
                onBuyProductHandler?(.failure(error))
            } else {
                onBuyProductHandler?(.failure(IAPManagerError.paymentWasCancelled))
            }
        }
    }
}

// MARK: - SKProductsRequestDelegate
extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        // Get the available products contained in the response.
        let products = response.products

        // Check if there are any products available.
        if products.count > 0 {
            // Call the following handler passing the received products.
            onReceiveProductsHandler?(.success(products))
        } else {
            // No products were found.
            onReceiveProductsHandler?(.failure(.noProductsFound))
        }
    }


    func request(_ request: SKRequest, didFailWithError error: Error) {
        onReceiveProductsHandler?(.failure(.productRequestFailed))
    }


    func requestDidFinish(_ request: SKRequest) {
        // Implement this method OPTIONALLY and add any custom logic
        // you want to apply when a product request is finished.
    }
}
