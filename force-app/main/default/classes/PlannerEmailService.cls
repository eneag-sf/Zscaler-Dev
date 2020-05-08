global class PlannerEmailService implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail inemail, 
                                                       Messaging.InboundEnvelope env){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        try {
            String myPlainText= '';
            String ProjectId = inemail.subject;
            
            system.debug('HTML Body ::'+inemail.htmlBody);
            system.debug('Plan Body ::'+inemail.plainTextBody);
            system.debug('References ::'+inemail.references);
            //Subject Text [Ref:ProjectId] 
            if(ProjectId.contains('Ref:')){
                ProjectId = ProjectId.split('Ref:')[1];
            }
            
            if(ProjectId.contains(']')){
                ProjectId = ProjectId.remove(']');
            }
            
            myPlainText = inemail.plainTextBody;
            system.debug('--ProjectId--'+ProjectId);
            
            inspire1__Project__c ProjectRec = new inspire1__Project__c();
            if(ProjectId != null){
                ProjectRec = [select Id,Name from inspire1__Project__c Where Id =: ProjectId limit 1];
                
                EmailMessage EmailMsg = new EmailMessage();
                EmailMsg.FromAddress = inemail.fromAddress;
                
                string Body = String.valueOf(inemail.HtmlBody);
                string splitstring = '<div style="font-family:\'Helvetica Neue\', Helvetica, Arial, sans-serif;font-size:13px;color:#26282a;">';
                if(Body != null && Body != ''){
                    if(Body.contains('<div class="gmail_quote">')){
                        Body = Body.split('<div class="gmail_quote">')[0];
                    }
                     if(Body.contains(splitstring)){
                        Body = Body.split(splitstring)[0];
                    }
                    if(Body.contains('<div style="height:auto; min-height:auto">')){
                        Body = Body.split('<div style="height:auto; min-height:auto">')[0];
                    }
                    
                }
                EmailMsg.HtmlBody = Body;
                EmailMsg.Incoming = true;
                EmailMsg.Status = '2'; //'0' = New '1' = Read '2' = Replied '3' = Sent '4' = Forwarded
                EmailMsg.relatedToId = ProjectRec.Id;
                //system.debug('--HTML body--'+inemail.htmlBody);
                //EmailMsg.TextBody = inemail.plainTextBody;
                if(inemail.toAddresses != null)
                EmailMsg.ToAddress = inemail.toAddresses[0];
                if(inemail.ccAddresses != null)          
                EmailMsg.CcAddress = inemail.ccAddresses[0];
                EmailMsg.Subject = inemail.subject;        
                //system.debug('-----Body.stripHtmlTags()----'+Body.stripHtmlTags());  
                if(Body.stripHtmlTags().trim() != ''){
                    insert EmailMsg;
                }
                
                List<Attachment> attachments = new List<Attachment>();
                if(inemail.textAttachments != null)
                {
                	for (Messaging.Inboundemail.TextAttachment tAttachment : inemail.textAttachments) {
                	  Attachment attachment = new Attachment();
                	  attachment.Name = tAttachment.fileName;
                	  attachment.Body = Blob.valueOf(tAttachment.body);
                	  attachment.ParentId = ProjectId;
                	  attachments.add(attachment);
                	}
                }
                if(inemail.binaryAttachments != null)
                {
                	for (Messaging.Inboundemail.BinaryAttachment bAttachment : inemail.binaryAttachments) {
                	  Attachment attachment = new Attachment();
                	  attachment.Name = bAttachment.fileName;
                	  attachment.Body = bAttachment.body;
                	  attachment.ParentId = ProjectId;
                	  attachments.add(attachment);
                	}
                }
                if(attachments.size() > 0){
                	insert attachments;
                }
            }
        }catch(Exception ex){
            System.debug('Error occurred while processing. \nReason: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
        }
        
        result.success = true;
        return result;
    }
}