@isTest
public class ReservationTriggerTests {
    static Contact cont;
    static Membership__c membership;
    static Reservation__c res;

    static void setup() {
        StripePaymentServiceMock mock = new StripePaymentServiceMock();
        StripePaymentService.instance = mock;
        
        GoogleCalendarServiceMock gCalMock = new GoogleCalendarServiceMock();
        GoogleCalendarService.instance = gCalMock;
        
        cont = new Contact(
            LastName = 'Test',
            FirstName = 'Unit',
            Email = 'test@test.com'
        );
        insert cont;

        membership = new Membership__c(
            Contact__c = cont.Id
        );
        insert membership;
    }

    @isTest
    public static void testSplitReservation() {
        setup();

        res = new Reservation__c(
            Start__c = System.now(),
            End__c = System.now().addHours(24),
            Membership__c = membership.Id,
            Contact__c = cont.Id
        );
        
        Test.startTest();
        insert res;
        Test.stopTest();

        List<Reservation__c> uploaded = [SELECT Id FROM Reservation__c];

        System.assertEquals(2, uploaded.size());
    }
}