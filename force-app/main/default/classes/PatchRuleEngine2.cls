/*
 * This class is generated dynamically from Patch Rules.
 */
global class PatchRuleEngine2 extends  PatchRuleEngineBase implements IPatchRuleEngine
{
  private Id matchGroup1(PatchDataModel.MatchTarget t)
  {
    if(prematches.get('Company Name').contains('a310g000008I8JaAAK') || prematches.get('Email Domain').contains('a310g000008I8JfAAK'))      return 'a300g000001dKK1AAM'; //Patch LE Missouri - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsdHAAQ') || prematches.get('Email Domain').contains('a310g000003tsdGAAQ'))      return 'a300g0000019xV4AAI'; //Patch LE NYM 4 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsdCAAQ') || prematches.get('Email Domain').contains('a310g000003tsdDAAQ'))      return 'a300g0000019xVIAAY'; //Patch Major Phili 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tseGAAQ') || prematches.get('Email Domain').contains('a310g000003tseHAAQ'))      return 'a300g0000019xUNAAY'; //Patch LE Mid-Atlantic 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsdEAAQ') || prematches.get('Email Domain').contains('a310g000003tsdFAAQ'))      return 'a300g0000019xV3AAI'; //Patch LE NYM 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000004ZyfTAAS') || prematches.get('Email Domain').contains('a310g000004ZyfYAAS'))      return 'a300g000001iFzkAAE'; //Patch LE Carolinas 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000004ZyfdAAC') || prematches.get('Email Domain').contains('a310g000004ZyfiAAC'))      return 'a300g000001iFzpAAE'; //Patch LE Mid-Atlantic 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000004ZyfxAAC') || prematches.get('Email Domain').contains('a310g000004Zyg2AAC'))      return 'a300g000001iFzuAAE'; //Patch LE New England 3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000004ZygWAAS') || prematches.get('Email Domain').contains('a310g000004ZygbAAC'))      return 'a300g000001iG09AAE'; //Patch LE NYM 3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000008IFTJAA4') || prematches.get('Email Domain').contains('a310g000008IFTOAA4'))      return 'a300g000001debPAAQ'; //Patch ENT Michigan - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000AyFqwAAF') || prematches.get('Email Domain').contains('a310g00000AyFqxAAF'))      return 'a300g000001XNXrAAO'; //Patch LE Latam Named Accounts
    if(prematches.get('Company Name').contains('a310g00000DsEWMAA3') || prematches.get('Email Domain').contains('a310g00000DsEWWAA3'))      return 'a300g000001xrC7AAI'; //Patch Major Dallas 3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000DsEXKAA3') || prematches.get('Email Domain').contains('a310g00000DsEXPAA3'))      return 'a300g000001xrCCAAY'; //Patch Major Houston 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsa2AAA') || prematches.get('Email Domain').contains('a310g000003tsa1AAA'))      return 'a300g0000019xTuAAI'; //Patch LE Desert Region - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk30AAC') || prematches.get('Email Domain').contains('a310g000006Nk4AAAS'))      return 'a300g000001IBk3AAG'; //Patch LE Desert Region - Named Accounts
    if(prematches.get('Company Name').contains('a310g000004s9BqAAI') || prematches.get('Email Domain').contains('a310g000004s9BvAAI'))      return 'a300g0000007xAMAAY'; //Patch LE NYM 4 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsdvAAA') || prematches.get('Email Domain').contains('a310g000003tsduAAA'))      return 'a300g0000019xUtAAI'; //Patch ENT Ohio North - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk32AAC') || prematches.get('Email Domain').contains('a310g000006Nk4CAAS'))      return 'a300g000001IBk5AAG'; //Patch ENT Ohio North - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsdRAAQ') || prematches.get('Email Domain').contains('a310g000003tsdQAAQ'))      return 'a300g0000019xUuAAI'; //Patch LE Ohio/KY - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2vAAC') || prematches.get('Email Domain').contains('a310g000006Nk45AAC'))      return 'a300g000001IBjyAAG'; //Patch LE Ohio/KY - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2SAAS') || prematches.get('Email Domain').contains('a310g000006Nk3cAAC'))      return 'a300g000001IBjVAAW'; //Patch Major Phili 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsfLAAQ') || prematches.get('Email Domain').contains('a310g000003tsfKAAQ'))      return 'a300g0000019xU4AAI'; //Patch ENT Rockies - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2zAAC') || prematches.get('Email Domain').contains('a310g000006Nk49AAC'))      return 'a300g000001IBk2AAG'; //Patch LE Rockies - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsg9AAA') || prematches.get('Email Domain').contains('a310g000003tsgAAAQ'))      return 'a300g0000019xU7AAI'; //Patch LE Indiana - Named Accounts
    if(prematches.get('Company Name').contains('a310g000004s9AYAAY') || prematches.get('Email Domain').contains('a310g000004s9AdAAI'))      return 'a300g0000007xARAAY'; //Patch LE Indiana - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsdxAAA') || prematches.get('Email Domain').contains('a310g000003tsdwAAA'))      return 'a300g0000019xUqAAI'; //Patch LE North Florida - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2QAAS') || prematches.get('Email Domain').contains('a310g000006Nk3aAAC'))      return 'a300g000001IBjTAAW'; //Patch LE North Florida - Named Accounts
    if(prematches.get('Company Name').contains('a3170000003F3HFAA0') || prematches.get('Email Domain').contains('a3170000003F3HGAA0'))      return 'a3070000000F2XUAA0'; //Patch LE/M LatAm - Named Accounts
    if(prematches.get('Company Name').contains('a310g000004kS0MAAU') || prematches.get('Email Domain').contains('a310g000004kS0RAAU'))      return 'a300g0000015RF7AAM'; //Patch ENT LatAm - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tseTAAQ') || prematches.get('Email Domain').contains('a310g000003tseSAAQ'))      return 'a300g0000019xUsAAI'; //Patch ENT AT - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsdyAAA') || prematches.get('Email Domain').contains('a310g000003tsdzAAA'))      return 'a300g0000019xUwAAI'; //Patch LE Denmark - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsglAAA') || prematches.get('Email Domain').contains('a310g000003tsgiAAA'))      return 'a300g0000019xW2AAI'; //Patch ENT CEE - Named Accounts
    if(prematches.get('Company Name').contains('a310g000004s9CFAAY') || prematches.get('Email Domain').contains('a310g000004s9CKAAY'))      return 'a300g0000007xAWAAY'; //Patch ENT Iberia 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2aAAC') || prematches.get('Email Domain').contains('a310g000006Nk3kAAC'))      return 'a300g000001IBjdAAG'; //Patch LE Iberia 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000004s9BbAAI') || prematches.get('Email Domain').contains('a310g000004s9BgAAI'))      return 'a300g0000007xBKAAY'; //Patch LE Italy 1 - Named Accounts
    return null;
  }
  private Id matchGroup2(PatchDataModel.MatchTarget t)
  {
    if(prematches.get('Company Name').contains('a310g000006Nk2hAAC') || prematches.get('Email Domain').contains('a310g000006Nk3rAAC'))      return 'a300g000001IBjkAAG'; //Patch ENT Italy 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tseNAAQ') || prematches.get('Email Domain').contains('a310g000003tseMAAQ'))      return 'a300g0000019xURAAY'; //Patch LE Norway - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tseKAAQ') || prematches.get('Email Domain').contains('a310g000003tseLAAQ'))      return 'a300g0000019xUvAAI'; //Patch ENT Sweden Finland - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2OAAS') || prematches.get('Email Domain').contains('a310g000006Nk3YAAS'))      return 'a300g000001IBjRAAW'; //Patch LE MEA - Large Enterprise - LE Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk24AAC') || prematches.get('Email Domain').contains('a310g000006Nk3EAAS'))      return 'a300g000001IBj7AAG'; //Patch ENT ANZ North 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2PAAS') || prematches.get('Email Domain').contains('a310g000006Nk3ZAAS'))      return 'a300g000001IBjSAAW'; //Patch Major AU North 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2LAAS') || prematches.get('Email Domain').contains('a310g000006Nk3VAAS'))      return 'a300g000001IBjOAAW'; //Patch Major AU North 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2NAAS') || prematches.get('Email Domain').contains('a310g000006Nk3XAAS'))      return 'a300g000001IBjQAAW'; //Patch Major AU South 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2AAAS') || prematches.get('Email Domain').contains('a310g000006Nk3KAAS'))      return 'a300g000001IBjDAAW'; //Patch LE AU South 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000DtrLeAAJ') || prematches.get('Email Domain').contains('a310g00000DtrLfAAJ'))      return 'a300g0000022HPcAAM'; //Patch LE Gov ANZ - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000DtrLqAAJ') || prematches.get('Email Domain').contains('a310g00000DtrLrAAJ'))      return 'a300g0000022HPiAAM'; //Patch LE Japan 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo38AAD') || prematches.get('Email Domain').contains('a310g00000JFo39AAD'))      return 'a300g000002PgBgAAK'; //Patch LE AU North 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo3CAAT') || prematches.get('Email Domain').contains('a310g00000JFo3DAAT'))      return 'a300g000002PgBhAAK'; //Patch LE BeNeLux 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo3GAAT') || prematches.get('Email Domain').contains('a310g00000JFo3HAAT'))      return 'a300g000002PgBiAAK'; //Patch LE Canada East 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo3KAAT') || prematches.get('Email Domain').contains('a310g00000JFo3LAAT'))      return 'a300g000002PgBjAAK'; //Patch LE Canada West 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo3OAAT') || prematches.get('Email Domain').contains('a310g00000JFo3PAAT'))      return 'a300g000002PgBkAAK'; //Patch LE Carolinas 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo3SAAT') || prematches.get('Email Domain').contains('a310g00000JFo3TAAT'))      return 'a300g000002PgBlAAK'; //Patch LE Central Texas - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo3WAAT') || prematches.get('Email Domain').contains('a310g00000JFo3XAAT'))      return 'a300g000002PgBmAAK'; //Patch LE Dallas 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo3aAAD') || prematches.get('Email Domain').contains('a310g00000JFo3bAAD'))      return 'a300g000002PgBnAAK'; //Patch LE Dallas 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo3eAAD') || prematches.get('Email Domain').contains('a310g00000JFo3fAAD'))      return 'a300g000002PgBoAAK'; //Patch LE Desert Region 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo3iAAD') || prematches.get('Email Domain').contains('a310g00000JFo3jAAD'))      return 'a300g000002PgBpAAK'; //Patch LE Heartland - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo3mAAD') || prematches.get('Email Domain').contains('a310g00000JFo3nAAD'))      return 'a300g000002PgBqAAK'; //Patch LE Houston 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo3qAAD') || prematches.get('Email Domain').contains('a310g00000JFo3rAAD'))      return 'a300g000002PgBrAAK'; //Patch LE Houston/LA - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo3uAAD') || prematches.get('Email Domain').contains('a310g00000JFo3vAAD'))      return 'a300g000002PgBsAAK'; //Patch LE Illinois 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo3yAAD') || prematches.get('Email Domain').contains('a310g00000JFo3zAAD'))      return 'a300g000002PgBtAAK'; //Patch LE India 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo42AAD') || prematches.get('Email Domain').contains('a310g00000JFo43AAD'))      return 'a300g000002PgBuAAK'; //Patch LE Japan 3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo46AAD') || prematches.get('Email Domain').contains('a310g00000JFo47AAD'))      return 'a300g000002PgBvAAK'; //Patch LE KS/MO - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo4AAAT') || prematches.get('Email Domain').contains('a310g00000JFo4BAAT'))      return 'a300g000002PgBwAAK'; //Patch LE LA - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo4EAAT') || prematches.get('Email Domain').contains('a310g00000JFo4FAAT'))      return 'a300g000002PgBxAAK'; //Patch LE Michigan 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo4IAAT') || prematches.get('Email Domain').contains('a310g00000JFo4JAAT'))      return 'a300g000002PgByAAK'; //Patch LE Michigan 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo4MAAT') || prematches.get('Email Domain').contains('a310g00000JFo4NAAT'))      return 'a300g000002PgBzAAK'; //Patch LE Mid-Atlantic 3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo4OAAT') || prematches.get('Email Domain').contains('a310g00000JFo4PAAT'))      return 'a300g000002PgC0AAK'; //Patch LE MN - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo4QAAT') || prematches.get('Email Domain').contains('a310g00000JFo4RAAT'))      return 'a300g000002PgC1AAK'; //Patch LE New England 4 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo4SAAT') || prematches.get('Email Domain').contains('a310g00000JFo4TAAT'))      return 'a300g000002PgC2AAK'; //Patch LE NorCal 3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo4UAAT') || prematches.get('Email Domain').contains('a310g00000JFo4VAAT'))      return 'a300g000002PgC3AAK'; //Patch LE Nordics 4 - Named Accounts
    return null;
  }
  private Id matchGroup3(PatchDataModel.MatchTarget t)
  {
    if(prematches.get('Company Name').contains('a310g00000JFo4WAAT') || prematches.get('Email Domain').contains('a310g00000JFo4XAAT'))      return 'a300g000002PgC4AAK'; //Patch LE NYM 6 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo4YAAT') || prematches.get('Email Domain').contains('a310g00000JFo4ZAAT'))      return 'a300g000002PgC5AAK'; //Patch LE NYM 7 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo4aAAD') || prematches.get('Email Domain').contains('a310g00000JFo4bAAD'))      return 'a300g000002PgC6AAK'; //Patch LE San Diego - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo4cAAD') || prematches.get('Email Domain').contains('a310g00000JFo4dAAD'))      return 'a300g000002PgC7AAK'; //Patch LE SE 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo4eAAD') || prematches.get('Email Domain').contains('a310g00000JFo4fAAD'))      return 'a300g000002PgC8AAK'; //Patch LE SE 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsfdAAA') || prematches.get('Email Domain').contains('a310g000003tsfcAAA'))      return 'a300g0000019xU6AAI'; //Patch ENT PNW - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2yAAC') || prematches.get('Email Domain').contains('a310g000006Nk48AAC'))      return 'a300g000001IBk1AAG'; //Patch Ent Mid-Atlantic 1 - ENT Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsffAAA') || prematches.get('Email Domain').contains('a310g000003tsfeAAA'))      return 'a300g0000019xUOAAY'; //Patch ENT NorCal 2
    if(prematches.get('Company Name').contains('a310g000006Nk21AAC') || prematches.get('Email Domain').contains('a310g000006Nk3BAAS'))      return 'a300g000001IBj4AAG'; //Patch LE NorCal 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsfTAAQ') || prematches.get('Email Domain').contains('a310g000003tsfSAAQ'))      return 'a300g0000019xTzAAI'; //Patch ENT SoCal 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsfaAAA') || prematches.get('Email Domain').contains('a310g000003tsfbAAA'))      return 'a300g0000019xU5AAI'; //Patch ENT SoCal 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsZrAAI') || prematches.get('Email Domain').contains('a310g000003tsZqAAI'))      return 'a300g0000019xTvAAI'; //Patch ENT PNW - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003u2r6AAA') || prematches.get('Email Domain').contains('a310g000003u2rBAAQ'))      return 'a300g0000019xwtAAA'; //Patch ENT PA Metro - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsdLAAQ') || prematches.get('Email Domain').contains('a310g000003tsdKAAQ'))      return 'a300g0000019xVFAAY'; //Patch ENT NY Metro 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2DAAS') || prematches.get('Email Domain').contains('a310g000006Nk3NAAS'))      return 'a300g000001IBjGAAW'; //Patch ENT NYM 3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000008GZABAA4') || prematches.get('Email Domain').contains('a310g000008GZAGAA4'))      return 'a300g000001aiBTAAY'; //Patch LE Houston - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsgYAAQ') || prematches.get('Email Domain').contains('a310g000003tsgZAAQ'))      return 'a300g0000019xVzAAI'; //Patch ENT SouthCentral 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsgDAAQ') || prematches.get('Email Domain').contains('a310g000003tsgEAAQ'))      return 'a300g0000019xW0AAI'; //Patch ENT SouthCentral 3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2FAAS') || prematches.get('Email Domain').contains('a310g000006Nk3PAAS'))      return 'a300g000001IBjIAAW'; //Patch ENT Dallas/OK - Named Accounts
    if(prematches.get('Company Name').contains('a310g000008GZ85AAG') || prematches.get('Email Domain').contains('a310g000008GZ8AAAW'))      return 'a300g000001aiBOAAY'; //Patch ENT Dallas/OK - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsfUAAQ') || prematches.get('Email Domain').contains('a310g000003tsfVAAQ'))      return 'a300g0000019xUMAAY'; //Patch ENT Georgia - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsfYAAQ') || prematches.get('Email Domain').contains('a310g000003tsfZAAQ'))      return 'a300g0000019xTyAAI'; //Patch ENT IL 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2HAAS') || prematches.get('Email Domain').contains('a310g000006Nk3RAAS'))      return 'a300g000001IBjKAAW'; //Patch ENT IL 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsZiAAI') || prematches.get('Email Domain').contains('a310g000003tsZjAAI'))      return 'a300g0000019xV0AAI'; //Patch ENT Michigan - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2xAAC') || prematches.get('Email Domain').contains('a310g000006Nk47AAC'))      return 'a300g000001IBk0AAG'; //Patch ENT Mid-Atlantic - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsfhAAA') || prematches.get('Email Domain').contains('a310g000003tsfgAAA'))      return 'a300g0000019xU2AAI'; //Patch ENT MN/WI 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2JAAS') || prematches.get('Email Domain').contains('a310g000006Nk3TAAS'))      return 'a300g000001IBjMAAW'; //Patch ENT MO - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsfNAAQ') || prematches.get('Email Domain').contains('a310g000003tsfMAAQ'))      return 'a300g0000019xUPAAY'; //Patch ENT New England - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsfIAAQ') || prematches.get('Email Domain').contains('a310g000003tsfJAAQ'))      return 'a300g0000019xU1AAI'; //Patch ENT New England 2
    if(prematches.get('Company Name').contains('a310g000006Nk2dAAC') || prematches.get('Email Domain').contains('a310g000006Nk3nAAC'))      return 'a300g000001IBjgAAG'; //Patch ENT New England 3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2lAAC') || prematches.get('Email Domain').contains('a310g000006Nk3vAAC'))      return 'a300g000001IBjoAAG'; //Patch ENT S.Ohio - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsfPAAQ') || prematches.get('Email Domain').contains('a310g000003tsfOAAQ'))      return 'a300g0000019xUKAAY'; //Patch ENT Carolinas - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsfBAAQ') || prematches.get('Email Domain').contains('a310g000003tsfAAAQ'))      return 'a300g0000019xVoAAI'; //Patch ENT Canada West - Named Accounts
    if(prematches.get('Company Name').contains('a310g000004aqxOAAQ') || prematches.get('Email Domain').contains('a310g000004aqxTAAQ'))      return 'a300g000001jYOKAA2'; //Patch ENT NYR - Named Accounts
    if(prematches.get('Company Name').contains('a3170000003sBtLAAU') || prematches.get('Email Domain').contains('a3170000003sBtKAAU'))      return 'a30700000019VdxAAE'; //Patch ENT 1 UK - Named Accounts
    return null;
  }
  private Id matchGroup4(PatchDataModel.MatchTarget t)
  {
    if(prematches.get('Company Name').contains('a310g000003tsgnAAA') || prematches.get('Email Domain').contains('a310g000003tsgmAAA'))      return 'a300g0000019xVsAAI'; //Patch ENT GER 1 Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsgCAAQ') || prematches.get('Email Domain').contains('a310g000003tsgBAAQ'))      return 'a300g0000019xVqAAI'; //Patch ENT GER 6-7 Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tuU1AAI') || prematches.get('Email Domain').contains('a310g000003tuUBAAY'))      return 'a300g0000019xY3AAI'; //Patch ENT GER 0-3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsfmAAA') || prematches.get('Email Domain').contains('a310g000003tsfnAAA'))      return 'a300g0000019xW4AAI'; //Patch ENT CH Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk1tAAC') || prematches.get('Email Domain').contains('a310g000006Nk33AAC'))      return 'a300g000001IBiwAAG'; //Patch LE CH 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsgOAAQ') || prematches.get('Email Domain').contains('a310g000003tsgNAAQ'))      return 'a300g0000019xVuAAI'; //Patch ENT BeLux Named Accounts
    if(prematches.get('Company Name').contains('a310g00000AyFqaAAF') || prematches.get('Email Domain').contains('a310g00000AyFqbAAF'))      return 'a300g000001XNXgAAO'; //Patch ENT Desert Region Named Accounts
    if(prematches.get('Company Name').contains('a310g00000AyFqeAAF') || prematches.get('Email Domain').contains('a310g00000AyFqfAAF'))      return 'a300g000001XNXiAAO'; //Patch ENT IN/KY Named Accounts
    if(prematches.get('Company Name').contains('a310g00000AyFqgAAF') || prematches.get('Email Domain').contains('a310g00000AyFqhAAF'))      return 'a300g000001XNXjAAO'; //Patch ENT North Florida Named Accounts
    if(prematches.get('Company Name').contains('a310g00000AyFqiAAF') || prematches.get('Email Domain').contains('a310g00000AyFqjAAF'))      return 'a300g000001XNXkAAO'; //Patch ENT Rockies Named Accounts
    if(prematches.get('Company Name').contains('a310g00000AyFqkAAF') || prematches.get('Email Domain').contains('a310g00000AyFqlAAF'))      return 'a300g000001XNXlAAO'; //Patch ENT South Florida Named Accounts
    if(prematches.get('Company Name').contains('a310g00000AyFqmAAF') || prematches.get('Email Domain').contains('a310g00000AyFqnAAF'))      return 'a300g000001XNXmAAO'; //Patch ENT MN/WI 1 Named Accounts
    if(prematches.get('Company Name').contains('a310g00000AyGxCAAV') || prematches.get('Email Domain').contains('a310g00000AyGxHAAV'))      return 'a300g000001XWUsAAO'; //Patch ENT Canada 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000DtrLiAAJ') || prematches.get('Email Domain').contains('a310g00000DtrLjAAJ'))      return 'a300g0000022HPeAAM'; //Patch ENT ANZ - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000DtrLsAAJ') || prematches.get('Email Domain').contains('a310g00000DtrLtAAJ'))      return 'a300g0000022HPjAAM'; //Patch ENT Japan 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000DsEVnAAN') || prematches.get('Email Domain').contains('a310g00000DsEVsAAN'))      return 'a300g000001xrC2AAI'; //Patch ENT DFW 3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk29AAC') || prematches.get('Email Domain').contains('a310g000006Nk3JAAS'))      return 'a300g000001IBjCAAW'; //Patch ENT TN/MS/AL 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000DtrM0AAJ') || prematches.get('Email Domain').contains('a310g00000DtrM1AAJ'))      return 'a300g0000022HPnAAM'; //Patch ENT India West - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk2BAAS') || prematches.get('Email Domain').contains('a310g000006Nk3LAAS'))      return 'a300g000001IBjEAAW'; //Patch ENT TN/MS/AL 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000DtyvMAAR') || prematches.get('Email Domain').contains('a310g00000DtyvRAAR'))      return 'a300g0000022mrNAAQ'; //Patch ENT NYM 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JEbIJAA1') || prematches.get('Email Domain').contains('a310g00000JEbIOAA1'))      return 'a300g000002M9dpAAC'; //Patch ENT Canada 3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JErRWAA1') || prematches.get('Email Domain').contains('a310g00000JErRvAAL'))      return 'a300g000002MpFtAAK'; //Patch ENT FR 4 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo36AAD') || prematches.get('Email Domain').contains('a310g00000JFo37AAD'))      return 'a300g000002PgBGAA0'; //Patch ENT AU South 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo3AAAT') || prematches.get('Email Domain').contains('a310g00000JFo3BAAT'))      return 'a300g000002PgBHAA0'; //Patch ENT AU South 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo3EAAT') || prematches.get('Email Domain').contains('a310g00000JFo3FAAT'))      return 'a300g000002PgBIAA0'; //Patch ENT AUSTRIA 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo3IAAT') || prematches.get('Email Domain').contains('a310g00000JFo3JAAT'))      return 'a300g000002PgBJAA0'; //Patch ENT Canada 4 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo3MAAT') || prematches.get('Email Domain').contains('a310g00000JFo3NAAT'))      return 'a300g000002PgBKAA0'; //Patch ENT Carolinas 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo3QAAT') || prematches.get('Email Domain').contains('a310g00000JFo3RAAT'))      return 'a300g000002PgBLAA0'; //Patch ENT Central TX - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo3UAAT') || prematches.get('Email Domain').contains('a310g00000JFo3VAAT'))      return 'a300g000002PgBMAA0'; //Patch ENT FR 5 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo3YAAT') || prematches.get('Email Domain').contains('a310g00000JFo3ZAAT'))      return 'a300g000002PgBNAA0'; //Patch ENT FR 6 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo3cAAD') || prematches.get('Email Domain').contains('a310g00000JFo3dAAD'))      return 'a300g000002PgBOAA0'; //Patch ENT GA, AL, MS - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo3gAAD') || prematches.get('Email Domain').contains('a310g00000JFo3hAAD'))      return 'a300g000002PgBPAA0'; //Patch ENT GER 4 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo3kAAD') || prematches.get('Email Domain').contains('a310g00000JFo3lAAD'))      return 'a300g000002PgBQAA0'; //Patch ENT GER 5 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo3oAAD') || prematches.get('Email Domain').contains('a310g00000JFo3pAAD'))      return 'a300g000002PgBRAA0'; //Patch ENT IL 3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo3sAAD') || prematches.get('Email Domain').contains('a310g00000JFo3tAAD'))      return 'a300g000002PgBSAA0'; //Patch ENT Mid-Atlantic 3 - Named Accounts
    return null;
  }
  private Id matchGroup5(PatchDataModel.MatchTarget t)
  {
    if(prematches.get('Company Name').contains('a310g00000JFo3wAAD') || prematches.get('Email Domain').contains('a310g00000JFo3xAAD'))      return 'a300g000002PgBTAA0'; //Patch ENT MN/WI 3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo40AAD') || prematches.get('Email Domain').contains('a310g00000JFo41AAD'))      return 'a300g000002PgBUAA0'; //Patch ENT New England 4 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo44AAD') || prematches.get('Email Domain').contains('a310g00000JFo45AAD'))      return 'a300g000002PgBVAA0'; //Patch ENT NorCal 1 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo48AAD') || prematches.get('Email Domain').contains('a310g00000JFo49AAD'))      return 'a300g000002PgBWAA0'; //Patch ENT NorCal 3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo4CAAT') || prematches.get('Email Domain').contains('a310g00000JFo4DAAT'))      return 'a300g000002PgBXAA0'; //Patch ENT NYM 4 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo4GAAT') || prematches.get('Email Domain').contains('a310g00000JFo4HAAT'))      return 'a300g000002PgBYAA0'; //Patch ENT NYM 5 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo4KAAT') || prematches.get('Email Domain').contains('a310g00000JFo4LAAT'))      return 'a300g000002PgBZAA0'; //Patch Ent Ohio 3 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo2kAAD') || prematches.get('Email Domain').contains('a310g00000JFo2lAAD'))      return 'a300g000002PgBaAAK'; //Patch ENT Orange County - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo2oAAD') || prematches.get('Email Domain').contains('a310g00000JFo2pAAD'))      return 'a300g000002PgBbAAK'; //Patch Ent Rockies 2 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo2sAAD') || prematches.get('Email Domain').contains('a310g00000JFo2tAAD'))      return 'a300g000002PgBcAAK'; //Patch ENT UK 5 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo2wAAD') || prematches.get('Email Domain').contains('a310g00000JFo2xAAD'))      return 'a300g000002PgBdAAK'; //Patch ENT UK 7 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo30AAD') || prematches.get('Email Domain').contains('a310g00000JFo31AAD'))      return 'a300g000002PgBeAAK'; //Patch ENT UK 8 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFo34AAD') || prematches.get('Email Domain').contains('a310g00000JFo35AAD'))      return 'a300g000002PgBfAAK'; //Patch ENT UK 9 - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JG6qrAAD') || prematches.get('Email Domain').contains('a310g00000JG6qwAAD'))      return 'a300g000002QhwBAAS'; //Patch ENT UK 10 - Named Accounts
    if(prematches.get('Company Name').contains('a3170000002l0Y3AAI') || prematches.get('Email Domain').contains('a3170000002l0Y8AAI'))      return 'a3070000000Tjk7AAC'; //Patch Catch All - India Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tuboAAA') || prematches.get('Email Domain').contains('a310g000003tubtAAA'))      return 'a300g0000019xY8AAI'; //Patch Catch All ENT Canada Named Accounts
    if(prematches.get('Company Name').contains('a310g00000B0PixAAF') || prematches.get('Email Domain').contains('a310g00000B0Pj2AAF'))      return 'a300g000001pFbiAAE'; //Patch Catch All - Public Sector - US West (Named Account)
    if(prematches.get('Company Name').contains('a310g00000B0PfZAAV') || prematches.get('Email Domain').contains('a310g00000B0PfeAAF'))      return 'a300g000001pFZvAAM'; //Patch Catch All - Public Sector - US East (Named Accounts)
    if(prematches.get('Company Name').contains('a310g00000B0PfjAAF') || prematches.get('Email Domain').contains('a310g00000B0PfoAAF'))      return 'a300g000001pFa0AAE'; //Patch Catch All - Public Sector - US Central (Named Accounts)
    if(prematches.get('Company Name').contains('a310g000006NkAQAA0') || prematches.get('Email Domain').contains('a310g000006NkAVAA0'))      return 'a300g000001IBl9AAG'; //Patch Catch All - Public Sector - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk0CAAS') || prematches.get('Email Domain').contains('a310g000006Nk0HAAS'))      return 'a300g000001IBiSAAW'; //Patch Catch All Mid Atlantic - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tseqAAA') || prematches.get('Email Domain').contains('a310g000003tsesAAA'))      return 'a300g0000019xUGAAY'; //Patch Catch All New England 2 Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsetAAA') || prematches.get('Email Domain').contains('a310g000003tserAAA'))      return 'a300g0000019xU9AAI'; //Patch Catch All New England 1 Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsdjAAA') || prematches.get('Email Domain').contains('a310g000003tsdiAAA'))      return 'a300g0000019xUDAAY'; //Patch Catch All Northcentral - On hold Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsfHAAQ') || prematches.get('Email Domain').contains('a310g000003tsfGAAQ'))      return 'a300g0000019xVGAAY'; //Patch Catch All Northeast - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tseFAAQ') || prematches.get('Email Domain').contains('a310g000003tseEAAQ'))      return 'a300g0000019xULAAY'; //Patch Catch All West Named Accounts
    if(prematches.get('Company Name').contains('a310g00000CmDs6AAF') || prematches.get('Email Domain').contains('a310g00000CmDsBAAV'))      return 'a300g000002ErR3AAK'; //Patch Catch All Heartland & Rockies - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk02AAC') || prematches.get('Email Domain').contains('a310g000006Nk07AAC'))      return 'a300g000001IBiNAAW'; //Patch Catch All Japan - Named based
    if(prematches.get('Company Name').contains('a310g000006NjznAAC') || prematches.get('Email Domain').contains('a310g000006NjzsAAC'))      return 'a300g000001IBiIAAW'; //Patch Catch All - ASEAN - Named List
    if((opIn(t.country, new Set<String> { 'us', 'usa', 'u.s.', 'u.s.a', 'united states', 'united states of america' }) && opIn(t.state, new Set<String> { 'md', 'va', 'dc', 'nc', 'sc', 'ma', 'me', 'nh', 'ri', 'vt', 'ct', 'de', 'nj', 'ny', 'pa', 'ga', 'tn', 'ky', 'fl', 'al', 'wv', 'maryland', 'virginia', 'district of columbia', 'north carolina', 'south dakota', 'massachusetts', 'maine', 'new hampshire', 'rhode island', 'vermont', 'connecticut', 'delaware', 'new jersey', 'new york', 'pennsylvania', 'georgia', 'tennessee', 'kentucky', 'florida', 'alabama', 'west virginia' }) && opContain(t.custom3, '.gov')) || (opIn(t.country, new Set<String> { 'us', 'usa', 'u.s.', 'u.s.a', 'united states', 'united states of america' }) && opIn(t.state, new Set<String> { 'md', 'va', 'dc', 'nc', 'sc', 'ma', 'me', 'nh', 'ri', 'vt', 'ct', 'de', 'nj', 'ny', 'pa', 'ga', 'tn', 'ky', 'fl', 'al', 'wv', 'maryland', 'virginia', 'district of columbia', 'north carolina', 'south dakota', 'massachusetts', 'maine', 'new hampshire', 'rhode island', 'vermont', 'connecticut', 'delaware', 'new jersey', 'new york', 'pennsylvania', 'georgia', 'tennessee', 'kentucky', 'florida', 'alabama', 'west virginia' }) && opContain(t.custom3, '.mil')) || (opIn(t.country, new Set<String> { 'us', 'usa', 'u.s.', 'u.s.a', 'united states', 'united states of america' }) && opIn(t.state, new Set<String> { 'md', 'va', 'dc', 'nc', 'sc', 'ma', 'me', 'nh', 'ri', 'vt', 'ct', 'de', 'nj', 'ny', 'pa', 'ga', 'tn', 'ky', 'fl', 'al', 'wv', 'maryland', 'virginia', 'district of columbia', 'north carolina', 'south dakota', 'massachusetts', 'maine', 'new hampshire', 'rhode island', 'vermont', 'connecticut', 'delaware', 'new jersey', 'new york', 'pennsylvania', 'georgia', 'tennessee', 'kentucky', 'florida', 'alabama', 'west virginia' }) && opContain(t.custom3, '.us')))      return 'a300g000001oT6BAAU'; //Patch Catch All - Public Sector - US East
    if((opIn(t.country, new Set<String> { 'us', 'usa', 'u.s.', 'u.s.a', 'united states', 'united states of america' }) && opIn(t.state, new Set<String> { 'ia', 'in', 'il', 'mn', 'wi', 'mo', 'oh', 'mi', 'pittsburgh', 'ar', 'ks', 'la', 'ok', 'tx', 'iowa', 'indiana', 'illinois', 'minnesota', 'wisconsin', 'missouri', 'ohio', 'michigan', 'arkansas', 'kansas', 'louisiana', 'oklahoma', 'texas', 'new mexico', 'nm', 'ms', 'mississippi' }) && opContain(t.custom3, '.gov')) || (opIn(t.country, new Set<String> { 'us', 'usa', 'u.s.', 'u.s.a', 'united states', 'united states of america' }) && opIn(t.state, new Set<String> { 'ia', 'in', 'il', 'mn', 'wi', 'mo', 'oh', 'mi', 'pittsburgh', 'ar', 'ks', 'la', 'ok', 'tx', 'iowa', 'indiana', 'illinois', 'minnesota', 'wisconsin', 'missouri', 'ohio', 'michigan', 'arkansas', 'kansas', 'louisiana', 'oklahoma', 'texas', 'new mexico', 'nm', 'ms', 'mississippi' }) && opContain(t.custom3, '.mil')) || (opIn(t.country, new Set<String> { 'us', 'usa', 'u.s.', 'u.s.a', 'united states', 'united states of america' }) && opIn(t.state, new Set<String> { 'ia', 'in', 'il', 'mn', 'wi', 'mo', 'oh', 'mi', 'pittsburgh', 'ar', 'ks', 'la', 'ok', 'tx', 'iowa', 'indiana', 'illinois', 'minnesota', 'wisconsin', 'missouri', 'ohio', 'michigan', 'arkansas', 'kansas', 'louisiana', 'oklahoma', 'texas', 'new mexico', 'nm', 'ms', 'mississippi' }) && opContain(t.custom3, '.us')))      return 'a300g000001oT6GAAU'; //Patch Catch All - Public Sector - US Central
    if((opIn(t.country, new Set<String> { 'us', 'usa', 'u.s.', 'u.s.a', 'united states', 'united states of america' }) && opIn(t.state, new Set<String> { 'ca', 'ak', 'co', 'id', 'mt', 'or', 'wa', 'wy', 'hi', 'nv', 'ut', 'az', 'california', 'arkansas', 'colorado', 'idaho', 'montana', 'oregon', 'washington', 'wyoming', 'hawaii', 'nevada', 'utah', 'arizona', 'north dakota', 'nebraska', 'south dakota', 'nd', 'ne', 'sd' }) && opContain(t.custom3, '.gov')) || (opIn(t.country, new Set<String> { 'us', 'usa', 'u.s.', 'u.s.a', 'united states', 'united states of america' }) && opIn(t.state, new Set<String> { 'ca', 'ak', 'co', 'id', 'mt', 'or', 'wa', 'wy', 'hi', 'nv', 'ut', 'az', 'california', 'arkansas', 'colorado', 'idaho', 'montana', 'oregon', 'washington', 'wyoming', 'hawaii', 'nevada', 'utah', 'arizona', 'north dakota', 'nebraska', 'south dakota', 'nd', 'ne', 'sd' }) && opContain(t.custom3, '.mil')) || (opIn(t.country, new Set<String> { 'us', 'usa', 'u.s.', 'u.s.a', 'united states', 'united states of america' }) && opIn(t.state, new Set<String> { 'ca', 'ak', 'co', 'id', 'mt', 'or', 'wa', 'wy', 'hi', 'nv', 'ut', 'az', 'california', 'arkansas', 'colorado', 'idaho', 'montana', 'oregon', 'washington', 'wyoming', 'hawaii', 'nevada', 'utah', 'arizona', 'north dakota', 'nebraska', 'south dakota', 'nd', 'ne', 'sd' }) && opContain(t.custom3, '.us')))      return 'a300g000001oT66AAE'; //Patch Catch All - Public Sector - US West
    if(((opIn(t.country, new Set<String> { 'us', 'usa', 'u.s.', 'u.s.a', 'united states', 'united states of america' }) && opContain(t.custom3, '.mil')) || (opIn(t.country, new Set<String> { 'us', 'usa', 'u.s.', 'u.s.a', 'united states', 'united states of america' }) && opEqual(t.industry, 'Federal'))))      return 'a300g000001IBihAAG'; //Patch Catch All - Federal Domain
    if((opIn(t.country, new Set<String> { 'us', 'usa', 'u.s.', 'u.s.a', 'united states', 'united states of america' }) && opContain(t.custom3, '.gov')) || (opIn(t.country, new Set<String> { 'us', 'usa', 'u.s.', 'u.s.a', 'united states', 'united states of america' }) && opContain(t.custom3, '.mil')) || (opIn(t.country, new Set<String> { 'us', 'usa', 'u.s.', 'u.s.a', 'united states', 'united states of america' }) && opContain(t.custom3, '.us')))      return 'a300g0000015SMxAAM'; //Patch Catch All - Public Sector
    if(prematches.get('Company Name').contains('a310g00000JFrYHAA1') || prematches.get('Email Domain').contains('a310g00000JFrYWAA1'))      return 'a300g000002PqeKAAS'; //Patch Catch All ENT Benelux - Named Accounts
    return null;
  }
  private Id matchGroup6(PatchDataModel.MatchTarget t)
  {
    if(prematches.get('Company Name').contains('a310g00000JFrbLAAT') || prematches.get('Email Domain').contains('a310g00000JFrbMAAT'))      return 'a300g000002PqePAAS'; //Patch Catch All ENT Alpine - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFrbNAAT') || prematches.get('Email Domain').contains('a310g00000JFrbOAAT'))      return 'a300g000002PqeQAAS'; //Patch Catch All - ANZ - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFrbPAAT') || prematches.get('Email Domain').contains('a310g00000JFrbQAAT'))      return 'a300g000002PqeRAAS'; //Patch Catch All LE Iberia & Italy - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFrbRAAT') || prematches.get('Email Domain').contains('a310g00000JFrbSAAT'))      return 'a300g000002PqeSAAS'; //Patch Catch All ENT Iberia & Italy - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFrbTAAT') || prematches.get('Email Domain').contains('a310g00000JFrbUAAT'))      return 'a300g000002PqeTAAS'; //Patch Catch All GLR ENT - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFrbVAAT') || prematches.get('Email Domain').contains('a310g00000JFrbWAAT'))      return 'a300g000002PqeUAAS'; //Patch Catch All ENT CEE - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFrbXAAT') || prematches.get('Email Domain').contains('a310g00000JFrbYAAT'))      return 'a300g000002PqeVAAS'; //Patch Catch All GLR Major - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFrbZAAT') || prematches.get('Email Domain').contains('a310g00000JFrbaAAD'))      return 'a300g000002PqeWAAS'; //Patch Catch All LE Benelux - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000JFrbbAAD') || prematches.get('Email Domain').contains('a310g00000JFrbcAAD'))      return 'a300g000002PqeXAAS'; //Patch Catch All LE Alpine - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsc1AAA') || prematches.get('Email Domain').contains('a310g000003tsc0AAA'))      return 'a300g0000019xWhAAI'; //Patch Catch All LE Nordics - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsaOAAQ') || prematches.get('Email Domain').contains('a310g000003tsaNAAQ'))      return 'a300g0000019xWeAAI'; //Patch Catch All LE Germany - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsbTAAQ') || prematches.get('Email Domain').contains('a310g000003tsbPAAQ'))      return 'a300g0000019xX3AAI'; //Patch Catch All LE Mid-Atlantic - Patch Match List
    if(prematches.get('Company Name').contains('a310g000003tsccAAA') || prematches.get('Email Domain').contains('a310g000003tscfAAA'))      return 'a300g0000019xWzAAI'; //Patch Catch All LE New England - Patch Match List
    if(prematches.get('Company Name').contains('a310g000003tsc8AAA') || prematches.get('Email Domain').contains('a310g000003tsc4AAA'))      return 'a300g0000019xX2AAI'; //Patch Catch All LE NorthCentral - Patch Match List
    if(prematches.get('Company Name').contains('a310g000003tsb6AAA') || prematches.get('Email Domain').contains('a310g000003tsb9AAA'))      return 'a300g0000019xWtAAI'; //Patch Catch All LE Northeast - Patch Match List
    if(prematches.get('Company Name').contains('a310g000003tscQAAQ') || prematches.get('Email Domain').contains('a310g000003tscMAAQ'))      return 'a300g0000019xWrAAI'; //Patch Catch All LE NorthWest - Patch Match List
    if(prematches.get('Company Name').contains('a310g000003tscmAAA') || prematches.get('Email Domain').contains('a310g000003tsclAAA'))      return 'a300g0000019xWuAAI'; //Patch Catch All LE Ohio Valley - Patch Match List
    if(prematches.get('Company Name').contains('a310g000003tsaqAAA') || prematches.get('Email Domain').contains('a310g000003tsarAAA'))      return 'a300g0000019xXBAAY'; //Patch Catch All LE SouthCentral - Patch Match List
    if(prematches.get('Company Name').contains('a310g000003tscXAAQ') || prematches.get('Email Domain').contains('a310g000003tscVAAQ'))      return 'a300g0000019xX9AAI'; //Patch Catch All LE SouthEast - Patch Match List
    if(prematches.get('Company Name').contains('a310g000003tsaKAAQ') || prematches.get('Email Domain').contains('a310g000003tsaJAAQ'))      return 'a300g0000019xX0AAI'; //Patch Catch All LE France - Named Accounts
    if(prematches.get('Company Name').contains('a310g000003tsaAAAQ') || prematches.get('Email Domain').contains('a310g000003tsaBAAQ'))      return 'a300g0000019xX7AAI'; //Patch Catch All LE SouthWest - Patch Match List
    if(prematches.get('Company Name').contains('a310g000003tsbUAAQ') || prematches.get('Email Domain').contains('a310g000003tsbXAAQ'))      return 'a300g0000019xX4AAI'; //Patch Catch All LE UK/Ireland - Patch Match List
    if(prematches.get('Company Name').contains('a3170000002d35PAAQ') || prematches.get('Email Domain').contains('a3170000002d35QAAQ'))      return 'a3070000000TW6tAAG'; //Patch Large ENT 1 Sydney-Named Account
    if(prematches.get('Company Name').contains('a3170000002d35RAAQ') || prematches.get('Email Domain').contains('a3170000002d35SAAQ'))      return 'a3070000000TW6uAAG'; //Patch Large ENT 2 Melbourne-Named Account
    if(prematches.get('Company Name').contains('a3170000002l1KzAAI') || prematches.get('Email Domain').contains('a3170000002l1L4AAI'))      return 'a3070000000TjkLAAS'; //Patch Catch All ENT ANZ Named Accounts
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