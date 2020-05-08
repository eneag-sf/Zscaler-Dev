public without sharing class CreateCaseController {

    @AuraEnabled(cacheable=true)
    public static User fetchPreferredFields(){
        User ur = [select id, AccountId, Account.Name, ContactId, phone, TimeZoneSidKey from User where id =: UserInfo.getUserId() limit 1];
        return ur;
    }
    @AuraEnabled
    public static String saveCaseRecord(Case objCase, List<String> contDocIds){
        objCase.Status = 'New';
        insert objCase;
        updateContentDocLinks(contDocIds, objCase.Id);
        return objCase.Id;
    }
    public static void updateContentDocLinks(List<String> contDocIds, string recordId){

        if(contDocIds!=null && !contDocIds.isEmpty()){
            List<ContentDocumentLink> contentDocLinks = new List<ContentDocumentLink>();
            for(Id cdId: contDocIds){
                ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId=cdId);
                cdl.LinkedEntityId = recordId;
                cdl.ShareType = 'V';
                cdl.Visibility = 'AllUsers';
                contentDocLinks.add(cdl);
            }
            system.debug(contentDocLinks);
            //delete [Select Id from ContentDocumentLink where ContentDocumentId in :contDocIds];
            insert contentDocLinks;
        }        
    }
    @AuraEnabled
    public static void saveFile(Id idParent, String strFileName, String base64Data) {
        // // Decoding base64Data
        // base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        // System.debug('idParent:-'+idParent);
        // // inserting file

        // Attachment attachment = new Attachment();
        // attachment.Name = strFileName;
        // attachment.Body = EncodingUtil.base64Decode(base64Data);
        // attachment.ParentId = id.valueof(idParent);
        // insert attachment;
        // System.debug('attachment:-'+attachment);
        // return attachment;

        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.ContentDocumentId = null;
        cv.VersionData = EncodingUtil.base64Decode(base64Data);
        cv.Title = strFileName;
        cv.PathOnClient = strFileName;
        
        insert cv;
        
        //***This DEBUG statement must return an Id for the rest of the code to work***
        List<ContentVersion> cdlst = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id];

        ContentDocumentLink cdl = new ContentDocumentLink();
        if(cdlst != null && !cdlst.isEmpty()){
            cdl.ContentDocumentId = cdlst[0].ContentDocumentId;
            cdl.LinkedEntityId = id.valueof(idParent);
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
        }

        
    }

    @AuraEnabled(cacheable=true)
    public static String getPortalContent(String type){
        List<Portal_Content__c> plst = new List<Portal_Content__c>();
        String content = '';
        if(type == 'partners'){
            plst = [select Id, Content__c from Portal_Content__c where Portal_type__c = 'Partner'];
        }else{
            plst = [select Id, Content__c from Portal_Content__c where Portal_type__c = 'Customer'];
        }
        if(!plst.isEmpty()){
            content = plst[0].Content__c;
        }
        return content;
    }
        
}