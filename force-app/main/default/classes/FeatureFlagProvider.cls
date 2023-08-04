public virtual with sharing class FeatureFlagProvider {

    @TestVisible
    private Set<String> customPermissions;

    private static final Map<String, FeatureFlag__mdt> features = FeatureFlag__mdt.getAll();

    public FeatureFlagProvider() {
        this.customPermissions = new Set<String>();
        this.setAllPermissions();
    }

    virtual
    public Map<String, FeatureFlag__mdt> getAllFeatures() {
        return features;
    }

    virtual
    public Set<String> getPermissions() {
        return this.customPermissions;
    }

    virtual
    public Boolean hasAssignedPermission(String customPermission) {
        return FeatureManagement.checkPermission(customPermission);
    }

    private void setAllPermissions() {

        for(CustomPermission permission : [SELECT Id, DeveloperName FROM CustomPermission]) {
            customPermissions.add(permission.DeveloperName);
        }
    
    }

}