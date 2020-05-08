/*
 * This class is generated dynamically from Patch Rules.
 */
global class PatchRuleEngine1 extends  PatchRuleEngineBase implements IPatchRuleEngine
{
  private Id matchGroup1(PatchDataModel.MatchTarget t)
  {
  system.debug('inside PatchRuleEngine1  '+t);
    if(prematches.get('Company Name').contains('a3170000002x5DZAAY') || prematches.get('Email Domain').contains('a3170000002x5DaAAI'))      return 'a3070000000EeAbAAK'; //Patch SP - EMEA Emerging
    if(prematches.get('Company Name').contains('a3170000002x5GdAAI') || prematches.get('Email Domain').contains('a3170000002x5GnAAI'))      return 'a3070000000EeBKAA0'; //Patch VAR - CDW
    if(prematches.get('Company Name').contains('a3170000002x5FzAAI') || prematches.get('Email Domain').contains('a3170000002x5G0AAI'))      return 'a3070000000EeBFAA0'; //Patch GSI - I6
    if(prematches.get('Company Name').contains('a3170000002x5EcAAI') || prematches.get('Email Domain').contains('a3170000002x5EdAAI'))      return 'a3070000000EeAqAAK'; //Patch VAR - Optiv
    if(prematches.get('Company Name').contains('a3170000003gUDoAAM') || prematches.get('Email Domain').contains('a3170000003gUDtAAM'))      return 'a307000000045byAAA'; //Patch GSI - Accenture/Deloitte
    if(prematches.get('Company Name').contains('a3170000002x2pRAAQ') || prematches.get('Email Domain').contains('a3170000002x2pbAAA'))      return 'a3070000000Ee73AAC'; //Patch SP - AT&T
    if(prematches.get('Company Name').contains('a310g000004ZlX7AAK') || prematches.get('Email Domain').contains('a310g000004ZlXCAA0'))      return 'a300g000001hYNnAAM'; //Patch Business Development - Named Patches
    if(prematches.get('Company Name').contains('a3170000002x5FkAAI') || prematches.get('Email Domain').contains('a3170000002x5FlAAI'))      return 'a3070000000EeBAAA0'; //Patch GSI - G7
    if(prematches.get('Company Name').contains('a3170000002x5E3AAI') || prematches.get('Email Domain').contains('a3170000002x5E4AAI'))      return 'a3070000000EeAgAAK'; //Patch SP - APJ Emerging
    if((prematches.get('Company Name').contains('a310g000003tsbEAAQ') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })) || (prematches.get('Email Domain').contains('a310g000003tsbFAAQ') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })))      return 'a300g0000019xX6AAI'; //Patch Channel US North West - Named Patch
    if((prematches.get('Company Name').contains('a310g000003tsd7AAA') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })) || (prematches.get('Email Domain').contains('a310g000003tsd6AAA') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })))      return 'a300g0000019xWUAAY'; //Patch Channel Greater China Region
    if((prematches.get('Company Name').contains('a310g000003tsblAAA') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })) || (prematches.get('Email Domain').contains('a310g000003tsbmAAA') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })))      return 'a300g0000019xWTAAY'; //Patch Channel UK&I
    if((prematches.get('Company Name').contains('a310g000003tsd4AAA') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })) || (prematches.get('Email Domain').contains('a310g000003tsd5AAA') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })))      return 'a300g0000019xWmAAI'; //Patch Channel ANZ
    if((prematches.get('Company Name').contains('a310g000003tscFAAQ') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })) || (prematches.get('Email Domain').contains('a310g000003tscEAAQ') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })))      return 'a300g0000019xWcAAI'; //Patch Channel Central Europe
    if((prematches.get('Company Name').contains('a310g000003tsd3AAA') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })) || (prematches.get('Email Domain').contains('a310g000003tsd2AAA') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })))      return 'a300g0000019xWbAAI'; //Patch Channel Northern Europe
    if((prematches.get('Company Name').contains('a310g000003tscxAAA') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })) || (prematches.get('Email Domain').contains('a310g000003tscwAAA') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })))      return 'a300g0000019xWVAAY'; //Patch Channel India
    if((prematches.get('Company Name').contains('a310g000003tscyAAA') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })) || (prematches.get('Email Domain').contains('a310g000003tsczAAA') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })))      return 'a300g0000019xWWAAY'; //Patch Channel ASEAN
    if((prematches.get('Company Name').contains('a310g000003tscHAAQ') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })) || (prematches.get('Email Domain').contains('a310g000003tscGAAQ') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })))      return 'a300g0000019xWYAAY'; //Patch Channel Southern Europe
    if((prematches.get('Company Name').contains('a310g000003tsalAAA') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })) || (prematches.get('Email Domain').contains('a310g000003tsakAAA') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })))      return 'a300g0000019xWZAAY'; //Patch Channel US South Central Named Patch
    if((prematches.get('Company Name').contains('a310g000003tscIAAQ') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })) || (prematches.get('Email Domain').contains('a310g000003tscJAAQ') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })))      return 'a300g0000019xWXAAY'; //Patch Channel US North Central Named Patch
    if((prematches.get('Company Name').contains('a310g000003u9BvAAI') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })) || (prematches.get('Email Domain').contains('a310g000003u9C0AAI') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })))      return 'a300g0000019y3VAAQ'; //Patch Channel US Ohio Valley Named Patch
    if((prematches.get('Company Name').contains('a310g000003tscKAAQ') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })) || (prematches.get('Email Domain').contains('a310g000003tscLAAQ') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })))      return 'a300g0000019xWiAAI'; //Patch Channel US Public Sector
    if((prematches.get('Company Name').contains('a310g000003tsd0AAA') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })) || (prematches.get('Email Domain').contains('a310g000003tsd1AAA') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })))      return 'a300g0000019xWnAAI'; //Patch Channel US Mid-Atlantic
    if(prematches.get('Company Name').contains('a310g000006Nk1xAAC') || prematches.get('Email Domain').contains('a310g000006Nk37AAC'))      return 'a300g000001IBj0AAG'; //Patch Channel US Mid-Atlantic - Named Accounts
    if((prematches.get('Company Name').contains('a310g000003tscaAAA') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner', 'technology partner' })) || (prematches.get('Email Domain').contains('a310g000003tscbAAA') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner', 'technology partner' })))      return 'a300g0000019xWSAAY'; //Patch Channel US South East
    if((prematches.get('Company Name').contains('a310g000003tsb5AAA') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })) || (prematches.get('Email Domain').contains('a310g000003tsb4AAA') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })))      return 'a300g0000019xWkAAI'; //Patch Channel US North East Named Patch
    if((prematches.get('Company Name').contains('a310g000003tscuAAA') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })) || (prematches.get('Email Domain').contains('a310g000003tscvAAA') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })))      return 'a300g0000019xWdAAI'; //Patch Channel Middle East
    if((prematches.get('Company Name').contains('a310g000003tscsAAA') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })) || (prematches.get('Email Domain').contains('a310g000003tsctAAA') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })))      return 'a300g0000019xWlAAI'; //Patch Channel US New England/Canada
    if((prematches.get('Company Name').contains('a310g000003tsbCAAQ') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })) || (prematches.get('Email Domain').contains('a310g000003tsbDAAQ') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })))      return 'a300g0000019xWjAAI'; //Patch Channel US South West
    if(prematches.get('Company Name').contains('a310g000006Nk23AAC') || prematches.get('Email Domain').contains('a310g000006Nk3DAAS'))      return 'a300g000001IBj6AAG'; //Patch Channel US Southwest - Named Accounts
    if((prematches.get('Company Name').contains('a310g000003tscqAAA') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })) || (prematches.get('Email Domain').contains('a310g000003tscrAAA') && opIn(t.custom2, new Set<String> { 'partner', 'ex - partner' })))      return 'a300g0000019xWaAAI'; //Patch Channel Japan
    if(prematches.get('Company Name').contains('a3170000002lOcrAAE') || prematches.get('Email Domain').contains('a3170000002lOcwAAE'))      return 'a3070000000TkLKAA0'; //Patch FED CIV State Department, DOE, Legislative - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2jAAC') || prematches.get('Email Domain').contains('a310g000006Nk3tAAC'))      return 'a300g000001IBjmAAG'; //Patch FED CIV Commerce, Transportation, Education, Labor, Interior - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk0WAAS') || prematches.get('Email Domain').contains('a310g000006Nk0bAAC'))      return 'a300g000001IBicAAG'; //Patch Catch All - Federal Named
    if(prematches.get('Company Name').contains('a310g00000AyFqQAAV') || prematches.get('Email Domain').contains('a310g00000AyFqRAAV'))      return 'a300g000001XNXbAAO'; //Patch FED CIV DOJ & DHS - Named Accounts
    return null;
  }
  private Id matchGroup2(PatchDataModel.MatchTarget t)
  {
    if(prematches.get('Company Name').contains('a310g00000AyFqSAAV') || prematches.get('Email Domain').contains('a310g00000AyFqTAAV'))      return 'a300g000001XNXcAAO'; //Patch FED CIV Treasury, IRS, SEC, SSA - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000AyFqUAAV') || prematches.get('Email Domain').contains('a310g00000AyFqVAAV'))      return 'a300g000001XNXdAAO'; //Patch FED CIV Postal, GSA, EPA, OPM, HUD - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000AyFqWAAV') || prematches.get('Email Domain').contains('a310g00000AyFqXAAV'))      return 'a300g000001XNXeAAO'; //Patch FED CIV VA, DHA, Health and Human Services - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000AyFqYAAV') || prematches.get('Email Domain').contains('a310g00000AyFqZAAV'))      return 'a300g000001XNXfAAO'; //Patch FED DOD 1 Named Accounts
    if(prematches.get('Company Name').contains('a310g00000DtyvvAAB') || prematches.get('Email Domain').contains('a310g00000Dtyw0AAB'))      return 'a300g0000022mrSAAQ'; //Patch FED DOD 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000DtywAAAR') || prematches.get('Email Domain').contains('a310g00000DtywFAAR'))      return 'a300g0000022mrXAAQ'; //Patch FED DOD 3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000Cmt15AAB') || prematches.get('Email Domain').contains('a310g00000Cmt1AAAR'))      return 'a300g000002HdMrAAK'; //Patch FED DOD 4 Named Accounts
    if(prematches.get('Company Name').contains('a3170000003sBsnAAE') || prematches.get('Email Domain').contains('a3170000003sBsmAAE'))      return 'a30700000019VdgAAE'; //Patch LE SLED Northeast - LE Named Account
    if(prematches.get('Company Name').contains('a310g000006Nk2uAAC') || prematches.get('Email Domain').contains('a310g000006Nk44AAC'))      return 'a300g000001IBjxAAG'; //Patch LE SLED Southcentral - ENT Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2tAAC') || prematches.get('Email Domain').contains('a310g000006Nk43AAC'))      return 'a300g000001IBjwAAG'; //Patch LE SLED Southcentral - LE Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2sAAC') || prematches.get('Email Domain').contains('a310g000006Nk42AAC'))      return 'a300g000001IBjvAAG'; //Patch LE SLED Southeast- ENT Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2rAAC') || prematches.get('Email Domain').contains('a310g000006Nk41AAC'))      return 'a300g000001IBjuAAG'; //Patch LE SLED Southeast - LE Named Accounts
    if(prematches.get('Company Name').contains('a310g000004s9EaAAI') || prematches.get('Email Domain').contains('a310g000004s9EkAAI'))      return 'a300g0000007xCNAAY'; //Patch LE SLED Northeast - ENT Named Accounts
    if(prematches.get('Company Name').contains('a310g000004s9CoAAI') || prematches.get('Email Domain').contains('a310g000004s9CtAAI'))      return 'a300g0000007xBeAAI'; //Patch LE SLED California - ENT Named Accounts
    if(prematches.get('Company Name').contains('a3170000003sBt6AAE') || prematches.get('Email Domain').contains('a3170000003sBt7AAE'))      return 'a30700000019VdqAAE'; //Patch LE SLED California - LE Named Accounts
    if(prematches.get('Company Name').contains('a310g00000AyFqoAAF') || prematches.get('Email Domain').contains('a310g00000AyFqpAAF'))      return 'a300g000001XNXnAAO'; //Patch LE SLED Mid-Atlantic - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000AyFqqAAF') || prematches.get('Email Domain').contains('a310g00000AyFqrAAF'))      return 'a300g000001XNXoAAO'; //Patch LE SLED Northcentral - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000AyFqsAAF') || prematches.get('Email Domain').contains('a310g00000AyFqtAAF'))      return 'a300g000001XNXpAAO'; //Patch LE SLED West - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006OlHqAAK') || prematches.get('Email Domain').contains('a310g000006OlI0AAK'))      return 'a300g000001KM6AAAW'; //Patch GB US SLED IB - Named Accounts
    if(prematches.get('Company Name').contains('a3170000003sBslAAE') || prematches.get('Email Domain').contains('a3170000003sBskAAE'))      return 'a30700000019VdfAAE'; //Patch SLED GB - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2fAAC') || prematches.get('Email Domain').contains('a310g000006Nk3pAAC'))      return 'a300g000001IBjiAAG'; //Patch LE SLED Canada - LE Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2wAAC') || prematches.get('Email Domain').contains('a310g000006Nk46AAC'))      return 'a300g000001IBjzAAG'; //Patch LE SLED Canada - ENT Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsdUAAQ') || prematches.get('Email Domain').contains('a310g000003tsdVAAQ'))      return 'a300g0000019xUyAAI'; //Patch UK Majors 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsdXAAQ') || prematches.get('Email Domain').contains('a310g000003tsdWAAQ'))      return 'a300g0000019xUzAAI'; //Patch UK Majors 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2VAAS') || prematches.get('Email Domain').contains('a310g000006Nk3fAAC'))      return 'a300g000001IBjYAAW'; //Patch Major UK 3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tseJAAQ') || prematches.get('Email Domain').contains('a310g000003tseIAAQ'))      return 'a300g0000019xUZAAY'; //Patch Major Central Ohio - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsedAAA') || prematches.get('Email Domain').contains('a310g000003tsecAAA'))      return 'a300g0000019xUfAAI'; //Patch Major Mid-Atlantic - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2pAAC') || prematches.get('Email Domain').contains('a310g000006Nk3zAAC'))      return 'a300g000001IBjsAAG'; //Patch Major Mid-Atlantic 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsdTAAQ') || prematches.get('Email Domain').contains('a310g000003tsdSAAQ'))      return 'a300g0000019xUSAAY'; //Patch MAM FR - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tseaAAA') || prematches.get('Email Domain').contains('a310g000003tsebAAA'))      return 'a300g0000019xUaAAI'; //Patch Major PNW - Named List
    if(prematches.get('Company Name').contains('a310g000003tsefAAA') || prematches.get('Email Domain').contains('a310g000003tseeAAA'))      return 'a300g0000019xUnAAI'; //Patch Major NorCal 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tse1AAA') || prematches.get('Email Domain').contains('a310g000003tse0AAA'))      return 'a300g0000019xUkAAI'; //Patch Major Illinois - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsdqAAA') || prematches.get('Email Domain').contains('a310g000003tsdrAAA'))      return 'a300g0000019xUYAAY'; //Patch Major DACH 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tse3AAA') || prematches.get('Email Domain').contains('a310g000003tse2AAA'))      return 'a300g0000019xUdAAI'; //Patch Major DACH 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsdtAAA') || prematches.get('Email Domain').contains('a310g000003tsdsAAA'))      return 'a300g0000019xUmAAI'; //Patch Major DACH 3 - Named Accounts
    return null;
  }
  private Id matchGroup3(PatchDataModel.MatchTarget t)
  {
    if(prematches.get('Company Name').contains('a310g000006Nk1zAAC') || prematches.get('Email Domain').contains('a310g000006Nk39AAC'))      return 'a300g000001IBj2AAG'; //Patch Major GER 4 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk1uAAC') || prematches.get('Email Domain').contains('a310g000006Nk34AAC'))      return 'a300g000001IBixAAG'; //Patch Major CH - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk1vAAC') || prematches.get('Email Domain').contains('a310g000006Nk35AAC'))      return 'a300g000001IBiyAAG'; //Patch Major GER 5 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsehAAA') || prematches.get('Email Domain').contains('a310g000003tsegAAA'))      return 'a300g0000019xUAAAY'; //Patch Major Netherlands - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2mAAC') || prematches.get('Email Domain').contains('a310g000006Nk3wAAC'))      return 'a300g000001IBjpAAG'; //Patch Major Netherlands 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tseYAAQ') || prematches.get('Email Domain').contains('a310g000003tseZAAQ'))      return 'a300g0000019xUFAAY'; //Patch Major Nordics - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2oAAC') || prematches.get('Email Domain').contains('a310g000006Nk3yAAC'))      return 'a300g000001IBjrAAG'; //Patch Major FR 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsgIAAQ') || prematches.get('Email Domain').contains('a310g000003tsgHAAQ'))      return 'a300g0000019xVfAAI'; //Patch Major Dallas 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsdoAAA') || prematches.get('Email Domain').contains('a310g000003tsdpAAA'))      return 'a300g0000019xUjAAI'; //Patch Major MN Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsdZAAQ') || prematches.get('Email Domain').contains('a310g000003tsdYAAQ'))      return 'a300g0000019xUBAAY'; //Patch Major PA and OH - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003uWXLAA2') || prematches.get('Email Domain').contains('a310g000003uWXQAA2'))      return 'a300g0000019yEEAAY'; //Patch Major Southeast - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsa3AAA') || prematches.get('Email Domain').contains('a310g000003tsa4AAA'))      return 'a300g0000019xV2AAI'; //Patch Major Canada Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsgQAAQ') || prematches.get('Email Domain').contains('a310g000003tsgPAAQ'))      return 'a300g0000019xW9AAI'; //Patch Major Michigan - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsdBAAQ') || prematches.get('Email Domain').contains('a310g000003tsdAAAQ'))      return 'a300g0000019xVCAAY'; //Patch Major New England - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2cAAC') || prematches.get('Email Domain').contains('a310g000006Nk3mAAC'))      return 'a300g000001IBjfAAG'; //Patch Major India - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2bAAC') || prematches.get('Email Domain').contains('a310g000006Nk3lAAC'))      return 'a300g000001IBjeAAG'; //Patch Major Japan - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsZvAAI') || prematches.get('Email Domain').contains('a310g000003tsZuAAI'))      return 'a300g0000019xVDAAY'; //Patch Majors Carolinas - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsdIAAQ') || prematches.get('Email Domain').contains('a310g000003tsdJAAQ'))      return 'a300g0000019xVHAAY'; //Patch Major NYPD 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000004Zyg7AAC') || prematches.get('Email Domain').contains('a310g000004ZygCAAS'))      return 'a300g000001iFzzAAE'; //Patch Major New England 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000004ZygHAAS') || prematches.get('Email Domain').contains('a310g000004ZygMAAS'))      return 'a300g000001iG04AAE'; //Patch Major NYPD 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000AyGwsAAF') || prematches.get('Email Domain').contains('a310g00000AyGwxAAF'))      return 'a300g000001XWUnAAO'; //Patch Major Canada 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000AyFqyAAF') || prematches.get('Email Domain').contains('a310g00000AyFqzAAF'))      return 'a300g000001XNXsAAO'; //Patch Major Southern Ohio Named Accounts
    if(prematches.get('Company Name').contains('a310g00000DtrLoAAJ') || prematches.get('Email Domain').contains('a310g00000DtrLpAAJ'))      return 'a300g0000022HPhAAM'; //Patch Major Japan 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000DtrM4AAJ') || prematches.get('Email Domain').contains('a310g00000DtrM5AAJ'))      return 'a300g0000022HPpAAM'; //Patch Major UK 4 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000DtrM8AAJ') || prematches.get('Email Domain').contains('a310g00000DtrM9AAJ'))      return 'a300g0000022HPrAAM'; //Patch Major GER 6 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000DtrMEAAZ') || prematches.get('Email Domain').contains('a310g00000DtrMFAAZ'))      return 'a300g0000022HPuAAM'; //Patch Major NL 3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000Du398AAB') || prematches.get('Email Domain').contains('a310g00000Du39DAAR'))      return 'a300g00000237uuAAA'; //Patch Major MN/WI - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000Cm1KGAAZ') || prematches.get('Email Domain').contains('a310g00000Cm1KLAAZ'))      return 'a300g000002EIxJAAW'; //Patch Major Chicago - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000Cm2lJAAR') || prematches.get('Email Domain').contains('a310g00000Cm2lTAAR'))      return 'a300g000002EIygAAG'; //Patch LE NYM 5 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000Cm2ohAAB') || prematches.get('Email Domain').contains('a310g00000Cm2omAAB'))      return 'a300g000002EIylAAG'; //Patch Major Bay Area - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000Cm2pkAAB') || prematches.get('Email Domain').contains('a310g00000Cm2ppAAB'))      return 'a300g000002EIyqAAG'; //Patch LE SoCal 3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo4gAAD') || prematches.get('Email Domain').contains('a310g00000JFo4hAAD'))      return 'a300g000002PgC9AAK'; //Patch Major AR - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo4iAAD') || prematches.get('Email Domain').contains('a310g00000JFo4jAAD'))      return 'a300g000002PgCAAA0'; //Patch Major ASEAN 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo4mAAD') || prematches.get('Email Domain').contains('a310g00000JFo4nAAD'))      return 'a300g000002PgCBAA0'; //Patch Major ASEAN 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo4qAAD') || prematches.get('Email Domain').contains('a310g00000JFo4rAAD'))      return 'a300g000002PgCCAA0'; //Patch Major Canada 3 - Named Accounts
    return null;
  }
  private Id matchGroup4(PatchDataModel.MatchTarget t)
  {
    if(prematches.get('Company Name').contains('a310g00000JFo4uAAD') || prematches.get('Email Domain').contains('a310g00000JFo4vAAD'))      return 'a300g000002PgCDAA0'; //Patch Major Carolinas 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo4yAAD') || prematches.get('Email Domain').contains('a310g00000JFo4zAAD'))      return 'a300g000002PgCEAA0'; //Patch Major Desert 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo52AAD') || prematches.get('Email Domain').contains('a310g00000JFo53AAD'))      return 'a300g000002PgCFAA0'; //Patch Major FR 4 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo56AAD') || prematches.get('Email Domain').contains('a310g00000JFo57AAD'))      return 'a300g000002PgCGAA0'; //Patch Major FR 5 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo5AAAT') || prematches.get('Email Domain').contains('a310g00000JFo5BAAT'))      return 'a300g000002PgCHAA0'; //Patch Major FR 6 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo5EAAT') || prematches.get('Email Domain').contains('a310g00000JFo5FAAT'))      return 'a300g000002PgCIAA0'; //Patch Major Georgia - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo5IAAT') || prematches.get('Email Domain').contains('a310g00000JFo5JAAT'))      return 'a300g000002PgCJAA0'; //Patch Major GER 7 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo5MAAT') || prematches.get('Email Domain').contains('a310g00000JFo5NAAT'))      return 'a300g000002PgCKAA0'; //Patch Major GER 8 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo5QAAT') || prematches.get('Email Domain').contains('a310g00000JFo5RAAT'))      return 'a300g000002PgCLAA0'; //Patch Major GER 9 - Named Accounts
    if(prematches.get('Company Name').contains('a3170000003sBtOAAU') || prematches.get('Email Domain').contains('a3170000003sBtPAAU'))      return 'a30700000019VdzAAE'; //Patch All APAC - LE Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo5UAAT') || prematches.get('Email Domain').contains('a310g00000JFo5VAAT'))      return 'a300g000002PgCMAA0'; //Patch Major Gov India 3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo5YAAT') || prematches.get('Email Domain').contains('a310g00000JFo5ZAAT'))      return 'a300g000002PgCNAA0'; //Patch Major Heartland - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo5cAAD') || prematches.get('Email Domain').contains('a310g00000JFo5dAAD'))      return 'a300g000002PgCOAA0'; //Patch Major Houston 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2UAAS') || prematches.get('Email Domain').contains('a310g000006Nk3eAAC'))      return 'a300g000001IBjXAAW'; //Patch LE ASEAN 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo5gAAD') || prematches.get('Email Domain').contains('a310g00000JFo5hAAD'))      return 'a300g000002PgCPAA0'; //Patch Major IA - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000AygwgAAB') || prematches.get('Email Domain').contains('a310g00000AygwhAAB'))      return 'a300g000001YPpHAAW'; //Patch ENT ASEAN 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo5kAAD') || prematches.get('Email Domain').contains('a310g00000JFo5lAAD'))      return 'a300g000002PgCQAA0'; //Patch Major Iberia 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo5oAAD') || prematches.get('Email Domain').contains('a310g00000JFo5pAAD'))      return 'a300g000002PgCRAA0'; //Patch Major Iberia 2 - Named Accounts
    if(prematches.get('Company Name').contains('a3170000003sBtTAAU') || prematches.get('Email Domain').contains('a3170000003sBtSAAU'))      return 'a30700000019Ve1AAE'; //Patch All HK/TW/China - LE
    if(prematches.get('Company Name').contains('a310g00000JFo5sAAD') || prematches.get('Email Domain').contains('a310g00000JFo5tAAD'))      return 'a300g000002PgCSAA0'; //Patch Major Illinois 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo5wAAD') || prematches.get('Email Domain').contains('a310g00000JFo5xAAD'))      return 'a300g000002PgCTAA0'; //Patch Major IN/KY - Named Accounts
    if(prematches.get('Company Name').contains('a3170000003sBu0AAE') || prematches.get('Email Domain').contains('a3170000003sBu1AAE'))      return 'a30700000019VeIAAU'; //Patch GB GCR - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo60AAD') || prematches.get('Email Domain').contains('a310g00000JFo61AAD'))      return 'a300g000002PgCUAA0'; //Patch Major Italy 1 - Named Accounts
    if(prematches.get('Company Name').contains('a3170000003sBuYAAU') || prematches.get('Email Domain').contains('a3170000003sBuZAAU'))      return 'a30700000019VeZAAU'; //Patch All India North ENT Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo64AAD') || prematches.get('Email Domain').contains('a310g00000JFo65AAD'))      return 'a300g000002PgCVAA0'; //Patch Major Japan 3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo68AAD') || prematches.get('Email Domain').contains('a310g00000JFo69AAD'))      return 'a300g000002PgCWAA0'; //Patch Major Japan 5 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo6CAAT') || prematches.get('Email Domain').contains('a310g00000JFo6DAAT'))      return 'a300g000002PgCXAA0'; //Patch Major LA - Named Accounts
    if(prematches.get('Company Name').contains('a3170000003sBueAAE') || prematches.get('Email Domain').contains('a3170000003sBufAAE'))      return 'a30700000019VecAAE'; //Patch Major India 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo6GAAT') || prematches.get('Email Domain').contains('a310g00000JFo6HAAT'))      return 'a300g000002PgCYAA0'; //Patch Major Mid-Atlantic 3 - Named Accounts
    if(prematches.get('Company Name').contains('a3170000003sBvXAAU') || prematches.get('Email Domain').contains('a3170000003sBvYAAU'))      return 'a30700000019Vf4AAE'; //Patch All India West ENT Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo6KAAT') || prematches.get('Email Domain').contains('a310g00000JFo6LAAT'))      return 'a300g000002PgCZAA0'; //Patch Major Mid-Atlantic 4 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo4kAAD') || prematches.get('Email Domain').contains('a310g00000JFo4lAAD'))      return 'a300g000002PgCaAAK'; //Patch Major Mid-Atlantic 5 - Named Accounts
    if(prematches.get('Company Name').contains('a3170000003sBumAAE') || prematches.get('Email Domain').contains('a3170000003sBunAAE'))      return 'a30700000019VegAAE'; //Patch All India South ENT Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo4oAAD') || prematches.get('Email Domain').contains('a310g00000JFo4pAAD'))      return 'a300g000002PgCbAAK'; //Patch Major MN 3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo4sAAD') || prematches.get('Email Domain').contains('a310g00000JFo4tAAD'))      return 'a300g000002PgCcAAK'; //Patch Major MO/KS - Named Accounts
    return null;
  }
  private Id matchGroup5(PatchDataModel.MatchTarget t)
  {
    if(prematches.get('Company Name').contains('a310g00000JFo4wAAD') || prematches.get('Email Domain').contains('a310g00000JFo4xAAD'))      return 'a300g000002PgCdAAK'; //Patch Major New England 3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo50AAD') || prematches.get('Email Domain').contains('a310g00000JFo51AAD'))      return 'a300g000002PgCeAAK'; //Patch Major New England 4 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2KAAS') || prematches.get('Email Domain').contains('a310g000006Nk3UAAS'))      return 'a300g000001IBjNAAW'; //Patch All Japan 1 - ENT Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo54AAD') || prematches.get('Email Domain').contains('a310g00000JFo55AAD'))      return 'a300g000002PgCfAAK'; //Patch Major NJ 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo58AAD') || prematches.get('Email Domain').contains('a310g00000JFo59AAD'))      return 'a300g000002PgCgAAK'; //Patch Major NJ 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2ZAAS') || prematches.get('Email Domain').contains('a310g000006Nk3jAAC'))      return 'a300g000001IBjcAAG'; //Patch All Japan 2 - LE Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo5CAAT') || prematches.get('Email Domain').contains('a310g00000JFo5DAAT'))      return 'a300g000002PgChAAK'; //Patch Major NorCal 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo5GAAT') || prematches.get('Email Domain').contains('a310g00000JFo5HAAT'))      return 'a300g000002PgCiAAK'; //Patch Major Nordics 3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo5KAAT') || prematches.get('Email Domain').contains('a310g00000JFo5LAAT'))      return 'a300g000002PgCjAAK'; //Patch Major North Florida - Named Accounts
    if(prematches.get('Company Name').contains('a3170000003sBtUAAU') || prematches.get('Email Domain').contains('a3170000003sBtVAAU'))      return 'a30700000019Ve2AAE'; //Patch Major Korea - LE Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo5OAAT') || prematches.get('Email Domain').contains('a310g00000JFo5PAAT'))      return 'a300g000002PgCkAAK'; //Patch Major NYM 3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo5SAAT') || prematches.get('Email Domain').contains('a310g00000JFo5TAAT'))      return 'a300g000002PgClAAK'; //Patch Major NYM 4 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo5WAAT') || prematches.get('Email Domain').contains('a310g00000JFo5XAAT'))      return 'a300g000002PgCmAAK'; //Patch Major NYM 5 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo5aAAD') || prematches.get('Email Domain').contains('a310g00000JFo5bAAD'))      return 'a300g000002PgCnAAK'; //Patch Major NYM 6 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo5eAAD') || prematches.get('Email Domain').contains('a310g00000JFo5fAAD'))      return 'a300g000002PgCoAAK'; //Patch Major Phili 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo5iAAD') || prematches.get('Email Domain').contains('a310g00000JFo5jAAD'))      return 'a300g000002PgCpAAK'; //Patch Major Phili 3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo5mAAD') || prematches.get('Email Domain').contains('a310g00000JFo5nAAD'))      return 'a300g000002PgCqAAK'; //Patch Major Phili 4 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo5qAAD') || prematches.get('Email Domain').contains('a310g00000JFo5rAAD'))      return 'a300g000002PgCrAAK'; //Patch Major Phili 5 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo5uAAD') || prematches.get('Email Domain').contains('a310g00000JFo5vAAD'))      return 'a300g000002PgCsAAK'; //Patch Major Rockies 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo5yAAD') || prematches.get('Email Domain').contains('a310g00000JFo5zAAD'))      return 'a300g000002PgCtAAK'; //Patch Major Rockies 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo62AAD') || prematches.get('Email Domain').contains('a310g00000JFo63AAD'))      return 'a300g000002PgCuAAK'; //Patch Major SoCal - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo66AAD') || prematches.get('Email Domain').contains('a310g00000JFo67AAD'))      return 'a300g000002PgCvAAK'; //Patch Major South Florida - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo6AAAT') || prematches.get('Email Domain').contains('a310g00000JFo6BAAT'))      return 'a300g000002PgCwAAK'; //Patch Major Southeast 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo6EAAT') || prematches.get('Email Domain').contains('a310g00000JFo6FAAT'))      return 'a300g000002PgCxAAK'; //Patch MAJOR SWI 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo6IAAT') || prematches.get('Email Domain').contains('a310g00000JFo6JAAT'))      return 'a300g000002PgCyAAK'; //Patch Major TN - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo6MAAT') || prematches.get('Email Domain').contains('a310g00000JFo6NAAT'))      return 'a300g000002PgCzAAK'; //Patch Major UK 5 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo6OAAT') || prematches.get('Email Domain').contains('a310g00000JFo6PAAT'))      return 'a300g000002PgD0AAK'; //Patch Major UK 6 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo6QAAT') || prematches.get('Email Domain').contains('a310g00000JFo6RAAT'))      return 'a300g000002PgD1AAK'; //Patch Major UK 7 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo6SAAT') || prematches.get('Email Domain').contains('a310g00000JFo6TAAT'))      return 'a300g000002PgD2AAK'; //Patch Major UK 8 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo6UAAT') || prematches.get('Email Domain').contains('a310g00000JFo6VAAT'))      return 'a300g000002PgD3AAK'; //Patch Major WI - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsZdAAI') || prematches.get('Email Domain').contains('a310g000003tsZcAAI'))      return 'a300g0000019xTtAAI'; //Patch LE SoCal 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsgcAAA') || prematches.get('Email Domain').contains('a310g000003tsgdAAA'))      return 'a300g0000019xWCAAY'; //Patch LE SoCal 2 Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsdMAAQ') || prematches.get('Email Domain').contains('a310g000003tsdNAAQ'))      return 'a300g0000019xV5AAI'; //Patch ENT NY Metro 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsfWAAQ') || prematches.get('Email Domain').contains('a310g000003tsfXAAQ'))      return 'a300g0000019xU0AAI'; //Patch LE New England 1
    if(prematches.get('Company Name').contains('a310g000003tsfRAAQ') || prematches.get('Email Domain').contains('a310g000003tsfQAAQ'))      return 'a300g0000019xU3AAI'; //Patch LE New England 2 - Named Accounts
    return null;
  }
  private Id matchGroup6(PatchDataModel.MatchTarget t)
  {
    if(prematches.get('Company Name').contains('a310g000003tsePAAQ') || prematches.get('Email Domain').contains('a310g000003tseOAAQ'))      return 'a300g0000019xToAAI'; //Patch LE FL - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsfEAAQ') || prematches.get('Email Domain').contains('a310g000003tsfFAAQ'))      return 'a300g0000019xVhAAI'; //Patch Major Dallas 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsfCAAQ') || prematches.get('Email Domain').contains('a310g000003tsfDAAQ'))      return 'a300g0000019xU8AAI'; //Patch ENT TN/MS/AL - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsfiAAA') || prematches.get('Email Domain').contains('a310g000003tsfjAAA'))      return 'a300g0000019xUQAAY'; //Patch LE Georgia - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tse9AAA') || prematches.get('Email Domain').contains('a310g000003tse8AAA'))      return 'a300g0000019xUgAAI'; //Patch LE NorCal 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsekAAA') || prematches.get('Email Domain').contains('a310g000003tselAAA'))      return 'a300g0000019xUeAAI'; //Patch LE Illinois - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2nAAC') || prematches.get('Email Domain').contains('a310g000006Nk3xAAC'))      return 'a300g000001IBjqAAG'; //Patch Major Michigan 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsgfAAA') || prematches.get('Email Domain').contains('a310g000003tsgeAAA'))      return 'a300g0000019xW3AAI'; //Patch LE Canada East - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsgGAAQ') || prematches.get('Email Domain').contains('a310g000003tsgFAAQ'))      return 'a300g0000019xW8AAI'; //Patch LE Canada West - Named Accounts
    if(prematches.get('Company Name').contains('a310g000008H506AAC') || prematches.get('Email Domain').contains('a310g000008H50BAAS'))      return 'a300g000001beqoAAA'; //Patch LE Canada Central Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsgWAAQ') || prematches.get('Email Domain').contains('a310g000003tsgXAAQ'))      return 'a300g0000019xVnAAI'; //Patch LE UK 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsf3AAA') || prematches.get('Email Domain').contains('a310g000003tsf2AAA'))      return 'a300g0000019xVmAAI'; //Patch LE UK 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsfrAAA') || prematches.get('Email Domain').contains('a310g000003tsfqAAA'))      return 'a300g0000019xVrAAI'; //Patch LE UK 3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsgMAAQ') || prematches.get('Email Domain').contains('a310g000003tsgLAAQ'))      return 'a300g0000019xVpAAI'; //Patch LE UK 4 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tseiAAA') || prematches.get('Email Domain').contains('a310g000003tsejAAA'))      return 'a300g0000019xUbAAI'; //Patch LE GER 1 Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsezAAA') || prematches.get('Email Domain').contains('a310g000003tseyAAA'))      return 'a300g0000019xUVAAY'; //Patch LE GER 2 Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tse7AAA') || prematches.get('Email Domain').contains('a310g000003tse6AAA'))      return 'a300g0000019xUcAAI'; //Patch LE GER 3 Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tseAAAQ') || prematches.get('Email Domain').contains('a310g000003tseBAAQ'))      return 'a300g0000019xUxAAI'; //Patch LE FR Public - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsfwAAA') || prematches.get('Email Domain').contains('a310g000003tsfxAAA'))      return 'a300g0000019xW7AAI'; //Patch LE FR 2 Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsZpAAI') || prematches.get('Email Domain').contains('a310g000003tsZoAAI'))      return 'a300g0000019xV1AAI'; //Patch LE FR 3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsg5AAA') || prematches.get('Email Domain').contains('a310g000003tsg6AAA'))      return 'a300g0000019xWAAAY'; //Patch LE FR 4 Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tseUAAQ') || prematches.get('Email Domain').contains('a310g000003tseVAAQ'))      return 'a300g0000019xUTAAY'; //Patch LE FR 3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsZeAAI') || prematches.get('Email Domain').contains('a310g000003tsZfAAI'))      return 'a300g0000019xVEAAY'; //Patch LE Netherlands Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsenAAA') || prematches.get('Email Domain').contains('a310g000003tsemAAA'))      return 'a300g0000019xUHAAY'; //Patch LE Sweden Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsZbAAI') || prematches.get('Email Domain').contains('a310g000003tsZaAAI'))      return 'a300g0000019xTxAAI'; //Patch LE BeLux Named Accounts
    return null;
  }
  //returns the matched patch
  global PatchDataModel.PatchInfo match(PatchDataModel.MatchTarget t)
  {
    Id result = null;
    prematches = prematchList(t);
    result = matchGroup1(t);
    if(result != null) return processResult(result);
    result = matchGroup2(t);
    if(result != null) return processResult(result);
    result = matchGroup3(t);
    if(result != null) return processResult(result);
    result = matchGroup4(t);
    if(result != null) return processResult(result);
    result = matchGroup5(t);
    if(result != null) return processResult(result);
    result = matchGroup6(t);
    if(result != null) return processResult(result);
    return null;
  }
}