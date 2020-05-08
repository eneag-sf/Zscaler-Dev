public without sharing class CaseAttachmentController {
    
    @AuraEnabled(cacheable=true)
    public static list<AttachmentWrapper> fetchCaseFiles(String strObjectName) {
        Set<Id> setcontentIds = new Set<Id>();
        List<AttachmentWrapper> wrplst = new List<AttachmentWrapper>();
        if(String.isNotBlank(strObjectName)) {
            for(ContentDocumentLink cdl: [SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, IsDeleted, ShareType,ContentDocument.Title, ContentDocument.createdDate, ContentDocument.FileType FROM ContentDocumentLink WHERE (LinkedEntityId = :strObjectName and Visibility = 'AllUsers')]){
                if(setcontentIds.add(cdl.Id)){
                    wrplst.add(new AttachmentWrapper(cdl.ContentDocument.Title, cdl.Id, '/sfc/servlet.shepherd/document/download/'+cdl.ContentDocumentId));
                }
            }
            for(ContentDocumentLink cdl: [SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, IsDeleted, ShareType,ContentDocument.Title, ContentDocument.createdDate, ContentDocument.FileType FROM ContentDocumentLink WHERE (LinkedEntityId in (Select Id from EmailMessage where ParentId = :strObjectName))]){
                if(setcontentIds.add(cdl.Id)){
                    wrplst.add(new AttachmentWrapper(cdl.ContentDocument.Title, cdl.Id, '/sfc/servlet.shepherd/document/download/'+cdl.ContentDocumentId));
                }
            }
        }
        return wrplst;
    }
    public class AttachmentWrapper{
        @AuraEnabled
        public String filename;
        @AuraEnabled
        public String fileId;
        @AuraEnabled
        public String urltodownload;
        public AttachmentWrapper(String fname, string fid, string dlink){
            filename = fname;
            fileId = fid;
            urltodownload = dlink;
        }
    }
}