/*
 * This class is generated dynamically from Patch Rules.
 */
global class PatchRuleEngine5 extends  PatchRuleEngineBase implements IPatchRuleEngine
{
  private Id matchGroup1(PatchDataModel.MatchTarget t)
  {
    if(opIn(t.country, new Set<String> { 'my', 'mys', 'malaysia' }) && opEqual(t.custom1, 'Enterprise'))      return 'a3070000000ElQfAAK'; //Patch All APAC - MALAYSIA - ENT
    if(opIn(t.country, new Set<String> { 'sg', 'sgp', 'singapore' }) && opEqual(t.custom1, 'Enterprise'))      return 'a3070000000ElQaAAK'; //Patch GB ASEAN - SINGAPORE.
    if(opEqual(t.custom1, 'Enterprise') && opIn(t.country, new Set<String> { 'thailand', 'th' }))      return 'a3070000000ElQVAA0'; //Patch All APAC - THAILAND - ENT
    if(prematches.get('Company Name').contains('a310g000003uK77AAE') || prematches.get('Email Domain').contains('a310g000003uK7CAAU'))      return 'a300g0000019yA7AAI'; //Patch VAR - Fishtech
    if(opIn(t.state, new Set<String> { 'vt', 'vermont' }) && opIn(t.custom1, new Set<String> { 'smb', 'soho' }) && opIn(t.country, new Set<String> { 'us', 'usa', 'u.s.', 'u.s.a', 'united states', 'united states of america' }))      return 'a30700000010pwnAAA'; //Patch GB US New England/Canada - Vermont
    return 'a3070000000TSgfAAG'; //Patch ROW
    return null;
  }
  //returns the matched patch
  global PatchDataModel.PatchInfo match(PatchDataModel.MatchTarget t)
  {
    Id result = null;
    prematches = prematchList(t);
    result = matchGroup1(t);
    if(result != null) return processResult(result);
    return null;
  }
}