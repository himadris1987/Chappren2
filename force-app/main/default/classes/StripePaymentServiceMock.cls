@isTest
public class StripePaymentServiceMock extends StripePaymentService{

    public boolean customerFail = false;
    public boolean subscriptionFail = false;
    public boolean chargeFail = false;

        public override String createCustomer(String department, String cardToken, String email, String name, String phone, Id contactId) {
            if (customerFail) {
                return 'error:404';
            }

            return 'CUSTOMER_ID';
        }
        
        public override String createSubscription(String department, String customerId, String paymentMethodId, String planId,  String couponCode, String market) {
            if (subscriptionFail) {
                return 'error:404';
            }

            return 'SUBSCRIPTION_ID';
        }

        public override void cancelSubscription(String department, String subscriptionId) {
            return;
        }

        public override String createSubscription(String department, String customerId, String sourceId, String productId, String discountCode, Integer customerCount, String market) {
            if (subscriptionFail) {
                return 'error:404';
            }

            return 'SUBSCRIPTION_ID';
        }

        public override String chargeCustomer(String department, String customerId, String sourceId, Decimal amount, String description) {
            if (chargeFail) {
                return 'error:404';
            }
            
            return 'CHARGE_ID';
        }

        
        public override String createSource(String department, String token) {
            return 'SOURCE_ID';
        }
        
        public override void attachSource(String department, String customerId, String sourceId) {
            return;
        }

        public override void createDiscount(String department, Discount__c discount) {
            return;
        }
        
        public override void deleteDiscount(String department, Discount__c discount) {
            return;
        }


}