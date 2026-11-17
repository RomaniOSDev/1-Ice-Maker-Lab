import Foundation

/// Idempotent percent-encoding: valid `%XX` triplets are left intact.
enum PercentEncoder {

    /// RFC 3986 unreserved + `/:@!$'(),*`
    private static let safeScalars: Set<UnicodeScalar> = {
        var set = Set<UnicodeScalar>()
        let extras = "/:@!$'(),*"
        for s in extras.unicodeScalars {
            set.insert(s)
        }
        for c in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~".unicodeScalars {
            set.insert(c)
        }
        return set
    }()

    static func encode(_ string: String) -> String {
        var result = String()
        result.reserveCapacity(string.utf16.count)
        let scalars = Array(string.unicodeScalars)
        var i = 0
        while i < scalars.count {
            if scalars[i] == "%" ,
               i + 2 < scalars.count,
               isHex(scalars[i + 1]),
               isHex(scalars[i + 2]) {
                result.unicodeScalars.append(scalars[i])
                result.unicodeScalars.append(scalars[i + 1])
                result.unicodeScalars.append(scalars[i + 2])
                i += 3
                continue
            }

            let scalar = scalars[i]
            if safeScalars.contains(scalar) {
                result.unicodeScalars.append(scalar)
            } else {
                for byte in String(scalar).utf8 {
                    result.append(String(format: "%%%02X", byte))
                }
            }
            i += 1
        }
        return result
    }

    private static func isHex(_ scalar: UnicodeScalar) -> Bool {
        switch scalar {
        case "0"..."9", "a"..."f", "A"..."F":
            return true
        default:
            return false
        }
    }
}
