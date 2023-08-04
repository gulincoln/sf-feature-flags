@isTest
private class FeatureFlagsTest {

    private static final String FEATURE_NAME = 'AllowCaseCreationTest';
    
    @isTest
    static void shouldBeEnabled_whenCheckFeatureToggleForCustomPermissionWithFlagEnabled() {

        FeatureFlag__mdt featureFlag = buildFeatureFlag(FEATURE_NAME, true, true);

        FeatureFlagProviderMock mockProvider = new FeatureFlagProviderMock();

        mockProvider.setMockFeature(FEATURE_NAME, featureFlag);
        mockProvider.setMockPermission(FEATURE_NAME);

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
    /*
    @isTest
    static void shouldThrownException_whenCheckFeatureToggleForInvalidCustomPermission() {
        
    }
    */
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

        public FeatureFlagProviderMock() {
            mockedPermissions = new Set<String>();
            mockedFeatures = new Map<String, FeatureFlag__mdt>();
        }

        public void setMockFeature(String featureFlag, FeatureFlag__mdt feature) {
            mockedFeatures.put(featureFlag, feature);
        }

        public void setMockPermission(String customPermission) {
            mockedPermissions.add(customPermission);
        }

        override
        public Map<String, FeatureFlag__mdt> getAllFeatures() {
            return mockedFeatures;
        }
    
        override
        public Set<String> getPermissions() {
            return mockedPermissions;
        }

    }

}