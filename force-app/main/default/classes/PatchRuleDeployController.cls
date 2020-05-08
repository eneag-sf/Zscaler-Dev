/*
 * Controller of page PatchRuleDeploy
 */
public class PatchRuleDeployController 
{   
    private static final Integer NumberOfPatchesInEachEngine = Integer.valueOf(Label.NumberOfPatchesInEachEngine);

    public PatchRuleDeployController()
    {
        isValidate = (ApexPages.currentPage().getParameters().get('validate') == '1');
        isConfirmed = isValidate ? true : false;
        bodyGenerated = false;
        realign = false;
        accRealign = true;
        leadRealign = true;
        EngineClassName2Body = new Map<String, String>();
        EngineTestClassName2Body = new Map<String, String>();

        if(isConfirmed)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Generating deployment package...'));
        }

        try
        {
            List<Patch__c> patchesForBuild = new List<Patch__c>();
            Integer engineIndex = 0;
            for(Patch__c patch : [select Id from Patch__c where Active__c=true order by ProcessingSequence__c])
            {
                 patchesForBuild.add(patch);

                if(patchesForBuild.size() == NumberOfPatchesInEachEngine)
                {
                    String engineIndexStr = engineIndex == 0 ? '' : String.valueOf(engineIndex);
                    PatchRuleEngineBuilder builder = new PatchRuleEngineBuilder(engineIndexStr, patchesForBuild);
                    EngineClassName2Body.put('PatchRuleEngine' + engineIndexStr, builder.build());
                    EngineTestClassName2Body.put('PatchRuleEngineTest' + engineIndexStr, builder.buildTestCoverage());

                    engineIndex++;
                    patchesForBuild.clear();
                }
            }

            if(!patchesForBuild.isEmpty())
            {
                String engineIndexStr = engineIndex == 0 ? '' : String.valueOf(engineIndex);
                PatchRuleEngineBuilder builder = new PatchRuleEngineBuilder(engineIndexStr, patchesForBuild);
                EngineClassName2Body.put('PatchRuleEngine' + engineIndexStr, builder.build());
                EngineTestClassName2Body.put('PatchRuleEngineTest' + engineIndexStr, builder.buildTestCoverage());
            }

            bodyGenerated = true;
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
            bodyGenerated = false;
        }
    }
    public Boolean isValidate { get; set; }
    public Boolean isConfirmed { get; set; }
    public Boolean bodyGenerated { get; set; }
    public Boolean realign { get; set; }
    public Boolean accRealign { get; set; }
    public Boolean leadRealign { get; set; }
    public Boolean IsAdmin
    {
        get
        {
            return PatchRuleHelper.IsAdmin;
        }
    }
    
    public String ZipData { get; set; } 
    public Map<String, String> EngineClassName2Body { get; set; }
    public Map<String, String> EngineTestClassName2Body { get; set; }

    public MetadataService.AsyncResult AsyncResult {get; private set;}

    public String getPackageXml()
    {
        List<String> classNames = new List<String>();
        classNames.addAll(EngineClassName2Body.keySet());
        classNames.addAll(EngineTestClassName2Body.keySet());

        String members = '';
        for(String className : classNames)
        {
            members += '<types>' + 
                            '<members>' + className + '</members>' +
                            '<name>ApexClass</name>' + 
                        '</types>';
        }

        return '<?xml version="1.0" encoding="UTF-8"?>' + 
            '<Package xmlns="http://soap.sforce.com/2006/04/metadata">' + 
                members +
                '<version>40.0</version>' + 
            '</Package>';
    }

    public String getClassMetadata()
    {
        return '<?xml version="1.0" encoding="UTF-8"?>' +
            '<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">' +
                '<apiVersion>40.0</apiVersion>' + 
                '<status>Active</status>' +
            '</ApexClass>';     
    }
    
    public PageReference startDeploy()
    {
        isConfirmed = true;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Generating deployment package...'));
        return null;
    }
    
    public PageReference deployZip()
    {
        if(bodyGenerated)
        {
            if(IsAdmin)
            {
                List<String> teststorun = new List<String>();
                teststorun.addAll(EngineTestClassName2Body.keySet());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, (isValidate ? 'Validating...' : 'Deploying...')));
                MetadataService.MetadataPort service = createService();
                MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions();
                deployOptions.allowMissingFiles = false;
                deployOptions.autoUpdatePackage = false;
                deployOptions.checkOnly = isValidate;
                deployOptions.ignoreWarnings = false;
                deployOptions.performRetrieve = false;
                deployOptions.purgeOnDelete = false;
                deployOptions.rollbackOnError = true;
                //deployOptions.runAllTests = false;
                deployOptions.runTests = teststorun;
                deployOptions.testlevel = 'RunSpecifiedTests';
                deployOptions.singlePackage = true;     
                AsyncResult = service.deploy(ZipData, DeployOptions);
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, (isValidate ? 'Validation succeeded' : 'Validation succeeded, however you don\'t have permission to do deployment. Please contact system administrator.')));
            }
        }
        return null;
    }   

    public PageReference checkAsyncRequest()
    {   
        // Check the status of the retrieve request
        MetadataService.MetadataPort service = createService();
        MetadataService.DeployResult deployResult = service.checkDeployStatus(AsyncResult.Id, true);
        if(deployResult != null)
        {
            if(deployResult.done)
            {
                if(deployResult.success == true)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, (isValidate ? 'Validation succeeded' : 'Deployment complete')));
                    if(Realign)
                    {
                        String realignType = getRealignType();
                        if(realignType != null)
                        {
                            String URL = '/apex/PatchRealign?start=1&realigntype=' + realignType;
                            return new PageReference(URL);
                        }
                    }
                }
                else if(deployResult.status == 'Failed')
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Failled to validate/deploy the patches, error message is: ' + getDeployResultMessage(deployResult)));
                    AsyncResult = null;
                }
                else if(deployResult.status == 'Canceled')
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Validation/Deployment is canceled by administrator'));
                    AsyncResult = null;
                }
            }
            else
            {
                if(deployResult.status == 'Canceling')
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Validation/Deployment is cancelling by administrator.'));
                }
                else if(deployResult.status == 'InProgress')
                {
                    Decimal numberTestsCompleted = (deployResult.numberTestsCompleted == null) ? 0 : deployResult.numberTestsCompleted;
                    Decimal numberTestsTotal = (deployResult.numberTestsTotal == null) ? 0 : deployResult.numberTestsTotal;
                    Integer percentageComplete = numberTestsTotal == 0 ? 0 : ((numberTestsCompleted / numberTestsTotal) * 100).intValue();
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, (isValidate ? 'Validation in progress: ' + percentageComplete + '%' : 'Deployment in progress: ' + percentageComplete + '%')));
                }
                else
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, (isValidate ? 'Validating...' : 'Deploying...')));
                }
            } 
        } 
        return null;
    }

    private String getDeployResultMessage(MetadataService.DeployResult deployResult)
    {
        String message = '';
        if(deployResult.details != null && deployResult.details.componentFailures != null)
        {
            for(MetadataService.DeployMessage dm : deployResult.details.componentFailures)
            {
                if(String.isNotBlank(dm.problem))
                {
                    message += dm.problem + '; ';
                }
            }
        }
        if(deployResult.details != null && deployResult.details.runTestResult != null)
        {
            if(deployResult.details.runTestResult.failures != null)
            {
                message += 'Failed to execute existing test methods. ';
                for(MetadataService.RunTestFailure failure : deployResult.details.runTestResult.failures)
                {
                    message += failure.message + '[' + failure.name + '.' + failure.methodName + ']; ';
                }
            }
            if(deployResult.details.runTestResult.codeCoverage != null)
            {
            }
        }
        return message;
    }
    
    private static MetadataService.MetadataPort createService()
    { 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;     
    } 

    private String getRealignType()
    {
        if(accRealign && leadRealign) return 'AL';
        if(accRealign && leadRealign == false) return 'Account';
        if(accRealign == false && leadRealign) return 'Lead';
        return null;
    }
}