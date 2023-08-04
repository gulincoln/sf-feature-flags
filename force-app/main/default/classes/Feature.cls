public class Feature {

    @TestVisible
    private static FeatureFlags service;

    static {
        service = new FeatureFlags();
    }

    
    public static Boolean isEnabled(String featureFlag) {

        return service.evaluate(featureFlag).isEnabled();
    
    }

    public static Boolean isDisabled(String featureFlag) {

        return service.evaluate(featureFlag).isDisabled();
    
    }

    @TestVisible
    private static void enable(String featureFlag) {

        service.enable(featureFlag);

    }

    @TestVisible
    private static void disable(String featureFlag) {

        service.disable(featureFlag);

    }

}