@isTest
private class FeatureFlagsTest {

    private static final String FEATURE_NAME = 'AllowCaseCreationTest';
    
    @isTest
    static void shouldBeEnabled_whenCheckFeatureToggleForCustomPermissionWithFlagEnabled() {

        FeatureFlag__mdt featureFlag = buildFeatureFlag(FEATURE_NAME, true, true);

        FeatureFlagProviderMock mockProvider = new FeatureFlagProviderMock();

        mockProvider.setMockFeature(FEATURE_NAME, featureFlag);
        mockProvider.setMockPermission(FEATURE_NAME);
        mockProvider.enableAssignment();

        FeatureFlags service = new FeatureFlags(mockProvider);

        Test.startTest();

        FeatureFlags.FeatureFlagResult result = service.evaluate(FEATURE_NAME);

        Test.stopTest();

        Assert.areEqual(FEATURE_NAME, result.getName());
        Assert.isTrue(result.isEnabled());
        Assert.areEqual(FeatureFlags.FeatureFlagReason.CUSTOM_PERMISSION.name(), result.getReason());

    }

    @isTest
    static void shouldBeDisabled_whenCheckFeatureToggleForCustomPermissionWithNoFlagEnabled() {

        FeatureFlag__mdt featureFlag = buildFeatureFlag(FEATURE_NAME, false, false);

        FeatureFlagProviderMock mockProvider = new FeatureFlagProviderMock();

        mockProvider.setMockFeature(FEATURE_NAME, featureFlag);
        mockProvider.setMockPermission(FEATURE_NAME);

        FeatureFlags service = new FeatureFlags(mockProvider);

        Test.startTest();

        FeatureFlags.FeatureFlagResult result = service.evaluate(FEATURE_NAME);

        Test.stopTest();

        Assert.areEqual(FEATURE_NAME, result.getName());
        Assert.isFalse(result.isEnabled());
        Assert.areEqual(FeatureFlags.FeatureFlagReason.CUSTOM_METADATA_DEFINED.name(), result.getReason());
        
    }

    @isTest
    static void shouldBeDisabled_whenCheckFeatureToggleForCustomPermissionWithoutUserAssigned() {

        FeatureFlag__mdt featureFlag = buildFeatureFlag(FEATURE_NAME, true, true);

        FeatureFlagProviderMock mockProvider = new FeatureFlagProviderMock();

        mockProvider.setMockFeature(FEATURE_NAME, featureFlag);
        mockProvider.setMockPermission(FEATURE_NAME);

        FeatureFlags service = new FeatureFlags(mockProvider);

        Test.startTest();

        FeatureFlags.FeatureFlagResult result = service.evaluate(FEATURE_NAME);

        Test.stopTest();

        Assert.areEqual(FEATURE_NAME, result.getName());
        Assert.isFalse(result.isEnabled());
        Assert.areEqual(FeatureFlags.FeatureFlagReason.PERMISSION_NOT_ASSIGNED.name(), result.getReason());
        
    }
    
    @isTest
    static void shouldReturnDisabledAndPermissionNotDefinedReason_whenCheckForInvalidCustomPermission() {

        FeatureFlag__mdt featureFlag = buildFeatureFlag(FEATURE_NAME, false, true);

        FeatureFlagProviderMock mockProvider = new FeatureFlagProviderMock();

        mockProvider.setMockFeature(FEATURE_NAME, featureFlag);
        mockProvider.setMockPermission('AnotherCustomPermission');

        FeatureFlags service = new FeatureFlags(mockProvider);

        Test.startTest();

        FeatureFlags.FeatureFlagResult result = service.evaluate(FEATURE_NAME);

        Test.stopTest();

        Assert.areEqual(FEATURE_NAME, result.getName());
        Assert.isFalse(result.isEnabled());
        Assert.areEqual(FeatureFlags.FeatureFlagReason.PERMISSION_NOT_DEFINED.name(), result.getReason());
        
    }

    @isTest
    static void shouldReturnDisabledAndMissingFlagReason_whenCheckForUndefinedFeatureFlag() {

        FeatureFlags service = new FeatureFlags();

        Test.startTest();

        FeatureFlags.FeatureFlagResult result = service.evaluate(FEATURE_NAME);

        Test.stopTest();

        Assert.areEqual(FEATURE_NAME, result.getName());
        Assert.isFalse(result.isEnabled());
        Assert.areEqual(FeatureFlags.FeatureFlagReason.MISSING_FLAG.name(), result.getReason());

    }

    @isTest
    static void shouldReturnEnabled_whenCheckForMockedFeatureFlag() {

        FeatureFlag__mdt featureFlag = buildFeatureFlag(FEATURE_NAME, false, false);

        FeatureFlags service = new FeatureFlags();

        service.enable(FEATURE_NAME);

        Test.startTest();

        FeatureFlags.FeatureFlagResult result = service.evaluate(FEATURE_NAME);

        Test.stopTest();

        Assert.areEqual(FEATURE_NAME, result.getName());
        Assert.isTrue(result.isEnabled());
        Assert.areEqual(FeatureFlags.FeatureFlagReason.MOCK.name(), result.getReason());

    }
    
    static FeatureFlag__mdt buildFeatureFlag(String name, Boolean isEnabled) {
        return buildFeatureFlag(name, isEnabled, !isEnabled);
    }

    static FeatureFlag__mdt buildFeatureFlag(String name, Boolean isEnabled, Boolean isEnabledByPermission) {

        String payload = '{"Id":"m008b0000001e8PAAQ","DeveloperName":"'+name+'","CustomPermission__c":"'+name+'","IsEnabled__c":'+isEnabled+',"IsEnabledByPermission__c":'+isEnabledByPermission+'}';

        return (FeatureFlag__mdt) JSON.deserialize(payload, FeatureFlag__mdt.class);

    }

    public class FeatureFlagProviderMock extends FeatureFlagProvider {

        private Set<String> mockedPermissions;
        private Map<String, FeatureFlag__mdt> mockedFeatures;
        private Boolean mockedAssignment;

        public FeatureFlagProviderMock() {
            mockedPermissions = new Set<String>();
            mockedFeatures = new Map<String, FeatureFlag__mdt>();
            mockedAssignment = false;
        }

        public void setMockFeature(String featureFlag, FeatureFlag__mdt feature) {
            mockedFeatures.put(featureFlag, feature);
        }

        public void setMockPermission(String customPermission) {
            mockedPermissions.add(customPermission);
        }

        public void enableAssignment() {
            mockedAssignment = true;
        }

        override
        public Map<String, FeatureFlag__mdt> getAllFeatures() {
            return mockedFeatures;
        }
    
        override
        public Set<String> getPermissions() {
            return mockedPermissions;
        }

        override
        public Boolean hasAssignedPermission(String customPermission) {

            if(mockedAssignment) return mockedAssignment;

            return super.hasAssignedPermission(customPermission);

        }

    }

}