import Foundation
import Security

enum KeychainHelper {

    private static let service = "com.desalix.Atlas"
    private static let account = "ai-api-key"

    static var apiKey: String? {
        get {
            let query: [CFString: Any] = [
                kSecClass:       kSecClassGenericPassword,
                kSecAttrService: service,
                kSecAttrAccount: account,
                kSecReturnData:  true,
                kSecMatchLimit:  kSecMatchLimitOne
            ]
            var result: AnyObject?
            guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
                  let data = result as? Data,
                  let string = String(data: data, encoding: .utf8)
            else { return nil }
            return string
        }
        set {
            let deleteQuery: [CFString: Any] = [
                kSecClass:       kSecClassGenericPassword,
                kSecAttrService: service,
                kSecAttrAccount: account
            ]
            SecItemDelete(deleteQuery as CFDictionary)

            guard let newValue, !newValue.isEmpty,
                  let data = newValue.data(using: .utf8) else { return }

            let addQuery: [CFString: Any] = [
                kSecClass:            kSecClassGenericPassword,
                kSecAttrService:      service,
                kSecAttrAccount:      account,
                kSecValueData:        data,
                kSecAttrAccessible:   kSecAttrAccessibleWhenUnlocked
            ]
            SecItemAdd(addQuery as CFDictionary, nil)
        }
    }

    static func clear() { apiKey = nil }
}
