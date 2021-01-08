# Module:   TeamsFunctions
# Function: Helper
# Author:		David Eberhardt
# Updated:  06-DEC-2020
# Status:   RC




function Get-RegionFromCountryCode {
  <#
	.SYNOPSIS
		Ever wondered in which Region a ZW is?
	.DESCRIPTION
		Returns a Global Region or Country Name for any given CountryCode
	.PARAMETER CountryCode
		This is the CountryCode in the format ISO 3166-alpha2 (2-digit)
  .PARAMETER Output
		Optional. By Default the Region is returned.
		With this Parameter, you can get the CountryName instead.
	.EXAMPLE
		Get-RegionFromCountryCode -CountryCode UZ
		Returns Region "APAC" for CountryCode UZ ("Uzbekistan")
	.EXAMPLE
		Get-RegionFromCountryCode AW -Output Country
		Returns Country "Aruba" for CountryCode AW
	.NOTES
		CountryCode must be provided otherwise InvalidData Error will be thrown
		FullyQualifiedErrorId: ParameterArgumentValidationErrorEmptyStringNotAllowed
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
	#>

  [CmdletBinding()]
  [OutputType([System.String])]
  param (
    [Parameter(Mandatory, Position = 0, ValueFromPipeline, HelpMessage = "2-digit CountryCode")]
    [ValidatePattern("^[A-Z][A-Z]$")]
    [string]$CountryCode,

    [Parameter(HelpMessage = "Country or Region")]
    [ValidateSet("Region", "Country")]
    [String]$Output = "Region"
  )

  begin {
    $Region = $null
    $CountryName = $null
    Write-Verbose -Message "Returning $Output"
  }

  process {
    $Region, $CountryName = switch ($CountryCode) {
      "AF" { "EMEA", "Afghanistan" }
      "AX" { "EMEA", "Aaland" }
      "AL" { "EMEA", "Albania" }
      "DZ" { "EMEA", "Algeria" }
      "AS" { "APAC", "American Samoa" }
      "AD" { "EMEA", "Andorra" }
      "AO" { "EMEA", "Angola" }
      "AI" { "AMER", "Anguilla" }
      "AQ" { "APAC", "Antarctica" }
      "AG" { "AMER", "Antigua and Barbuda" }
      "AR" { "AMER", "Argentina" }
      "AM" { "EMEA", "Armenia" }
      "AW" { "AMER", "Aruba" }
      "AU" { "APAC", "Australia" }
      "AT" { "EMEA", "Austria" }
      "AZ" { "EMEA", "Azerbaijan" }
      "BS" { "AMER", "Bahamas" }
      "BH" { "EMEA", "Bahrain" }
      "BD" { "APAC", "Bangladesh" }
      "BB" { "AMER", "Barbados" }
      "BY" { "EMEA", "Belarus" }
      "BE" { "EMEA", "Belgium" }
      "BZ" { "AMER", "Belize" }
      "BJ" { "EMEA", "Benin" }
      "BM" { "AMER", "Bermuda" }
      "BT" { "APAC", "Bhutan" }
      "BO" { "AMER", "Bolivia" }
      "BQ" { "AMER", "Bonaire, Sint Eustatius and Saba" }
      "BA" { "EMEA", "Bosnia and Herzegovina" }
      "BW" { "EMEA", "Botswana" }
      "BV" { "EMEA", "Bouvet Island" }
      "BR" { "AMER", "Brazil" }
      "IO" { "APAC", "British Indian Ocean Territory" }
      "BN" { "APAC", "Brunei Darussalam" }
      "BG" { "EMEA", "Bulgaria" }
      "BF" { "EMEA", "Burkina Faso" }
      "BI" { "EMEA", "Burundi" }
      "KH" { "APAC", "Cambodia" }
      "CM" { "EMEA", "Cameroon" }
      "CA" { "AMER", "Canada" }
      "CV" { "EMEA", "Cape Verde" }
      "KY" { "AMER", "Cayman Islands" }
      "CF" { "EMEA", "Central African Republic" }
      "TD" { "EMEA", "Chad" }
      "CL" { "AMER", "Chile" }
      "CN" { "APAC", "China" }
      "CX" { "APAC", "Christmas Island" }
      "CC" { "APAC", "Cocos (Keeling) Islands" }
      "CO" { "AMER", "Colombia" }
      "KM" { "EMEA", "Comoros" }
      "CG" { "EMEA", "Congo (Brazzaville)" }
      "CD" { "EMEA", "Congo (Kinshasa)" }
      "CK" { "APAC", "Cook Islands" }
      "CR" { "AMER", "Costa Rica" }
      "CI" { "EMEA", "C?te d'Ivoire" }
      "HR" { "EMEA", "Croatia" }
      "CU" { "AMER", "Cuba" }
      "CW" { "AMER", "Curacao" }
      "CY" { "EMEA", "Cyprus" }
      "CZ" { "EMEA", "Czech Republic" }
      "DK" { "EMEA", "Denmark" }
      "DJ" { "EMEA", "Djibouti" }
      "DM" { "AMER", "Dominica" }
      "DO" { "AMER", "Dominican Republic" }
      "EC" { "AMER", "Ecuador" }
      "EG" { "EMEA", "Egypt" }
      "SV" { "AMER", "El Salvador" }
      "GQ" { "EMEA", "Equatorial Guinea" }
      "ER" { "EMEA", "Eritrea" }
      "EE" { "EMEA", "Estonia" }
      "ET" { "EMEA", "Ethiopia" }
      "FK" { "EMEA", "Falkland Islands" }
      "FO" { "EMEA", "Faroe Islands" }
      "FJ" { "APAC", "Fiji" }
      "FI" { "EMEA", "Finland" }
      "FR" { "EMEA", "France" }
      "GF" { "AMER", "French Guiana" }
      "PF" { "APAC", "French Polynesia" }
      "TF" { "APAC", "French Southern Lands" }
      "GA" { "EMEA", "Gabon" }
      "GM" { "EMEA", "Gambia" }
      "GE" { "EMEA", "Georgia" }
      "DE" { "EMEA", "Germany" }
      "GH" { "EMEA", "Ghana" }
      "GI" { "EMEA", "Gibraltar" }
      "GR" { "EMEA", "Greece" }
      "GL" { "EMEA", "Greenland" }
      "GD" { "AMER", "Grenada" }
      "GP" { "AMER", "Guadeloupe" }
      "GU" { "APAC", "Guam" }
      "GT" { "AMER", "Guatemala" }
      "GG" { "EMEA", "Guernsey" }
      "GN" { "EMEA", "Guinea" }
      "GW" { "EMEA", "Guinea-Bissau" }
      "GY" { "AMER", "Guyana" }
      "HT" { "AMER", "Haiti" }
      "HM" { "APAC", "Heard and McDonald Islands" }
      "HN" { "AMER", "Honduras" }
      "HK" { "APAC", "Hong Kong" }
      "HU" { "EMEA", "Hungary" }
      "IS" { "EMEA", "Iceland" }
      "IN" { "APAC", "India" }
      "ID" { "APAC", "Indonesia" }
      "IR" { "EMEA", "Iran" }
      "IQ" { "EMEA", "Iraq" }
      "IE" { "EMEA", "Ireland" }
      "IM" { "EMEA", "Isle of Man" }
      "IL" { "EMEA", "Israel" }
      "IT" { "EMEA", "Italy" }
      "JM" { "AMER", "Jamaica" }
      "JP" { "APAC", "Japan" }
      "JE" { "EMEA", "Jersey" }
      "JO" { "EMEA", "Jordan" }
      "KZ" { "EMEA", "Kazakhstan" }
      "KE" { "EMEA", "Kenya" }
      "KI" { "APAC", "Kiribati" }
      "KP" { "EMEA", "Korea, North" }
      "KR" { "EMEA", "Korea, South" }
      "KW" { "EMEA", "Kuwait" }
      "KG" { "APAC", "Kyrgyzstan" }
      "LA" { "APAC", "Laos" }
      "LV" { "EMEA", "Latvia" }
      "LB" { "EMEA", "Lebanon" }
      "LS" { "EMEA", "Lesotho" }
      "LR" { "EMEA", "Liberia" }
      "LY" { "EMEA", "Libya" }
      "LI" { "EMEA", "Liechtenstein" }
      "LT" { "EMEA", "Lithuania" }
      "LU" { "EMEA", "Luxembourg" }
      "MO" { "APAC", "Macau" }
      "MK" { "EMEA", "Macedonia" }
      "MG" { "EMEA", "Madagascar" }
      "MW" { "EMEA", "Malawi" }
      "MY" { "APAC", "Malaysia" }
      "MV" { "APAC", "Maldives" }
      "ML" { "EMEA", "Mali" }
      "MT" { "EMEA", "Malta" }
      "MH" { "APAC", "Marshall Islands" }
      "MQ" { "AMER", "Martinique" }
      "MR" { "EMEA", "Mauritania" }
      "MU" { "EMEA", "Mauritius" }
      "YT" { "EMEA", "Mayotte" }
      "MX" { "AMER", "Mexico" }
      "FM" { "APAC", "Micronesia" }
      "MD" { "EMEA", "Moldova" }
      "MC" { "EMEA", "Monaco" }
      "MN" { "APAC", "Mongolia" }
      "ME" { "EMEA", "Montenegro" }
      "MS" { "AMER", "Montserrat" }
      "MA" { "EMEA", "Morocco" }
      "MZ" { "EMEA", "Mozambique" }
      "MM" { "APAC", "Myanmar" }
      "NA" { "EMEA", "Namibia" }
      "NR" { "APAC", "Nauru" }
      "NP" { "APAC", "Nepal" }
      "NL" { "EMEA", "Netherlands" }
      "NC" { "APAC", "New Caledonia" }
      "NZ" { "APAC", "New Zealand" }
      "NI" { "AMER", "Nicaragua" }
      "NE" { "EMEA", "Niger" }
      "NG" { "EMEA", "Nigeria" }
      "NU" { "APAC", "Niue" }
      "NF" { "APAC", "Norfolk Island" }
      "MP" { "APAC", "Northern Mariana Islands" }
      "NO" { "EMEA", "Norway" }
      "OM" { "EMEA", "Oman" }
      "PK" { "APAC", "Pakistan" }
      "PW" { "APAC", "Palau" }
      "PS" { "EMEA", "Palestine" }
      "PA" { "AMER", "Panama" }
      "PG" { "APAC", "Papua New Guinea" }
      "PY" { "AMER", "Paraguay" }
      "PE" { "AMER", "Peru" }
      "PH" { "APAC", "Philippines" }
      "PN" { "APAC", "Pitcairn" }
      "PL" { "EMEA", "Poland" }
      "PT" { "EMEA", "Portugal" }
      "PR" { "AMER", "Puerto Rico" }
      "QA" { "EMEA", "Qatar" }
      "RE" { "EMEA", "Reunion" }
      "RO" { "EMEA", "Romania" }
      "RU" { "EMEA", "Russian Federation" }
      "RW" { "EMEA", "Rwanda" }
      "BL" { "AMER", "Saint Barthelemy" }
      "SH" { "EMEA", "Saint Helena" }
      "KN" { "AMER", "Saint Kitts and Nevis" }
      "LC" { "AMER", "Saint Lucia" }
      "MF" { "AMER", "Saint Martin (French part)" }
      "PM" { "AMER", "Saint Pierre and Miquelon" }
      "VC" { "AMER", "Saint Vincent and the Grenadines" }
      "WS" { "APAC", "Samoa" }
      "SM" { "EMEA", "San Marino" }
      "ST" { "EMEA", "Sao Tome and Principe" }
      "SA" { "EMEA", "Saudi Arabia" }
      "SN" { "EMEA", "Senegal" }
      "RS" { "EMEA", "Serbia" }
      "SC" { "EMEA", "Seychelles" }
      "SL" { "EMEA", "Sierra Leone" }
      "SG" { "APAC", "Singapore" }
      "SX" { "AMER", "Sint Maarten" }
      "SK" { "EMEA", "Slovakia" }
      "SI" { "EMEA", "Slovenia" }
      "SB" { "APAC", "Solomon Islands" }
      "SO" { "EMEA", "Somalia" }
      "ZA" { "EMEA", "South Africa" }
      "GS" { "EMEA", "South Georgia and South Sandwich Islands" }
      "SS" { "APAC", "South Sudan" }
      "ES" { "EMEA", "Spain" }
      "LK" { "APAC", "Sri Lanka" }
      "SD" { "EMEA", "Sudan" }
      "SR" { "AMER", "Suriname" }
      "SJ" { "EMEA", "Svalbard and Jan Mayen Islands" }
      "SZ" { "EMEA", "Swaziland" }
      "SE" { "EMEA", "Sweden" }
      "CH" { "EMEA", "Switzerland" }
      "SY" { "EMEA", "Syria" }
      "TW" { "APAC", "Taiwan" }
      "TJ" { "APAC", "Tajikistan" }
      "TZ" { "EMEA", "Tanzania" }
      "TH" { "APAC", "Thailand" }
      "TL" { "APAC", "Timor-Leste" }
      "TG" { "EMEA", "Togo" }
      "TK" { "APAC", "Tokelau" }
      "TO" { "APAC", "Tonga" }
      "TT" { "AMER", "Trinidad and Tobago" }
      "TN" { "EMEA", "Tunisia" }
      "TR" { "EMEA", "Turkey" }
      "TM" { "APAC", "Turkmenistan" }
      "TC" { "AMER", "Turks and Caicos Islands" }
      "TV" { "APAC", "Tuvalu" }
      "UG" { "EMEA", "Uganda" }
      "UA" { "EMEA", "Ukraine" }
      "AE" { "EMEA", "United Arab Emirates" }
      "GB" { "EMEA", "United Kingdom" }
      "UM" { "APAC", "United States Minor Outlying Islands" }
      "US" { "AMER", "United States of America" }
      "UY" { "AMER", "Uruguay" }
      "UZ" { "APAC", "Uzbekistan" }
      "VU" { "APAC", "Vanuatu" }
      "VA" { "EMEA", "Vatican City" }
      "VE" { "AMER", "Venezuela" }
      "VN" { "APAC", "Vietnam" }
      "VG" { "AMER", "Virgin Islands, British" }
      "VI" { "AMER", "Virgin Islands, U.S." }
      "WF" { "APAC", "Wallis and Futuna Islands" }
      "EH" { "EMEA", "Western Sahara" }
      "YE" { "EMEA", "Yemen" }
      "ZM" { "EMEA", "Zambia" }
      "ZW" { "EMEA", "Zimbabwe" }
      default { $null, $null }
    }

    switch ($Output) {
      "Region" { Return $Region }
      "Country" { Return $CountryName }
    }

  }

  end {

  }
} #Get-RegionFromCountryCode
