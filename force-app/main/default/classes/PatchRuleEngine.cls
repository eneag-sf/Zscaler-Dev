/*
 * This class is generated dynamically from Patch Rules.
 */
global class PatchRuleEngine extends  PatchRuleEngineBase implements IPatchRuleEngine
{
  private Id matchGroup1(PatchDataModel.MatchTarget t)
  {
  system.debug('inside PatchRuleEngine  '+t);
    if(prematches.get('Custom4').contains('a310g00000Du2ZnAAJ') || prematches.get('Custom6').contains('a310g00000CmpicAAB'))      overlayingPatchIds.add('a300g0000022xMnAAI');
    if(prematches.get('Custom4').contains('a310g00000Du2ZoAAJ') || prematches.get('Custom6').contains('a310g00000CmpkQAAR'))      overlayingPatchIds.add('a300g0000022xMoAAI');
    if(prematches.get('Custom4').contains('a310g00000Du2ZpAAJ') || prematches.get('Custom6').contains('a310g00000CmpjIAAR'))      overlayingPatchIds.add('a300g0000022xMpAAI');
    if(prematches.get('Custom4').contains('a310g00000Du2ZqAAJ') || prematches.get('Custom6').contains('a310g00000CmpkVAAR'))      overlayingPatchIds.add('a300g0000022xMqAAI');
    if(prematches.get('Custom4').contains('a310g00000Du2ZrAAJ') || prematches.get('Custom6').contains('a310g00000CmpjJAAR'))      overlayingPatchIds.add('a300g0000022xMrAAI');
    if(prematches.get('Custom4').contains('a310g00000Du2ZsAAJ') || prematches.get('Custom6').contains('a310g00000CmpjKAAR'))      overlayingPatchIds.add('a300g0000022xMsAAI');
    if(prematches.get('Custom4').contains('a310g00000Du2ZtAAJ') || prematches.get('Custom6').contains('a310g00000CmpjLAAR'))      overlayingPatchIds.add('a300g0000022xMtAAI');
    if(prematches.get('Custom4').contains('a310g00000Du2ZuAAJ') || prematches.get('Custom6').contains('a310g00000CmpjMAAR'))      overlayingPatchIds.add('a300g0000022xMuAAI');
    if(prematches.get('Custom4').contains('a310g00000Du2ZxAAJ') || prematches.get('Custom6').contains('a310g00000CmpjPAAR'))      overlayingPatchIds.add('a300g0000022xMxAAI');
    if(prematches.get('Custom4').contains('a310g00000Du2ZyAAJ') || prematches.get('Custom6').contains('a310g00000CmpjQAAR'))      overlayingPatchIds.add('a300g0000022xMyAAI');
    if(prematches.get('Custom4').contains('a310g00000Du2ZzAAJ') || prematches.get('Custom6').contains('a310g00000CmpjRAAR'))      overlayingPatchIds.add('a300g0000022xMzAAI');
    if(prematches.get('Custom4').contains('a310g00000Du2a0AAB') || prematches.get('Custom6').contains('a310g00000CmpjSAAR'))      overlayingPatchIds.add('a300g0000022xN0AAI');
    if(prematches.get('Custom4').contains('a310g00000Du2a1AAB') || prematches.get('Custom6').contains('a310g00000CmpjhAAB'))      overlayingPatchIds.add('a300g0000022xN1AAI');
    if(prematches.get('Custom4').contains('a310g00000Du2a2AAB') || prematches.get('Custom6').contains('a310g00000CmpjiAAB'))      overlayingPatchIds.add('a300g0000022xN2AAI');
    if(prematches.get('Custom4').contains('a310g00000Du2a3AAB') || prematches.get('Custom6').contains('a310g00000CmpjTAAR'))      overlayingPatchIds.add('a300g0000022xN3AAI');
    if(prematches.get('Custom4').contains('a310g00000Du2a4AAB') || prematches.get('Custom6').contains('a310g00000CmpjUAAR'))      overlayingPatchIds.add('a300g0000022xN4AAI');
    if(prematches.get('Custom4').contains('a310g00000Du2a5AAB') || prematches.get('Custom6').contains('a310g00000CmpjVAAR'))      overlayingPatchIds.add('a300g0000022xN5AAI');
    if(prematches.get('Custom4').contains('a310g00000Du2a6AAB') || prematches.get('Custom6').contains('a310g00000CmpjWAAR'))      overlayingPatchIds.add('a300g0000022xN6AAI');
    if(prematches.get('Custom4').contains('a310g00000Du2a7AAB') || prematches.get('Custom6').contains('a310g00000CmpjXAAR'))      overlayingPatchIds.add('a300g0000022xN7AAI');
    if(prematches.get('Custom4').contains('a310g00000Du2a8AAB') || prematches.get('Custom6').contains('a310g00000CmpjYAAR'))      overlayingPatchIds.add('a300g0000022xN8AAI');
    if(prematches.get('Custom4').contains('a310g00000Du2a9AAB') || prematches.get('Custom6').contains('a310g00000CmpjZAAR'))      overlayingPatchIds.add('a300g0000022xN9AAI');
    if(opContain(t.custom5, 'Ishwinder Cheema'))      overlayingPatchIds.add('a300g00000237t7AAA');
    if(prematches.get('Custom4').contains('a310g00000Du2aAAAR') || prematches.get('Custom6').contains('a310g00000CmpjaAAB'))      overlayingPatchIds.add('a300g0000022xNAAAY');
    if(prematches.get('Custom4').contains('a310g00000Du2aBAAR') || prematches.get('Custom6').contains('a310g00000CmpjbAAB'))      overlayingPatchIds.add('a300g0000022xNBAAY');
    if(prematches.get('Custom4').contains('a310g00000Du2aCAAR') || prematches.get('Custom6').contains('a310g00000CmpjcAAB'))      overlayingPatchIds.add('a300g0000022xNCAAY');
    if(prematches.get('Custom4').contains('a310g00000Du2aDAAR') || prematches.get('Custom6').contains('a310g00000CmpjdAAB'))      overlayingPatchIds.add('a300g0000022xNDAAY');
    if(prematches.get('Custom4').contains('a310g00000Du2aEAAR') || prematches.get('Custom6').contains('a310g00000CmpjeAAB'))      overlayingPatchIds.add('a300g0000022xNEAAY');
    if(opContain(t.custom5, 'Jimmy Chen'))      overlayingPatchIds.add('a300g00000237t8AAA');
    if(prematches.get('Custom4').contains('a310g00000Du2aFAAR') || prematches.get('Custom6').contains('a310g00000CmpjfAAB'))      overlayingPatchIds.add('a300g0000022xNFAAY');
    if(prematches.get('Custom4').contains('a310g00000Du2aGAAR') || prematches.get('Custom6').contains('a310g00000CmpjgAAB'))      overlayingPatchIds.add('a300g0000022xNGAAY');
    if(prematches.get('Custom4').contains('a310g00000Du2aHAAR') || prematches.get('Custom6').contains('a310g00000CmpjjAAB'))      overlayingPatchIds.add('a300g0000022xNHAAY');
    if(prematches.get('Custom4').contains('a310g00000Du2aIAAR') || prematches.get('Custom6').contains('a310g00000CmpjkAAB'))      overlayingPatchIds.add('a300g0000022xNIAAY');
    if(opContain(t.custom5, 'Justin O\'Brien'))      overlayingPatchIds.add('a300g00000237t9AAA');
    if(prematches.get('Custom4').contains('a310g00000Du2aJAAR') || prematches.get('Custom6').contains('a310g00000CmpjlAAB'))      overlayingPatchIds.add('a300g0000022xNJAAY');
    if(prematches.get('Custom4').contains('a310g00000Du2aKAAR') || prematches.get('Custom6').contains('a310g00000CmpjmAAB'))      overlayingPatchIds.add('a300g0000022xNKAAY');
    return null;
  }
  private Id matchGroup2(PatchDataModel.MatchTarget t)
  {
    if(prematches.get('Custom4').contains('a310g00000Du2aLAAR') || prematches.get('Custom6').contains('a310g00000CmpjnAAB'))      overlayingPatchIds.add('a300g0000022xNLAAY');
    if(prematches.get('Custom4').contains('a310g00000Du2aMAAR') || prematches.get('Custom6').contains('a310g00000CmpjoAAB'))      overlayingPatchIds.add('a300g0000022xNMAAY');
    if(prematches.get('Custom4').contains('a310g00000Du2aOAAR') || prematches.get('Custom6').contains('a310g00000CmpjpAAB'))      overlayingPatchIds.add('a300g0000022xNOAAY');
    if(opContain(t.custom5, 'Matt Atkinson'))      overlayingPatchIds.add('a300g00000237tAAAQ');
    if(prematches.get('Custom4').contains('a310g00000Du2aPAAR') || prematches.get('Custom6').contains('a310g00000CmpjqAAB'))      overlayingPatchIds.add('a300g0000022xNPAAY');
    if(prematches.get('Custom4').contains('a310g00000Du2aQAAR') || prematches.get('Custom6').contains('a310g00000CmpjrAAB'))      overlayingPatchIds.add('a300g0000022xNQAAY');
    if(prematches.get('Custom4').contains('a310g00000Du2aRAAR') || prematches.get('Custom6').contains('a310g00000CmpjsAAB'))      overlayingPatchIds.add('a300g0000022xNRAAY');
    if(prematches.get('Custom4').contains('a310g00000Du2aSAAR') || prematches.get('Custom6').contains('a310g00000CmpjtAAB'))      overlayingPatchIds.add('a300g0000022xNSAAY');
    if(prematches.get('Custom4').contains('a310g00000Du2aTAAR') || prematches.get('Custom6').contains('a310g00000CmpjuAAB'))      overlayingPatchIds.add('a300g0000022xNTAAY');
    if(prematches.get('Custom4').contains('a310g00000Du2aUAAR') || prematches.get('Custom6').contains('a310g00000CmpjvAAB'))      overlayingPatchIds.add('a300g0000022xNUAAY');
    if(prematches.get('Custom4').contains('a310g00000Du2aVAAR') || prematches.get('Custom6').contains('a310g00000CmpjwAAB'))      overlayingPatchIds.add('a300g0000022xNVAAY');
    if(prematches.get('Custom4').contains('a310g00000Du2aWAAR') || prematches.get('Custom6').contains('a310g00000CmpjxAAB'))      overlayingPatchIds.add('a300g0000022xNWAAY');
    if(opContain(t.custom5, 'Pieter Van Roosbroek'))      overlayingPatchIds.add('a300g00000237tBAAQ');
    if(opContain(t.custom5, 'Piotr Gruszczynski'))      overlayingPatchIds.add('a300g00000237tCAAQ');
    if(prematches.get('Custom4').contains('a310g00000Du2aXAAR') || prematches.get('Custom6').contains('a310g00000CmpjyAAB'))      overlayingPatchIds.add('a300g0000022xNXAAY');
    if(prematches.get('Custom4').contains('a310g00000Du2aYAAR') || prematches.get('Custom6').contains('a310g00000CmpkEAAR'))      overlayingPatchIds.add('a300g0000022xNYAAY');
    if(prematches.get('Custom4').contains('a310g00000Du2aZAAR') || prematches.get('Custom6').contains('a310g00000CmpjzAAB'))      overlayingPatchIds.add('a300g0000022xNZAAY');
    if(prematches.get('Custom4').contains('a310g00000Du2aaAAB') || prematches.get('Custom6').contains('a310g00000Cmpk0AAB'))      overlayingPatchIds.add('a300g0000022xNaAAI');
    if(prematches.get('Custom4').contains('a310g00000Du2acAAB') || prematches.get('Custom6').contains('a310g00000Cmpk2AAB'))      overlayingPatchIds.add('a300g0000022xNcAAI');
    if(prematches.get('Custom4').contains('a310g00000Du2adAAB') || prematches.get('Custom6').contains('a310g00000Cmpk3AAB'))      overlayingPatchIds.add('a300g0000022xNdAAI');
    if(prematches.get('Custom4').contains('a310g00000Du2aeAAB') || prematches.get('Custom6').contains('a310g00000Cmpk4AAB'))      overlayingPatchIds.add('a300g0000022xNeAAI');
    if(prematches.get('Custom4').contains('a310g00000JGuKRAA1') || prematches.get('Custom6').contains('a310g00000JGuKWAA1'))      overlayingPatchIds.add('a300g000002RZbZAAW');
    if(opContain(t.custom5, 'Sahil Singla'))      overlayingPatchIds.add('a300g0000022xNfAAI');
    if(prematches.get('Custom4').contains('a310g00000Du2agAAB') || prematches.get('Custom6').contains('a310g00000Cmpk6AAB'))      overlayingPatchIds.add('a300g0000022xNgAAI');
    if(prematches.get('Custom4').contains('a310g00000Du2ahAAB') || prematches.get('Custom6').contains('a310g00000Cmpk7AAB'))      overlayingPatchIds.add('a300g0000022xNhAAI');
    if(prematches.get('Custom4').contains('a310g00000Du2ajAAB') || prematches.get('Custom6').contains('a310g00000Cmpk9AAB'))      overlayingPatchIds.add('a300g0000022xNjAAI');
    if(opContain(t.custom5, 'Scott Wood'))      overlayingPatchIds.add('a300g00000237tDAAQ');
    if(prematches.get('Custom4').contains('a310g00000Du2akAAB') || prematches.get('Custom6').contains('a310g00000CmpkAAAR'))      overlayingPatchIds.add('a300g0000022xNkAAI');
    if(prematches.get('Custom4').contains('a310g00000Du2alAAB') || prematches.get('Custom6').contains('a310g00000CmpkBAAR'))      overlayingPatchIds.add('a300g0000022xNlAAI');
    if(prematches.get('Custom4').contains('a310g00000Du2amAAB') || prematches.get('Custom6').contains('a310g00000CmpkCAAR'))      overlayingPatchIds.add('a300g0000022xNmAAI');
    if(prematches.get('Custom4').contains('a310g00000Du2anAAB') || prematches.get('Custom6').contains('a310g00000CmpkDAAR'))      overlayingPatchIds.add('a300g0000022xNnAAI');
    if(prematches.get('Custom4').contains('a310g00000Du2aoAAB') || prematches.get('Custom6').contains('a310g00000CmpkFAAR'))      overlayingPatchIds.add('a300g0000022xNoAAI');
    if(prematches.get('Custom4').contains('a310g00000Du2apAAB') || prematches.get('Custom6').contains('a310g00000CmpkGAAR'))      overlayingPatchIds.add('a300g0000022xNpAAI');
    if(prematches.get('Custom4').contains('a310g00000Du2aqAAB') || prematches.get('Custom6').contains('a310g00000CmpkHAAR'))      overlayingPatchIds.add('a300g0000022xNqAAI');
    if(opContain(t.custom5, 'Tim Banks'))      overlayingPatchIds.add('a300g00000237tEAAQ');
    return null;
  }
  private Id matchGroup3(PatchDataModel.MatchTarget t)
  {
    if(opContain(t.custom5, 'Torrek Phillips'))      overlayingPatchIds.add('a300g00000237tFAAQ');
    if(prematches.get('Custom4').contains('a310g00000Du2arAAB') || prematches.get('Custom6').contains('a310g00000CmpkIAAR'))      overlayingPatchIds.add('a300g0000022xNrAAI');
    if(opContain(t.custom5, 'Varun Vasisth'))      overlayingPatchIds.add('a300g00000237tGAAQ');
    if(prematches.get('Custom4').contains('a310g00000Du2asAAB') || prematches.get('Custom6').contains('a310g00000CmpkJAAR'))      overlayingPatchIds.add('a300g0000022xNsAAI');
    if(prematches.get('Custom4').contains('a310g00000Du2atAAB') || prematches.get('Custom6').contains('a310g00000CmpkKAAR'))      overlayingPatchIds.add('a300g0000022xNtAAI');
    if(opContain(t.custom5, 'Djalil Lounis'))      overlayingPatchIds.add('a300g00000237tHAAQ');
    if(opContain(t.custom5, 'Abhishek Sharma'))      overlayingPatchIds.add('a300g00000237tIAAQ');
    if(opContain(t.custom5, 'Adam Rokosz'))      overlayingPatchIds.add('a300g00000237tJAAQ');
    if(opContain(t.custom5, 'Aditya Shekhar'))      overlayingPatchIds.add('a300g00000237tKAAQ');
    if(opContain(t.custom5, 'Akash Rana'))      overlayingPatchIds.add('a300g00000237tLAAQ');
    if(opContain(t.custom5, 'Aman Mukhija'))      overlayingPatchIds.add('a300g00000237tNAAQ');
    if(opContain(t.custom5, 'Ananta Thakur'))      overlayingPatchIds.add('a300g0000022xO4AAI');
    if(opContain(t.custom5, 'Anchal Taksh Sood'))      overlayingPatchIds.add('a300g00000237tPAAQ');
    if(opContain(t.custom5, 'Andy Asamoah'))      overlayingPatchIds.add('a300g00000237tQAAQ');
    if(opContain(t.custom5, 'Anubhav Gupta'))      overlayingPatchIds.add('a300g00000237tRAAQ');
    if(opContain(t.custom5, 'Ayoub Choudhury'))      overlayingPatchIds.add('a300g00000237tSAAQ');
    if(opContain(t.custom5, 'Berj Soghmonian'))      overlayingPatchIds.add('a300g00000237tTAAQ');
    if(opContain(t.custom5, 'Bogumil Griner'))      overlayingPatchIds.add('a300g00000237tUAAQ');
    if(opContain(t.custom5, 'Carlos Barrantes'))      overlayingPatchIds.add('a300g00000237tVAAQ');
    if(opContain(t.custom5, 'Carlos Davila'))      overlayingPatchIds.add('a300g00000237tWAAQ');
    if(opContain(t.custom5, 'Carlos Romero'))      overlayingPatchIds.add('a300g00000237tXAAQ');
    if(opContain(t.custom5, 'Chad Cummins'))      overlayingPatchIds.add('a300g00000237tYAAQ');
    if(opContain(t.custom5, 'Chris Liu'))      overlayingPatchIds.add('a300g00000237tZAAQ');
    if(opContain(t.custom5, 'Cliff Yaun'))      overlayingPatchIds.add('a300g00000237taAAA');
    if(opContain(t.custom5, 'Danny Ward'))      overlayingPatchIds.add('a300g00000237tbAAA');
    if(opContain(t.custom5, 'David Noriega'))      overlayingPatchIds.add('a300g00000237tcAAA');
    if(opContain(t.custom5, 'Davis Altamirano'))      overlayingPatchIds.add('a300g00000237tdAAA');
    if(opContain(t.custom5, 'Dawid Stepien'))      overlayingPatchIds.add('a300g00000237teAAA');
    if(opContain(t.custom5, 'Dylan Merida'))      overlayingPatchIds.add('a300g00000237tfAAA');
    if(opContain(t.custom5, 'Esteban Araya'))      overlayingPatchIds.add('a300g00000237tgAAA');
    if(opContain(t.custom5, 'Fiorella Ivaldi'))      overlayingPatchIds.add('a300g00000237thAAA');
    if(opContain(t.custom5, 'Freddy Rodriguez'))      overlayingPatchIds.add('a300g0000022xO9AAI');
    if(opContain(t.custom5, 'Gaurav Mahajan'))      overlayingPatchIds.add('a300g00000237tiAAA');
    if(opContain(t.custom5, 'Giriraj Jayaraman'))      overlayingPatchIds.add('a300g00000237tjAAA');
    if(opContain(t.custom5, 'Gurjeet'))      overlayingPatchIds.add('a300g00000237tkAAA');
    return null;
  }
  private Id matchGroup4(PatchDataModel.MatchTarget t)
  {
    if(opContain(t.custom5, 'Gurpreet Singh (TAM)'))      overlayingPatchIds.add('a300g00000237tlAAA');
    if(opContain(t.custom5, 'Hamza Farhan'))      overlayingPatchIds.add('a300g00000237tmAAA');
    if(opContain(t.custom5, 'Hemanth Varanasi'))      overlayingPatchIds.add('a300g00000237tnAAA');
    if(opContain(t.custom5, 'Hubert Laguna'))      overlayingPatchIds.add('a300g00000237toAAA');
    if(opContain(t.custom5, 'Humara Naseer'))      overlayingPatchIds.add('a300g00000237tpAAA');
    if(opContain(t.custom5, 'Jamil Alomari'))      overlayingPatchIds.add('a300g00000237tqAAA');
    if(opContain(t.custom5, 'Jatin Sood'))      overlayingPatchIds.add('a300g00000237trAAA');
    if(opContain(t.custom5, 'John Wu'))      overlayingPatchIds.add('a300g00000237ttAAA');
    if(opContain(t.custom5, 'Jose Mendez'))      overlayingPatchIds.add('a300g00000237tuAAA');
    if(opContain(t.custom5, 'Joseph Stubberfield'))      overlayingPatchIds.add('a300g00000237tvAAA');
    if(opContain(t.custom5, 'Juan Robles'))      overlayingPatchIds.add('a300g00000237twAAA');
    if(opContain(t.custom5, 'Julio Artavia'))      overlayingPatchIds.add('a300g00000237txAAA');
    if(opContain(t.custom5, 'Konrad Aniskiewicz'))      overlayingPatchIds.add('a300g00000237tyAAA');
    if(opContain(t.custom5, 'Krishna Ghige'))      overlayingPatchIds.add('a300g00000237tzAAA');
    if(opContain(t.custom5, 'Lamia Elomary'))      overlayingPatchIds.add('a300g00000237u0AAA');
    if(opContain(t.custom5, 'Lukasz Teodorowski'))      overlayingPatchIds.add('a300g00000237u1AAA');
    if(opContain(t.custom5, 'Mandeep Singh'))      overlayingPatchIds.add('a300g00000237u2AAA');
    if(opContain(t.custom5, 'Manuel Arguello'))      overlayingPatchIds.add('a300g00000237u3AAA');
    if(opContain(t.custom5, 'Mario Herrera'))      overlayingPatchIds.add('a300g00000237u4AAA');
    if(opContain(t.custom5, 'Mario Zamora'))      overlayingPatchIds.add('a300g00000237u5AAA');
    if(opContain(t.custom5, 'Maroun Rouhana Moussa'))      overlayingPatchIds.add('a300g00000237u6AAA');
    if(opContain(t.custom5, 'Mateusz Szypczynski'))      overlayingPatchIds.add('a300g00000237u7AAA');
    if(opContain(t.custom5, 'Mauricio Quesada'))      overlayingPatchIds.add('a300g00000237u8AAA');
    if(opContain(t.custom5, 'Mayur Tyagi'))      overlayingPatchIds.add('a300g00000237u9AAA');
    if(opContain(t.custom5, 'Michael Cosyn'))      overlayingPatchIds.add('a300g00000237uAAAQ');
    if(opContain(t.custom5, 'Michael Pike'))      overlayingPatchIds.add('a300g00000237uCAAQ');
    if(opContain(t.custom5, 'Michiel Corbiere'))      overlayingPatchIds.add('a300g00000237uDAAQ');
    if(opContain(t.custom5, 'Mouad Zahrane'))      overlayingPatchIds.add('a300g00000237uGAAQ');
    if(opContain(t.custom5, 'Muneeb Mir'))      overlayingPatchIds.add('a300g00000237uHAAQ');
    if(opContain(t.custom5, 'Nathan Di Bitetto'))      overlayingPatchIds.add('a300g00000237uIAAQ');
    if(opContain(t.custom5, 'Nupur Sharma'))      overlayingPatchIds.add('a300g00000237uJAAQ');
    if(opContain(t.custom5, 'Omar Nasr'))      overlayingPatchIds.add('a300g00000237uKAAQ');
    if(opContain(t.custom5, 'Philip De Vos'))      overlayingPatchIds.add('a300g00000237uLAAQ');
    if(opContain(t.custom5, 'Pranav Kumar'))      overlayingPatchIds.add('a300g00000237uMAAQ');
    if(opContain(t.custom5, 'Prince Dubey'))      overlayingPatchIds.add('a300g00000237uNAAQ');
    return null;
  }
  private Id matchGroup5(PatchDataModel.MatchTarget t)
  {
    if(opContain(t.custom5, 'Raja Kotty P'))      overlayingPatchIds.add('a300g00000237uQAAQ');
    if(opContain(t.custom5, 'Randy Hernandez'))      overlayingPatchIds.add('a300g00000237uSAAQ');
    if(opContain(t.custom5, 'Ravneet Singh'))      overlayingPatchIds.add('a300g00000237uTAAQ');
    if(opContain(t.custom5, 'Reeti Verma'))      overlayingPatchIds.add('a300g00000237uUAAQ');
    if(opContain(t.custom5, 'Richard Hodgson'))      overlayingPatchIds.add('a300g00000237uVAAQ');
    if(opContain(t.custom5, 'Rodrigo Lobo'))      overlayingPatchIds.add('a300g00000237uWAAQ');
    if(opContain(t.custom5, 'Roman Shymansky'))      overlayingPatchIds.add('a300g00000237uXAAQ');
    if(opContain(t.custom5, 'Amit Rawat'))      overlayingPatchIds.add('a300g000002RZTWAA4');
    if(opContain(t.custom5, 'Roman Walat'))      overlayingPatchIds.add('a300g00000237uYAAQ');
    if(opContain(t.custom5, 'Rudi Kessler'))      overlayingPatchIds.add('a300g00000237uZAAQ');
    if(opContain(t.custom5, 'Ryan Bos'))      overlayingPatchIds.add('a300g00000237uaAAA');
    if(opContain(t.custom5, 'Ryan Galloway'))      overlayingPatchIds.add('a300g00000237ubAAA');
    if(opContain(t.custom5, 'Sameer Thadani'))      overlayingPatchIds.add('a300g00000237ucAAA');
    if(opContain(t.custom5, 'Saurabh Khantwal'))      overlayingPatchIds.add('a300g00000237udAAA');
    if(opContain(t.custom5, 'Sergio Bonilla'))      overlayingPatchIds.add('a300g00000237ueAAA');
    if(opContain(t.custom5, 'Sheril Nagoor'))      overlayingPatchIds.add('a300g00000237ufAAA');
    if(opContain(t.custom5, 'Shivani Khurana'))      overlayingPatchIds.add('a300g00000237ugAAA');
    if(opContain(t.custom5, 'SK Queh') || opContain(t.custom5, 'Soon Keong Queh'))      overlayingPatchIds.add('a300g00000237uhAAA');
    if(opContain(t.custom5, 'Sumit Bawa'))      overlayingPatchIds.add('a300g00000237uiAAA');
    if(opContain(t.custom5, 'Tiago Pisco'))      overlayingPatchIds.add('a300g00000237ujAAA');
    if(opContain(t.custom5, 'Tulika Chakraborty'))      overlayingPatchIds.add('a300g00000237ukAAA');
    if(opContain(t.custom5, 'Tyson Gwinn'))      overlayingPatchIds.add('a300g00000237ulAAA');
    if(opContain(t.custom5, 'Yaash Zargar'))      overlayingPatchIds.add('a300g00000237umAAA');
    if(opContain(t.custom5, 'Yanick Martin'))      overlayingPatchIds.add('a300g00000237unAAA');
    if(opContain(t.custom5, 'Yasir Shah'))      overlayingPatchIds.add('a300g00000237uoAAA');
    if(prematches.get('Custom4').contains('a310g00000CkxGPAAZ') || prematches.get('Custom6').contains('a310g00000CmpjBAAR'))      overlayingPatchIds.add('a300g000002AhYhAAK');
    if(opContain(t.custom5, 'Sebastian LopezCastro'))      overlayingPatchIds.add('a300g000002BQ3CAAW');
    if(opContain(t.custom5, 'Nelson Camacho'))      overlayingPatchIds.add('a300g000002BbAqAAK');
    if(prematches.get('Custom4').contains('a310g00000ClDbkAAF') || prematches.get('Custom6').contains('a310g00000CmpjHAAR'))      overlayingPatchIds.add('a300g000002BbC4AAK');
    if(prematches.get('Custom4').contains('a310g00000ClPpeAAF') || prematches.get('Custom6').contains('a310g00000CmpjGAAR'))      overlayingPatchIds.add('a300g000002CJk2AAG');
    if(prematches.get('Custom4').contains('a310g00000ClPqDAAV') || prematches.get('Custom6').contains('a310g00000CmpjDAAR'))      overlayingPatchIds.add('a300g000002CJk7AAG');
    if(prematches.get('Custom4').contains('a310g00000ClPr1AAF') || prematches.get('Custom6').contains('a310g00000CmpjEAAR'))      overlayingPatchIds.add('a300g000002CJkCAAW');
    if(prematches.get('Custom4').contains('a310g00000ClPrGAAV') || prematches.get('Custom6').contains('a310g00000CmpjFAAR'))      overlayingPatchIds.add('a300g000002CJkHAAW');
    if(prematches.get('Custom4').contains('a310g00000ClZrpAAF') || prematches.get('Custom6').contains('a310g00000CmpihAAB'))      overlayingPatchIds.add('a300g000002CUv5AAG');
    if(prematches.get('Custom4').contains('a310g00000Cm1TNAAZ') || prematches.get('Custom6').contains('a310g00000CmpjCAAR'))      overlayingPatchIds.add('a300g000002EIxTAAW');
    return null;
  }
  private Id matchGroup6(PatchDataModel.MatchTarget t)
  {
    if(opContain(t.custom5, 'Shakti Kumar'))      overlayingPatchIds.add('a300g000002ErQtAAK');
    if(opContain(t.custom5, 'Sulav Kumar'))      overlayingPatchIds.add('a300g000002FEL5AAO');
    if(opContain(t.custom5, 'Monika Sinha'))      overlayingPatchIds.add('a300g000002FyACAA0');
    if(prematches.get('Custom4').contains('a310g00000JDfJcAAL') || prematches.get('Custom6').contains('a310g00000JDfJhAAL'))      overlayingPatchIds.add('a300g000002ICGDAA4');
    if(opContain(t.custom5, 'Syed Ahmad'))      overlayingPatchIds.add('a300g000002IZkFAAW');
    if(opContain(t.custom5, 'Seb Patrick'))      overlayingPatchIds.add('a300g000002KHhMAAW');
    if(opContain(t.custom5, 'Mariusz Rozycki'))      overlayingPatchIds.add('a300g000002KHhlAAG');
    if(opContain(t.custom5, 'Malvika Kapoor'))      overlayingPatchIds.add('a300g000002MJyQAAW');
    if(opContain(t.custom5, 'Sebastian Patrick'))      overlayingPatchIds.add('a300g000002RZSZAA4');
    if(prematches.get('Custom4').contains('a310g00000JEe2SAAT') || prematches.get('Custom6').contains('a310g00000JEe2XAAT'))      overlayingPatchIds.add('a300g000002MJyaAAG');
    if(prematches.get('Custom4').contains('a310g00000JEe8zAAD') || prematches.get('Custom6').contains('a310g00000JEe9OAAT'))      overlayingPatchIds.add('a300g000002MJykAAG');
    if(opContain(t.custom5, 'Angel Delgado'))      overlayingPatchIds.add('a300g000002NKTcAAO');
    if(prematches.get('Custom4').contains('a310g00000JGkaiAAD') || prematches.get('Custom6').contains('a310g00000JGkanAAD'))      overlayingPatchIds.add('a300g000002RZUiAAO');
    if(opContain(t.custom5, 'Juan Mendez'))      overlayingPatchIds.add('a300g000002RZVpAAO');
    if(opContain(t.custom5, 'Sidharth Joshi'))      overlayingPatchIds.add('a300g000002RZVkAAO');
    if(opContain(t.custom5, 'Carlos Perez'))      overlayingPatchIds.add('a300g000002RZVuAAO');
    if(opContain(t.custom5, 'Helena Blanco Morales'))      overlayingPatchIds.add('a300g000002RZYcAAO');
    if(prematches.get('Company Name').contains('a3170000002x5DPAAY') || prematches.get('Email Domain').contains('a3170000002x5DUAAY'))      return 'a3070000000EeAWAA0'; //Patch SP - AMER Emerging
    if(prematches.get('Company Name').contains('a310g000006eOa0AAE') || prematches.get('Email Domain').contains('a310g000006eOa5AAE'))      return 'a300g000001M2GWAA0'; //Patch Bus Dev Cloud Consulting - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk25AAC') || prematches.get('Email Domain').contains('a310g000006Nk3FAAS'))      return 'a300g000001IBj8AAG'; //Patch SP - DT/T-Systems - Named Accounts
    if(prematches.get('Company Name').contains('a310g000006Nk1wAAC') || prematches.get('Email Domain').contains('a310g000006Nk36AAC'))      return 'a300g000001IBizAAG'; //Patch GSI - Accenture/Deloitte/Avanade - Named Accounts
    if(prematches.get('Company Name').contains('a310g00000Az5y2AAB') || prematches.get('Email Domain').contains('a310g00000Az5y7AAB'))      return 'a300g000001lkgGAAQ'; //Patch Bus Dev Cloud Consulting - Microsoft
    if(prematches.get('Company Name').contains('a310g000007I5fSAAS') || prematches.get('Email Domain').contains('a310g000007I5fXAAS'))      return 'a300g000001TQnxAAG'; //Patch SP - Telefonica
    if(prematches.get('Company Name').contains('a3170000002x5E8AAI') || prematches.get('Email Domain').contains('a3170000002x5E9AAI'))      return 'a3070000000EeAlAAK'; //Patch VAR - SHI
    if(prematches.get('Company Name').contains('a3170000002x5D5AAI') || prematches.get('Email Domain').contains('a3170000002x5DFAAY'))      return 'a3070000000EeARAA0'; //Patch SP - OBS
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