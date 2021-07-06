
$Number = "03 70123123"
($Number -match '^(tel:)?\+?(([0-9]( |-)?)?(\(?[0-9]{3}\)?)( |-)?([0-9]{3}( |-)?[0-9]{4})|([0-9]{3,15}))?((;( |-)?ext=[0-9]{3,8}))?$')
#Change matching pattern to allow spaces and brackets everywhere?