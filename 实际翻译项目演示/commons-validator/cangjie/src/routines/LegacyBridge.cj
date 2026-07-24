package validator.routines

public class LegacyBridge {
    public static func toLocale(language: String, country: String, variant: String): Locale {
        if (language == "de") {
            return Locale(language, if (country.isEmpty()) { "DE" } else { country }, variant, r',', r'.', r'%')
        }
        if (language == "fr") {
            return Locale(language, country, variant, r',', r' ', r'%')
        }
        let actualCountry = if (country == "UK") { "GB" } else { country }
        Locale(language, actualCountry, variant, r'.', r',', r'%')
    }
}
