public with sharing class FeatureFlags {

    private FeatureFlag__mdt contextFlag;
    private FeatureFlagProvider provider;
    
    private Set<String> customPermissions;

    private Map<String, FeatureFlag__mdt> features = new Map<String, FeatureFlag__mdt>();

    @TestVisible
    private Map<String, Boolean> mockedFeatures = new Map<String, Boolean>();


    public FeatureFlags() {
        this(new FeatureFlagProvider());
    }

    public FeatureFlags(FeatureFlagProvider provider) {
        this.provider = provider;
        customPermissions = provider.getPermissions();
        features = provider.getAllFeatures();
    }

    //for test purposes
    public void enable(String featureFlag) {
        mockedFeatures.put(featureFlag, true);
    }

    public void disable(String featureFlag) {
        mockedFeatures.put(featureFlag, false);
    }

    public FeatureFlagResult evaluate(String featureFlag) {

        if(mockedFeatures.containsKey(featureFlag)) {
            return new FeatureFlagResult(featureFlag, mockedFeatures.get(featureFlag), FeatureFlagReason.MOCK);
        }

        if(!features.containsKey(featureFlag)) {
            return new FeatureFlagResult(featureFlag, false, FeatureFlagReason.MISSING_FLAG);
        }

        contextFlag = features.get(featureFlag);

        if(contextFlag.IsEnabledByPermission__c) {
            return evaluatePermission(contextFlag);
        }

        return new FeatureFlagResult(featureFlag, contextFlag.IsEnabled__c, FeatureFlagReason.CUSTOM_METADATA_DEFINED);

    }

    @TestVisible
    private FeatureFlagResult evaluatePermission(FeatureFlag__mdt contextFlag) {

        if(String.isBlank(contextFlag.CustomPermission__c) || !isValidCustomPermission(contextFlag.CustomPermission__c)) {
            return new FeatureFlagResult(contextFlag.DeveloperName, false, FeatureFlagReason.PERMISSION_NOT_DEFINED);
        }

        return hasPermissionEnabled(contextFlag);

    }

    @TestVisible
    private FeatureFlagResult hasPermissionEnabled(FeatureFlag__mdt contextFlag) {

        Boolean hasPermission = FeatureManagement.checkPermission(contextFlag.CustomPermission__c);

        FeatureFlagReason reason = (hasPermission) ? FeatureFlagReason.CUSTOM_PERMISSION : FeatureFlagReason.PERMISSION_NOT_ASSIGNED;
        
        return new FeatureFlagResult(contextFlag.DeveloperName, hasPermission, reason);
    
    }

    @TestVisible
    private Boolean isValidCustomPermission(String customPermission) {
        return customPermissions.contains(customPermission);
    }

    public class FeatureFlagResult {
        private String name;
        private Boolean isEnabled;
        private FeatureFlagReason reason;

        public FeatureFlagResult(String name, Boolean isEnabled, FeatureFlagReason reason) {
            this.name = name;
            this.isEnabled = isEnabled;
            this.reason = reason;
        }

        public String getName() {
            return this.name;
        }

        public Boolean isEnabled() {
            return this.isEnabled;
        }

        public String getReason() {
            return this.reason.name();
        }

    }

    public enum FeatureFlagReason {
        CUSTOM_METADATA_DEFINED,
        CUSTOM_PERMISSION,
        MISSING_FLAG,
        PERMISSION_NOT_DEFINED,
        PERMISSION_NOT_ASSIGNED,
        MOCK
    }

}