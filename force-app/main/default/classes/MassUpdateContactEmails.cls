global class MassUpdateContactEmails implements Database.Batchable<sObject>
{ 
 global final String query;
 global final String SPECIAL_CHAR_PATTERN = '[^\\w\\*]';
global Database.QueryLocator start(Database.BatchableContext BC)
 {
 return Database.getQueryLocator('SELECT Id, Email FROM Contact WHERE Email != NULL AND FirstName != NULL');
 }
global void execute(Database.BatchableContext BC, List<SObject> scope)
 {
 List <Contact> lstContacts = new list<Contact>();
String orgAbbreviation = '.' + UserInfo.getUserName().substringAfterLast('.');
for(Sobject s : scope)
 {
 Contact a = (Contact) s;
 if(a.Email != NULL && !checkSpecialCharacter(a.Email)){
 if(a.Email.countMatches(orgAbbreviation) == 2){
 a.Email = a.Email.replace(orgAbbreviation + orgAbbreviation, orgAbbreviation);
 }else if(a.Email.countMatches(orgAbbreviation) == 3){ 
 a.Email = a.Email.replace(orgAbbreviation + orgAbbreviation + orgAbbreviation, orgAbbreviation);
 }else if(a.Email.countMatches(orgAbbreviation) == 4){
 a.Email = a.Email.replace(orgAbbreviation + orgAbbreviation + orgAbbreviation + orgAbbreviation, orgAbbreviation);
 }else if(a.Email.countMatches(orgAbbreviation) == 0){
 a.Email = a.Email + orgAbbreviation;
 }
 lstContacts.add(a); 
 }
 }
 Update lstContacts;
 }
global Boolean checkSpecialCharacter(String email){
 Boolean isSpecial = false;
 Pattern p = Pattern.compile(SPECIAL_CHAR_PATTERN);
 Matcher pm = p.matcher(email);
 while (pm.find()) {
 if(pm.group(0) != '.' && pm.group(0)!= '@'){
 isSpecial = true; 
 }
 }
return isSpecial;
 }
global void finish(Database.BatchableContext BC)
 {
 Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
 mail.setToAddresses(new String[] {UserInfo.getUserEmail()});
 mail.setSenderDisplayName('Salesforce Sandbox Activity');
 mail.setSubject('Contact Masking Activity Completed on ' + Date.today().month() + ' ' + Date.today().year()+' for '+UserInfo.getUserName().substringAfterLast('.')+' sandbox');
 mail.setBccSender(false);
 mail.setUseSignature(false);
 mail.setPlainTextBody('Contact Masking Activity Completed on ' + Date.today().month() + ' ' + Date.today().year()+' for '+UserInfo.getUserName().substringAfterLast('.')+' sandbox');
 }
}