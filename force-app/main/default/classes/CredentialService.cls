public class CredentialService {
    static Map<String, Gateway__c> records;
    public static Gateway__c getStripeGateway(String department) {
        if (records == null) {
            getRecords();
        }
        return records.get(department);
    }

    public static string getPublicStripeKey(String department) {
        return getStripeGateway(department).Publishable_Key__c;
    }

    public static string getPrivateStripeKey(String department) {
        return getStripeGateway(department).Secret_Key__c;
    }

    private static  void getRecords() {
        List<Gateway__c> gateways = [SELECT Id, Department__c, Publishable_Key__c, Secret_Key__c FROM Gateway__c WHERE Active__c = true];
        records = new Map<String, Gateway__c>();

        for (Gateway__c gateway : gateways) {
            records.put(gateway.Department__c, gateway);
        }
    }


    // private static Stripe_Settings__c settings;

    // public static Stripe_Settings__c getStripeSettings() {
    //     if (settings == null) {
    //         settings = Stripe_Settings__c.getInstance();
    //     }

    //     return settings;
    // }

    // public static string getPublicStripeKey() {
    //     return getStripeSettings().Public_Key__c;
    // }

    // public static string getPrivateStripeKey() {
    //     return getStripeSettings().Secret_Key__c;
    // }
}