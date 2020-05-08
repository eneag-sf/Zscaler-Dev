public without sharing class CaseCommentController_LWC {
    @AuraEnabled
    public static void saveCaseComment(Id caseId, String comment, Boolean ispublic, List<String> contDocIds){
        String parentId = '';
        /*if(ispublic){
            /*emailmessage em = new emailmessage();
            em.HTMLBody=comment;
            em.IsExternallyVisible=true;
            em.ParentId=caseId;
            em.FromAddress=UserInfo.getUserEmail();
            insert em;
            system.debug(em);
            emailmessage em = new emailmessage(HTMLBody='<h1>kjfjdbgf</h1>',IsExternallyVisible=true, ParentId='50021000005XaafAAC',FromAddress='avaideeswaran@zscaler.com');
            insert em;
            parentId= em.Id;
        }else{*/
            FeedItem cc = new FeedItem(parentId = caseId);
            cc.Body = comment;
            cc.Visibility = 'InternalUsers';
            cc.IsRichText = false;
            insert cc;
            parentId= cc.Id;
        //}
        
        updateContentDocLinks(contDocIds, parentId, ispublic);
    }
    @AuraEnabled(cacheable=true)
    public static List<CaseCommentWrapper> getCaseComments(Id caseId, Integer lim, String sortorder, String portal){
        system.debug(caseId);
        system.debug(lim);
        List<FeedItem> cclst = new List<FeedItem>();
        List<CaseCommentWrapper> wrplst = new List<CaseCommentWrapper>();
        List<CaseCommentWrapper> finallst = new List<CaseCommentWrapper>();
        Map<Id, Id> mapCVtoFeedId = new map<Id, Id>();
        Map<Id, List<AttachmentWrapper>> mapFeedItemtoAttachment = new map<Id, List<AttachmentWrapper>>();
        List<User> usrinf = [Select Id, ContactId, Service_Level__c from USer where id=:UserInfo.getUserId()];
        if(caseId != null){
            for(FeedAttachment fa: [Select RecordId, FeedEntityId from FeedAttachment where FeedEntityId in (Select Id from feedItem where ParentId = :caseId)]){
                mapCVtoFeedId.put(fa.RecordId, fa.FeedEntityId);
            }
            for(ContentVersion cv: [Select Id, ContentDocumentId, ContentDocument.Title from ContentVersion where Id in :mapCVtoFeedId.keySet()]){
                List<AttachmentWrapper> attwrplst;
                if(mapCVtoFeedId.containsKey(cv.Id) && mapCVtoFeedId.get(cv.Id) != null && mapFeedItemtoAttachment.containsKey(mapCVtoFeedId.get(cv.Id))){
                    attwrplst = mapFeedItemtoAttachment.get(mapCVtoFeedId.get(cv.Id));
                    attwrplst.add(new AttachmentWrapper(cv.ContentDocument.Title, cv.Id, '/' + portal + '/sfc/servlet.shepherd/document/download/'+cv.ContentDocumentId));
                    mapFeedItemtoAttachment.put(mapCVtoFeedId.get(cv.Id), attwrplst);
                    
                }else if(mapCVtoFeedId.containsKey(cv.Id) && mapCVtoFeedId.get(cv.Id) != null){
                    attwrplst = new List<AttachmentWrapper>();
                    attwrplst.add(new AttachmentWrapper(cv.ContentDocument.Title, cv.Id, '/' + portal + '/sfc/servlet.shepherd/document/download/'+cv.ContentDocumentId));
                    mapFeedItemtoAttachment.put(mapCVtoFeedId.get(cv.Id), attwrplst);
                }
            }
            if(!usrinf.isEmpty() && usrinf[0].ContactId != null){
                for(CaseComment cc: [Select Id, CommentBody, ParentId, Ispublished, CreatedDate, CreatedById, CreatedBy.Name, CreatedBy.Firstname, CreatedBy.Lastname from CaseComment where ParentId = :caseId and IsPublished = true]){
                    CaseCommentWrapper ccwrp = new CaseCommentWrapper();
                    if(cc.CommentBody != null){
                        ccwrp.caseId = cc.ParentId;
                        ccwrp.commentId = cc.Id;
                        ccwrp.sortOrder = sortOrder;
                        ccwrp.comment = cc.CommentBody;
                        ccwrp.createddate = cc.CreatedDate;
                        ccwrp.creatorId = cc.CreatedById;
                        ccwrp.ispublic = '';
                        ccwrp.creatorname = (cc.CreatedBy.Firstname != null ? cc.CreatedBy.Firstname + ' ' : '')  + cc.CreatedBy.Lastname;
                        ccwrp.attachlst = new List<AttachmentWrapper>();
                        wrplst.add(ccwrp);
                    }
                }
                for(FeedItem cc: [Select Id, Body, InsertedById, IsRichText, LastEditById, LastEditDate, ParentId, Type, Visibility, CreatedDate, CreatedById, CreatedBy.Name, CreatedBy.Firstname, CreatedBy.Lastname from FeedItem where ParentId = :caseId and Visibility = 'AllUsers' and (type='TextPost' or type = 'LinkPost' or type='ContentPost')]){
                    CaseCommentWrapper ccwrp = new CaseCommentWrapper();
                    if(cc.Body != null){
                        ccwrp.caseId = cc.ParentId;
                        ccwrp.commentId = cc.Id;
                        ccwrp.sortOrder = sortOrder;
                        ccwrp.comment = cc.Body;
                        ccwrp.createddate = cc.CreatedDate;
                        ccwrp.creatorId = cc.CreatedById;
                        ccwrp.ispublic = '';
                        ccwrp.creatorname = (cc.CreatedBy.Firstname != null ? cc.CreatedBy.Firstname + ' ' : '') + cc.CreatedBy.Lastname;
                        ccwrp.attachlst = new List<AttachmentWrapper>();
                        if(mapFeedItemtoAttachment != null && !mapFeedItemtoAttachment.isEmpty() && mapFeedItemtoAttachment.containsKey(cc.Id)){
                            ccwrp.attachlst.addAll(mapFeedItemtoAttachment.get(cc.Id));
                        }
                        wrplst.add(ccwrp);
                    }
                }
                for(EmailMessage cc: [Select Id, fromaddress, toaddress, ccaddress, HtmlBody, ParentId, IsExternallyVisible, CreatedDate, CreatedById, CreatedBy.Name, CreatedBy.Firstname, CreatedBy.Lastname, (Select Id, ContentDocumentId, ContentDocument.Title from ContentDocumentLinks) from EmailMessage where ParentId = :caseId]){
                    CaseCommentWrapper ccwrp = new CaseCommentWrapper();
                    Boolean addem = false;
                    if(cc.fromaddress != null){
                        if(!cc.fromaddress.contains('@zscaler.com')){
                            addem = true; 
                        }
                    }
                    if(cc.toaddress != null){
                        List<String> emaillst = cc.toaddress.split(';');
                        for(String s: emaillst){
                            if(!s.contains('@zscaler.com')){
                                addem = true; 
                                break;
                            }
                        }
                    }
                    if(cc.ccaddress != null){
                        List<String> emaillst = cc.ccaddress.split(';');
                        for(String s: emaillst){
                            if(!s.contains('@zscaler.com')){
                                addem = true; 
                                break;
                            }
                        }
                    }
                    if(cc.HtmlBody != null && addem){
                        ccwrp.caseId = cc.ParentId;
                        ccwrp.commentId = cc.Id;
                        ccwrp.sortOrder = sortOrder;
                        ccwrp.comment = cc.HtmlBody;
                        ccwrp.createddate = cc.CreatedDate;
                        ccwrp.creatorId = cc.CreatedById;
                        ccwrp.ispublic = '';
                        ccwrp.creatorname = (cc.CreatedBy.Firstname != null ? cc.CreatedBy.Firstname + ' ' : '') + cc.CreatedBy.Lastname;
                        ccwrp.attachlst = new List<AttachmentWrapper>();
                        system.debug('+++++'+ ccwrp.creatorname +  cc.ContentDocumentLinks);
                        for(ContentDocumentLink cdl: cc.ContentDocumentLinks){
                            ccwrp.attachlst.add(new AttachmentWrapper(cdl.ContentDocument.Title, cdl.Id, '/' + portal + '/sfc/servlet.shepherd/document/download/'+cdl.ContentDocumentId));
                        }
                        wrplst.add(ccwrp);
                    }
                }
            }else{
                for(CaseComment cc: [Select Id, CommentBody, ParentId, Ispublished, CreatedDate, CreatedById, CreatedBy.Name, CreatedBy.Firstname, CreatedBy.Lastname from CaseComment where ParentId = :caseId]){
                    CaseCommentWrapper ccwrp = new CaseCommentWrapper();
                    if(cc.CommentBody != null){
                        ccwrp.caseId = cc.ParentId;
                        ccwrp.commentId = cc.Id;
                        ccwrp.sortOrder = sortOrder;
                        ccwrp.comment = cc.CommentBody;
                        ccwrp.createddate = cc.CreatedDate;
                        ccwrp.creatorId = cc.CreatedById;
                        ccwrp.ispublic = cc.IsPublished ? '<div style="background-color:yellow;color:brown;padding:3px;border-radius:20%;">Public</div>': 'Internal';
                        ccwrp.creatorname = (cc.CreatedBy.Firstname != null ? cc.CreatedBy.Firstname + ' ' : '') + cc.CreatedBy.Lastname;
                        ccwrp.attachlst = new List<AttachmentWrapper>();
                        wrplst.add(ccwrp);
                    }
                }
                for(FeedItem cc: [Select Id, Body, InsertedById, IsRichText, LastEditById, LastEditDate, ParentId, Type, Visibility, CreatedDate, CreatedById, CreatedBy.Name, CreatedBy.Firstname, CreatedBy.Lastname from FeedItem where ParentId = :caseId and (type='TextPost' or type = 'LinkPost' or type='ContentPost')]){
                    CaseCommentWrapper ccwrp = new CaseCommentWrapper();
                    if(cc.Body != null){
                        ccwrp.caseId = cc.ParentId;
                        ccwrp.commentId = cc.Id;
                        ccwrp.sortOrder = sortOrder;
                        ccwrp.comment = cc.Body;
                        ccwrp.createddate = cc.CreatedDate;
                        ccwrp.creatorId = cc.CreatedById;
                        ccwrp.ispublic = cc.Visibility == 'AllUsers' ? '<div style="background-color:yellow;color:brown;padding:3px;border-radius:20%;">Public</div>': 'Internal';
                        ccwrp.creatorname = (cc.CreatedBy.Firstname != null ? cc.CreatedBy.Firstname + ' ' : '') + cc.CreatedBy.Lastname;
                        ccwrp.attachlst = new List<AttachmentWrapper>();
                        if(mapFeedItemtoAttachment != null && !mapFeedItemtoAttachment.isEmpty() && mapFeedItemtoAttachment.containsKey(cc.Id)){
                            ccwrp.attachlst.addAll(mapFeedItemtoAttachment.get(cc.Id));
                        }
                        wrplst.add(ccwrp);
                    }
                }
                for(EmailMessage cc: [Select Id, fromaddress, toaddress, ccaddress, HtmlBody, ParentId, IsExternallyVisible, CreatedDate, CreatedById, CreatedBy.Name, CreatedBy.Firstname, CreatedBy.Lastname, (Select Id, ContentDocumentId, ContentDocument.Title from ContentDocumentLinks) from EmailMessage where ParentId = :caseId]){
                    CaseCommentWrapper ccwrp = new CaseCommentWrapper();
                    Boolean addem = false;
                    if(cc.fromaddress != null){
                        if(!cc.fromaddress.contains('@zscaler.com')){
                            addem = true; 
                        }
                    }
                    if(cc.toaddress != null){
                        List<String> emaillst = cc.toaddress.split(';');
                        for(String s: emaillst){
                            if(!s.contains('@zscaler.com')){
                                addem = true; 
                                break;
                            }
                        }
                    }
                    if(cc.ccaddress != null){
                        List<String> emaillst = cc.ccaddress.split(';');
                        for(String s: emaillst){
                            if(!s.contains('@zscaler.com')){
                                addem = true; 
                                break;
                            }
                        }
                    }
                    if(cc.HtmlBody != null && addem){
                        ccwrp.caseId = cc.ParentId;
                        ccwrp.commentId = cc.Id;
                        ccwrp.sortOrder = sortOrder;
                        ccwrp.comment = cc.HtmlBody;
                        ccwrp.createddate = cc.CreatedDate;
                        ccwrp.creatorId = cc.CreatedById;
                        ccwrp.ispublic = cc.IsExternallyVisible ? '<div style="background-color:yellow;color:brown;padding:3px;border-radius:20%;">Public</div>': 'Internal';
                        ccwrp.creatorname = (cc.CreatedBy.Firstname != null ? cc.CreatedBy.Firstname + ' ' : '') + cc.CreatedBy.Lastname;
                        ccwrp.attachlst = new List<AttachmentWrapper>();
                        for(ContentDocumentLink cdl: cc.ContentDocumentLinks){
                            ccwrp.attachlst.add(new AttachmentWrapper(cdl.ContentDocument.Title, cdl.Id, '/' + portal + '/sfc/servlet.shepherd/document/download/'+cdl.ContentDocumentId));
                        }
                        wrplst.add(ccwrp);
                    }
                }
            }
        }
        wrplst.sort();
        Integer loopsize = wrplst.size() > lim ? lim : wrplst.size();
        for(Integer a = 0; a < loopsize; a++){
            finallst.add(wrplst[a]);
        }
        system.debug('++++'+ wrplst);
        return finallst;
    }
    public class CaseCommentWrapper  implements Comparable{
        @AuraEnabled
        public String commentId;
        @AuraEnabled
        public String caseId;
        @AuraEnabled
        public String comment;
        @AuraEnabled
        public String ispublic;
        @AuraEnabled
        public String creatorId;
        @AuraEnabled
        public String creatorname;
        @AuraEnabled
        public String sortOrder;
        @AuraEnabled
        public DateTime createddate;
        @AuraEnabled
        public List<AttachmentWrapper> attachlst;

        public Integer compareTo(Object compareTo) {
            CaseCommentWrapper gsarec2 = (CaseCommentWrapper)compareTo;
            if(this.sortOrder == 'ASC'){
                if(this.createddate < gsarec2.createddate){
                    return -1;
                }else if(this.createddate > gsarec2.createddate){
                    return 1;
                }else{
                    return 0;
                }
            }else{
                if(this.createddate < gsarec2.createddate){
                    return 1;
                }else if(this.createddate > gsarec2.createddate){
                    return -1;
                }else{
                    return 0;
                }
            }
        }
    }
    //Method added by Puneeth
    public static void updateContentDocLinks(List<String> contDocIds, string feedId, boolean isportaluser){

        if(contDocIds!=null && !contDocIds.isEmpty()){
            if(isportaluser){
                List<ContentDocumentLink> contentDocLinks = new List<ContentDocumentLink>();
                for(Id cdId: contDocIds){
                    ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId=cdId);
                    cdl.LinkedEntityId = feedId;
                    cdl.ShareType = 'V';
                    cdl.Visibility = 'AllUsers';
                    contentDocLinks.add(cdl);
                }
                system.debug(contentDocLinks);
                delete [Select Id from ContentDocumentLink where ContentDocumentId in :contDocIds];
                insert contentDocLinks;
            }else{
                /*List<User> ulst = [Select Id, ContactId from User where Id = :UserInfo.getUserId()];
                List<ContentDocumentLink> contentDocLinks = new List<ContentDocumentLink>();
                for(ContentDocumentLink contDocLink : [SELECT Id,Visibility FROM ContentDocumentLink WHERE ContentDocumentId IN : contDocIds]){
                    contDocLink.Visibility = ulst != null && !ulst.isEmpty() && ulst[0].ContactId != null ? 'AllUsers' : 'InternalUsers';
                    contentDocLinks.add(contDocLink);
                }
                system.debug(contentDocLinks);
                update contentDocLinks;*/
                List<FeedAttachment> falst = new List<FeedAttachment>();
                for(ContentVersion cv : [SELECT Id FROM ContentVersion WHERE ContentDocumentId IN : contDocIds]){
                    FeedAttachment fa = new FeedAttachment(FeedEntityId = feedId, RecordId = cv.Id, Type='CONTENT');
                    falst.add(fa);
                }
                system.debug(falst);
                insert falst;
            }
            
            
        }        
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