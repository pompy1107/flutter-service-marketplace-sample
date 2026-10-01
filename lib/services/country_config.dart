class CountryConfig {
  final String code;
  final String name;
  final String phonePrefix;
  final String currencyCode;
  final String currencySymbol;

  const CountryConfig({
    required this.code,
    required this.name,
    required this.phonePrefix,
    required this.currencyCode,
    required this.currencySymbol,
  });

  static const romania = CountryConfig(
    code: 'RO',
    name: 'România',
    phonePrefix: '+40',
    currencyCode: 'RON',
    currencySymbol: 'lei',
  );

  static const unitedKingdom = CountryConfig(
    code: 'GB',
    name: 'United Kingdom',
    phonePrefix: '+44',
    currencyCode: 'GBP',
    currencySymbol: '£',
  );

  static const supportedCountries = [romania, unitedKingdom];

  static CountryConfig fromCode(String? code) {
    return supportedCountries.firstWhere(
      (country) => country.code == code,
      orElse: () => romania,
    );
  }
}
