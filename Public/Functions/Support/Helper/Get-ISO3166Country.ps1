# Module:   TeamsFunctions
# Function: Helper
# Author:   David Eberhardt
# Updated:  31-JUL-2021
# Status:   Live




function Get-ISO3166Country {
  <#
  .SYNOPSIS
    ISO 3166 Country table. Period.
  .DESCRIPTION
    Returns the full ISO3166 Country table with Name, -alpha2, -alpha3 & NUM code.
  .EXAMPLE
    Get-ISO3166Country
    Returns the full table of Countries including TwoLetterCode (alpha2) & ThreeLetterCode (alpha3) and NumericCode (NUM)
  .EXAMPLE
    Get-ISO3166Country | Where-Object TwoLetterCode -eq "AW"
    Returns entry for Country "Aruba" queried from the TwoLetterCode (ISO3166-Alpha2) AW
  .EXAMPLE
    (Get-ISO3166Country).TwoLetterCode
    Returns the column TwoLetterCode (ISO3166-Alpha2) for all countries
  .INPUTS
    System.Void
  .OUTPUTS
    System.Object
  .NOTES
    This CmdLet is created based on the C# definition of https://github.com/schourode/iso3166
    Manually translated into PowerShell from source file https://raw.githubusercontent.com/schourode/iso3166/master/Country.cs
    Dataset last queried 31 JUL 2021 (based on last update of Github repo 08 JAN 2020)
    ISO3166-alpha2 is used as the Usage Location in Office 365
  .COMPONENT
    SupportingFunction
  .FUNCTIONALITY
    Retruns a List of all ISO3166 Countries
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/Get-ISO3166Country.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/about_Supporting_Functions.md
  .LINK
    https://github.com/DEberhardt/TeamsFunctions/tree/master/docs/
  #>

  [CmdletBinding()]
  [OutputType([System.Object[]])]
  param (
  )

  begin {
    Show-FunctionStatus -Level Live
    Write-Verbose -Message "Returning ISO 3166 Country List"

    # Creating Class TFCountry
    class TFCountry {
      [string]$Name
      [string]$TwoLetterCode
      [string]$ThreeLetterCode
      [string]$NumericCode

      TFCountry(
        [string]$Name,
        [string]$TwoLetterCode,
        [string]$ThreeLetterCode,
        [string]$NumericCode
      ) {
        $this.Name = $Name
        $this.TwoLetterCode = $TwoLetterCode
        $this.ThreeLetterCode = $ThreeLetterCode
        $this.NumericCode = $NumericCode
      }
    }
  }

  process {
    [System.Collections.ArrayList]$ISO3166Countries = @()

    #region Adding Countries
    [void]$ISO3166Countries.Add([TFCountry]::new('Afghanistan', 'AF', 'AFG', '004'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Albania', 'AL', 'ALB', '008'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Algeria', 'DZ', 'DZA', '012'))
    [void]$ISO3166Countries.Add([TFCountry]::new('American Samoa', 'AS', 'ASM', '016'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Andorra', 'AD', 'AND', '020'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Angola', 'AO', 'AGO', '024'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Anguilla', 'AI', 'AIA', '660'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Antarctica', 'AQ', 'ATA', '010'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Antigua and Barbuda', 'AG', 'ATG', '028'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Argentina', 'AR', 'ARG', '032'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Armenia', 'AM', 'ARM', '051'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Aruba', 'AW', 'ABW', '533'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Australia', 'AU', 'AUS', '036'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Austria', 'AT', 'AUT', '040'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Azerbaijan', 'AZ', 'AZE', '031'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Bahamas', 'BS', 'BHS', '044'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Bahrain', 'BH', 'BHR', '048'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Bangladesh', 'BD', 'BGD', '050'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Barbados', 'BB', 'BRB', '052'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Belarus', 'BY', 'BLR', '112'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Belgium', 'BE', 'BEL', '056'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Belize', 'BZ', 'BLZ', '084'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Benin', 'BJ', 'BEN', '204'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Bermuda', 'BM', 'BMU', '060'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Bhutan', 'BT', 'BTN', '064'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Bolivia, Plurinational State of', 'BO', 'BOL', '068'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Bonaire, Sint Eustatius and Saba', 'BQ', 'BES', '535'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Bosnia and Herzegovina', 'BA', 'BIH', '070'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Botswana', 'BW', 'BWA', '072'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Bouvet Island', 'BV', 'BVT', '074'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Brazil', 'BR', 'BRA', '076'))
    [void]$ISO3166Countries.Add([TFCountry]::new('British Indian Ocean Territory', 'IO', 'IOT', '086'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Brunei Darussalam', 'BN', 'BRN', '096'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Bulgaria', 'BG', 'BGR', '100'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Burkina Faso', 'BF', 'BFA', '854'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Burundi', 'BI', 'BDI', '108'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Cabo Verde', 'CV', 'CPV', '132'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Cambodia', 'KH', 'KHM', '116'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Cameroon', 'CM', 'CMR', '120'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Canada', 'CA', 'CAN', '124'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Cayman Islands', 'KY', 'CYM', '136'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Central African Republic', 'CF', 'CAF', '140'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Chad', 'TD', 'TCD', '148'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Chile', 'CL', 'CHL', '152'))
    [void]$ISO3166Countries.Add([TFCountry]::new('China', 'CN', 'CHN', '156'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Christmas Island', 'CX', 'CXR', '162'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Cocos (Keeling) Islands', 'CC', 'CCK', '166'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Colombia', 'CO', 'COL', '170'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Comoros', 'KM', 'COM', '174'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Congo', 'CG', 'COG', '178'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Congo, the Democratic Republic of the', 'CD', 'COD', '180'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Cook Islands', 'CK', 'COK', '184'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Costa Rica', 'CR', 'CRI', '188'))
    [void]$ISO3166Countries.Add([TFCountry]::new("Côte d'Ivoire", 'CI', 'CIV', '384'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Croatia', 'HR', 'HRV', '191'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Cuba', 'CU', 'CUB', '192'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Curaçao', 'CW', 'CUW', '531'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Cyprus', 'CY', 'CYP', '196'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Czechia', 'CZ', 'CZE', '203'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Denmark', 'DK', 'DNK', '208'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Djibouti', 'DJ', 'DJI', '262'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Dominica', 'DM', 'DMA', '212'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Dominican Republic', 'DO', 'DOM', '214'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Ecuador', 'EC', 'ECU', '218'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Egypt', 'EG', 'EGY', '818'))
    [void]$ISO3166Countries.Add([TFCountry]::new('El Salvador', 'SV', 'SLV', '222'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Equatorial Guinea', 'GQ', 'GNQ', '226'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Eritrea', 'ER', 'ERI', '232'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Estonia', 'EE', 'EST', '233'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Eswatini', 'SZ', 'SWZ', '748'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Ethiopia', 'ET', 'ETH', '231'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Falkland Islands (Malvinas)', 'FK', 'FLK', '238'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Faroe Islands', 'FO', 'FRO', '234'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Fiji', 'FJ', 'FJI', '242'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Finland', 'FI', 'FIN', '246'))
    [void]$ISO3166Countries.Add([TFCountry]::new('France', 'FR', 'FRA', '250'))
    [void]$ISO3166Countries.Add([TFCountry]::new('French Guiana', 'GF', 'GUF', '254'))
    [void]$ISO3166Countries.Add([TFCountry]::new('French Polynesia', 'PF', 'PYF', '258'))
    [void]$ISO3166Countries.Add([TFCountry]::new('French Southern Territories', 'TF', 'ATF', '260'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Gabon', 'GA', 'GAB', '266'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Gambia', 'GM', 'GMB', '270'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Georgia', 'GE', 'GEO', '268'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Germany', 'DE', 'DEU', '276'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Ghana', 'GH', 'GHA', '288'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Gibraltar', 'GI', 'GIB', '292'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Greece', 'GR', 'GRC', '300'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Greenland', 'GL', 'GRL', '304'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Grenada', 'GD', 'GRD', '308'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Guadeloupe', 'GP', 'GLP', '312'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Guam', 'GU', 'GUM', '316'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Guatemala', 'GT', 'GTM', '320'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Guernsey', 'GG', 'GGY', '831'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Guinea', 'GN', 'GIN', '324'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Guinea-Bissau', 'GW', 'GNB', '624'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Guyana', 'GY', 'GUY', '328'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Haiti', 'HT', 'HTI', '332'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Heard Island and McDonald Islands', 'HM', 'HMD', '334'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Holy See', 'VA', 'VAT', '336'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Honduras', 'HN', 'HND', '340'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Hong Kong', 'HK', 'HKG', '344'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Hungary', 'HU', 'HUN', '348'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Iceland', 'IS', 'ISL', '352'))
    [void]$ISO3166Countries.Add([TFCountry]::new('India', 'IN', 'IND', '356'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Indonesia', 'ID', 'IDN', '360'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Iran, Islamic Republic of', 'IR', 'IRN', '364'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Iraq', 'IQ', 'IRQ', '368'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Ireland', 'IE', 'IRL', '372'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Isle of Man', 'IM', 'IMN', '833'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Israel', 'IL', 'ISR', '376'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Italy', 'IT', 'ITA', '380'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Jamaica', 'JM', 'JAM', '388'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Japan', 'JP', 'JPN', '392'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Jersey', 'JE', 'JEY', '832'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Jordan', 'JO', 'JOR', '400'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Kazakhstan', 'KZ', 'KAZ', '398'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Kenya', 'KE', 'KEN', '404'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Kiribati', 'KI', 'KIR', '296'))
    [void]$ISO3166Countries.Add([TFCountry]::new("Korea, Democratic People's Republic of", 'KP', 'PRK', '408'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Korea, Republic of', 'KR', 'KOR', '410'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Kuwait', 'KW', 'KWT', '414'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Kyrgyzstan', 'KG', 'KGZ', '417'))
    [void]$ISO3166Countries.Add([TFCountry]::new("Lao People's Democratic Republic", 'LA', 'LAO', '418'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Latvia', 'LV', 'LVA', '428'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Lebanon', 'LB', 'LBN', '422'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Lesotho', 'LS', 'LSO', '426'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Liberia', 'LR', 'LBR', '430'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Libya', 'LY', 'LBY', '434'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Liechtenstein', 'LI', 'LIE', '438'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Lithuania', 'LT', 'LTU', '440'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Luxembourg', 'LU', 'LUX', '442'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Macao', 'MO', 'MAC', '446'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Madagascar', 'MG', 'MDG', '450'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Malawi', 'MW', 'MWI', '454'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Malaysia', 'MY', 'MYS', '458'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Maldives', 'MV', 'MDV', '462'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Mali', 'ML', 'MLI', '466'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Malta', 'MT', 'MLT', '470'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Marshall Islands', 'MH', 'MHL', '584'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Martinique', 'MQ', 'MTQ', '474'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Mauritania', 'MR', 'MRT', '478'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Mauritius', 'MU', 'MUS', '480'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Mayotte', 'YT', 'MYT', '175'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Mexico', 'MX', 'MEX', '484'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Micronesia, Federated States of', 'FM', 'FSM', '583'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Moldova, Republic of', 'MD', 'MDA', '498'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Monaco', 'MC', 'MCO', '492'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Mongolia', 'MN', 'MNG', '496'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Montenegro', 'ME', 'MNE', '499'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Montserrat', 'MS', 'MSR', '500'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Morocco', 'MA', 'MAR', '504'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Mozambique', 'MZ', 'MOZ', '508'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Myanmar', 'MM', 'MMR', '104'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Namibia', 'NA', 'NAM', '516'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Nauru', 'NR', 'NRU', '520'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Nepal', 'NP', 'NPL', '524'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Netherlands', 'NL', 'NLD', '528'))
    [void]$ISO3166Countries.Add([TFCountry]::new('New Caledonia', 'NC', 'NCL', '540'))
    [void]$ISO3166Countries.Add([TFCountry]::new('New Zealand', 'NZ', 'NZL', '554'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Nicaragua', 'NI', 'NIC', '558'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Niger', 'NE', 'NER', '562'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Nigeria', 'NG', 'NGA', '566'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Niue', 'NU', 'NIU', '570'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Norfolk Island', 'NF', 'NFK', '574'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Northern Mariana Islands', 'MP', 'MNP', '580'))
    [void]$ISO3166Countries.Add([TFCountry]::new('North Macedonia', 'MK', 'MKD', '807'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Norway', 'NO', 'NOR', '578'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Oman', 'OM', 'OMN', '512'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Pakistan', 'PK', 'PAK', '586'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Palau', 'PW', 'PLW', '585'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Palestine, State of', 'PS', 'PSE', '275'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Panama', 'PA', 'PAN', '591'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Papua New Guinea', 'PG', 'PNG', '598'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Paraguay', 'PY', 'PRY', '600'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Peru', 'PE', 'PER', '604'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Philippines', 'PH', 'PHL', '608'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Pitcairn', 'PN', 'PCN', '612'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Poland', 'PL', 'POL', '616'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Portugal', 'PT', 'PRT', '620'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Puerto Rico', 'PR', 'PRI', '630'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Qatar', 'QA', 'QAT', '634'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Réunion', 'RE', 'REU', '638'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Romania', 'RO', 'ROU', '642'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Russian Federation', 'RU', 'RUS', '643'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Rwanda', 'RW', 'RWA', '646'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Saint Barthélemy', 'BL', 'BLM', '652'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Saint Helena, Ascension and Tristan da Cunha', 'SH', 'SHN', '654'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Saint Kitts and Nevis', 'KN', 'KNA', '659'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Saint Lucia', 'LC', 'LCA', '662'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Saint Martin (French part)', 'MF', 'MAF', '663'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Saint Pierre and Miquelon', 'PM', 'SPM', '666'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Saint Vincent and the Grenadines', 'VC', 'VCT', '670'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Samoa', 'WS', 'WSM', '882'))
    [void]$ISO3166Countries.Add([TFCountry]::new('San Marino', 'SM', 'SMR', '674'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Sao Tome and Principe', 'ST', 'STP', '678'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Saudi Arabia', 'SA', 'SAU', '682'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Senegal', 'SN', 'SEN', '686'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Serbia', 'RS', 'SRB', '688'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Seychelles', 'SC', 'SYC', '690'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Sierra Leone', 'SL', 'SLE', '694'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Singapore', 'SG', 'SGP', '702'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Sint Maarten (Dutch part)', 'SX', 'SXM', '534'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Slovakia', 'SK', 'SVK', '703'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Slovenia', 'SI', 'SVN', '705'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Solomon Islands', 'SB', 'SLB', '090'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Somalia', 'SO', 'SOM', '706'))
    [void]$ISO3166Countries.Add([TFCountry]::new('South Africa', 'ZA', 'ZAF', '710'))
    [void]$ISO3166Countries.Add([TFCountry]::new('South Georgia and the South Sandwich Islands', 'GS', 'SGS', '239'))
    [void]$ISO3166Countries.Add([TFCountry]::new('South Sudan', 'SS', 'SSD', '728'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Spain', 'ES', 'ESP', '724'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Sri Lanka', 'LK', 'LKA', '144'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Sudan', 'SD', 'SDN', '729'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Suriname', 'SR', 'SUR', '740'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Svalbard and Jan Mayen', 'SJ', 'SJM', '744'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Sweden', 'SE', 'SWE', '752'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Switzerland', 'CH', 'CHE', '756'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Syrian Arab Republic', 'SY', 'SYR', '760'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Taiwan, Province of China', 'TW', 'TWN', '158'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Tajikistan', 'TJ', 'TJK', '762'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Tanzania, United Republic of', 'TZ', 'TZA', '834'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Thailand', 'TH', 'THA', '764'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Timor-Leste', 'TL', 'TLS', '626'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Togo', 'TG', 'TGO', '768'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Tokelau', 'TK', 'TKL', '772'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Tonga', 'TO', 'TON', '776'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Trinidad and Tobago', 'TT', 'TTO', '780'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Tunisia', 'TN', 'TUN', '788'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Turkey', 'TR', 'TUR', '792'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Turkmenistan', 'TM', 'TKM', '795'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Turks and Caicos Islands', 'TC', 'TCA', '796'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Tuvalu', 'TV', 'TUV', '798'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Uganda', 'UG', 'UGA', '800'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Ukraine', 'UA', 'UKR', '804'))
    [void]$ISO3166Countries.Add([TFCountry]::new('United Arab Emirates', 'AE', 'ARE', '784'))
    [void]$ISO3166Countries.Add([TFCountry]::new('United Kingdom of Great Britain and Northern Ireland', 'GB', 'GBR', '826'))
    [void]$ISO3166Countries.Add([TFCountry]::new('United States of America', 'US', 'USA', '840'))
    [void]$ISO3166Countries.Add([TFCountry]::new('United States Minor Outlying Islands', 'UM', 'UMI', '581'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Uruguay', 'UY', 'URY', '858'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Uzbekistan', 'UZ', 'UZB', '860'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Vanuatu', 'VU', 'VUT', '548'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Venezuela, Bolivarian Republic of', 'VE', 'VEN', '862'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Viet Nam', 'VN', 'VNM', '704'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Virgin Islands, British', 'VG', 'VGB', '092'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Virgin Islands, U.S.', 'VI', 'VIR', '850'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Wallis and Futuna', 'WF', 'WLF', '876'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Western Sahara', 'EH', 'ESH', '732'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Yemen', 'YE', 'YEM', '887'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Zambia', 'ZM', 'ZMB', '894'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Zimbabwe', 'ZW', 'ZWE', '716'))
    [void]$ISO3166Countries.Add([TFCountry]::new('Åland Islands', 'AX', 'ALA', '248'))
    #endregion

    return $ISO3166Countries
  }

  end {

  }
} #Get-ISO3166Country
