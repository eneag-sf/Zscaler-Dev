@isTest
public class PatchRuleDeployControllerTest
{
    @isTest
    private static void testWithStatusInProgress()
    {
        Patch__c patch1 = new Patch__c(PatchName__c='acme', Active__c=true, ProcessingSequence__c=1);
        insert patch1;
        PatchCriteriaRule__c rule1 = new PatchCriteriaRule__c(Patch__c=patch1.Id, Field__c='Country', Operation__c='equals', Value__c='US', ProcessingSequence__c=1);
        insert rule1;
        
        Test.startTest();
        try
        {
            Test.setMock(WebServiceMock.class, new MetadataServiceMockupInProgress());
            PatchRuleDeployController controller = new PatchRuleDeployController();
            String s1 = controller.getPackageXml();
            String s2 = controller.getClassMetadata();
            //String s3 = controller.getClassBody();
            //String s4 = controller.getTestClassBody();
            controller.ZipData = 'acme';
            controller.startDeploy();
            controller.deployZip();
            controller.checkAsyncRequest();
        }
        catch(Exception ex) {}
        Test.stopTest();
    }
    
    @isTest
    private static void testWithStatusInCanceling()
    {
        Patch__c patch1 = new Patch__c(PatchName__c='acme', Active__c=true, ProcessingSequence__c=1);
        insert patch1;
        PatchCriteriaRule__c rule1 = new PatchCriteriaRule__c(Patch__c=patch1.Id, Field__c='Country', Operation__c='equals', Value__c='US', ProcessingSequence__c=1);
        insert rule1;
        
        Test.startTest();
        try
        {
            Test.setMock(WebServiceMock.class, new MetadataServiceMockupCanceling());
            PatchRuleDeployController controller = new PatchRuleDeployController();
            String s1 = controller.getPackageXml();
            String s2 = controller.getClassMetadata();
            //String s3 = controller.getClassBody();
            //String s4 = controller.getTestClassBody();
            controller.ZipData = 'acme';
            controller.startDeploy();
            controller.deployZip();
            controller.checkAsyncRequest();
        }
        catch(Exception ex) {}
        Test.stopTest();
    }
    
    @isTest
    private static void testWithStatusFailed()
    {
        Patch__c patch1 = new Patch__c(PatchName__c='acme', Active__c=true, ProcessingSequence__c=1);
        insert patch1;
        PatchCriteriaRule__c rule1 = new PatchCriteriaRule__c(Patch__c=patch1.Id, Field__c='Country', Operation__c='equals', Value__c='US', ProcessingSequence__c=1);
        insert rule1;
        
        Test.startTest();
        try
        {
            Test.setMock(WebServiceMock.class, new MetadataServiceMockupFailed());
            PatchRuleDeployController controller = new PatchRuleDeployController();
            String s1 = controller.getPackageXml();
            String s2 = controller.getClassMetadata();
            //String s3 = controller.getClassBody();
            //String s4 = controller.getTestClassBody();
            controller.ZipData = 'acme';
            controller.startDeploy();
            controller.deployZip();
            controller.checkAsyncRequest();
        }
        catch(Exception ex) {}
        Test.stopTest();
    }
    
    @isTest
    private static void testWithStatusSuccssded()
    {
        Patch__c patch1 = new Patch__c(PatchName__c='acme', Active__c=true, ProcessingSequence__c=1);
        insert patch1;
        PatchCriteriaRule__c rule1 = new PatchCriteriaRule__c(Patch__c=patch1.Id, Field__c='Country', Operation__c='equals', Value__c='US', ProcessingSequence__c=1);
        insert rule1;
        
        Test.startTest();
        try
        {
            Test.setMock(WebServiceMock.class, new MetadataServiceMockupSuccssded());
            PatchRuleDeployController controller = new PatchRuleDeployController();
            String s1 = controller.getPackageXml();
            String s2 = controller.getClassMetadata();
            //String s3 = controller.getClassBody();
            //String s4 = controller.getTestClassBody();
            controller.ZipData = 'acme';
            controller.startDeploy();
            controller.deployZip();
            controller.checkAsyncRequest();
        }
        catch(Exception ex) {}
        Test.stopTest();
    }
    
    @isTest
    private static void testWithStatusCanceled()
    {
        Patch__c patch1 = new Patch__c(PatchName__c='acme', Active__c=true, ProcessingSequence__c=1);
        insert patch1;
        PatchCriteriaRule__c rule1 = new PatchCriteriaRule__c(Patch__c=patch1.Id, Field__c='Country', Operation__c='equals', Value__c='US', ProcessingSequence__c=1);
        insert rule1;
        
        Test.startTest();
        try
        {
            Test.setMock(WebServiceMock.class, new MetadataServiceMockupCanceled());
            PatchRuleDeployController controller = new PatchRuleDeployController();
            String s1 = controller.getPackageXml();
            String s2 = controller.getClassMetadata();
            //String s3 = controller.getClassBody();
            //String s4 = controller.getTestClassBody();
            controller.ZipData = 'acme';
            controller.startDeploy();
            controller.deployZip();
            controller.checkAsyncRequest();
        }
        catch(Exception ex) {}
        Test.stopTest();
    }
    
    public class MetadataServiceMockupInProgress implements WebServiceMock 
    {
        public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) 
        {
            if(requestName == 'deploy')
            {
                MetadataService.deployResponse_element responseElement = new MetadataService.deployResponse_element();
                responseElement.result = new MetadataService.AsyncResult();
                response.put('response_x', responseElement);
            }
            else if(requestName == 'checkDeployStatus')
            {
                MetadataService.checkDeployStatusResponse_element responseElement = new MetadataService.checkDeployStatusResponse_element();
                MetadataService.DeployResult result = new MetadataService.DeployResult();
                result.done = false;
                result.status = 'InProgress';
                result.details = new MetadataService.DeployDetails();
                result.details.componentFailures = new List<MetadataService.DeployMessage>();
                responseElement.result = result;
                response.put('response_x', responseElement);
            }
        }
    }
    
    public class MetadataServiceMockupCanceling implements WebServiceMock 
    {
        public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) 
        {
            if(requestName == 'deploy')
            {
                MetadataService.deployResponse_element responseElement = new MetadataService.deployResponse_element();
                responseElement.result = new MetadataService.AsyncResult();
                response.put('response_x', responseElement);
            }
            else if(requestName == 'checkDeployStatus')
            {
                MetadataService.checkDeployStatusResponse_element responseElement = new MetadataService.checkDeployStatusResponse_element();
                MetadataService.DeployResult result = new MetadataService.DeployResult();
                result.done = false;
                result.status = 'Canceling';
                result.details = new MetadataService.DeployDetails();
                result.details.componentFailures = new List<MetadataService.DeployMessage>();
                responseElement.result = result;
                response.put('response_x', responseElement);
            }
        }
    }
    
    public class MetadataServiceMockupFailed implements WebServiceMock 
    {
        public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) 
        {
            if(requestName == 'deploy')
            {
                MetadataService.deployResponse_element responseElement = new MetadataService.deployResponse_element();
                responseElement.result = new MetadataService.AsyncResult();
                response.put('response_x', responseElement);
            }
            else if(requestName == 'checkDeployStatus')
            {
                MetadataService.checkDeployStatusResponse_element responseElement = new MetadataService.checkDeployStatusResponse_element();
                MetadataService.DeployResult result = new MetadataService.DeployResult();
                result.done = true;
                result.status = 'Failed';
                result.details = new MetadataService.DeployDetails();
                result.details.componentFailures = new List<MetadataService.DeployMessage>();
                responseElement.result = result;
                response.put('response_x', responseElement);
            }
        }
    }
    
    public class MetadataServiceMockupSuccssded implements WebServiceMock 
    {
        public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) 
        {
            if(requestName == 'deploy')
            {
                MetadataService.deployResponse_element responseElement = new MetadataService.deployResponse_element();
                responseElement.result = new MetadataService.AsyncResult();
                response.put('response_x', responseElement);
            }
            else if(requestName == 'checkDeployStatus')
            {
                MetadataService.checkDeployStatusResponse_element responseElement = new MetadataService.checkDeployStatusResponse_element();
                MetadataService.DeployResult result = new MetadataService.DeployResult();
                result.done = true;
                result.success = true;
                result.details = new MetadataService.DeployDetails();
                result.details.componentFailures = new List<MetadataService.DeployMessage>();
                responseElement.result = result;
                response.put('response_x', responseElement);
            }
        }
    }
    
    public class MetadataServiceMockupCanceled implements WebServiceMock 
    {
        public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) 
        {
            if(requestName == 'deploy')
            {
                MetadataService.deployResponse_element responseElement = new MetadataService.deployResponse_element();
                responseElement.result = new MetadataService.AsyncResult();
                response.put('response_x', responseElement);
            }
            else if(requestName == 'checkDeployStatus')
            {
                MetadataService.checkDeployStatusResponse_element responseElement = new MetadataService.checkDeployStatusResponse_element();
                MetadataService.DeployResult result = new MetadataService.DeployResult();
                result.done = true;
                result.status = 'Canceled';
                result.details = new MetadataService.DeployDetails();
                result.details.componentFailures = new List<MetadataService.DeployMessage>();
                responseElement.result = result;
                response.put('response_x', responseElement);
            }
        }
    }
}