@isTest
public class StripeMembershipChargeTests {
    static Contact c;
    static Membership__c membership;

    static void setup() {
        StripePaymentServiceMock mock = new StripePaymentServiceMock();
        StripePaymentService.instance = mock;
        
        GoogleCalendarServiceMock gCalMock = new GoogleCalendarServiceMock();
        GoogleCalendarService.instance = gCalMock;

        insert new Cowork_Room_Booking__c (
            Podcast_Booth_Member_Price__c = 10,
            Podcast_Booth_Non_Member_Price__c = 10,
            Conference_Room_Member_Price__c = 10,
            Conference_Room_Non_Member_Price__c = 10
        );


        c = TestDataFactory.createContact();
        c.Cowork_Stripe_Customer_Id__c = 'CUSTOMER_ID';
        insert c;

        membership = new Membership__c(
            Contact__c = c.Id,
            Type__c = 'Individual',
            Stripe_Subscription_Id__c = 'SUBSCRIPTION_ID'
        );
        insert membership;

        Space__c space = new Space__c(
            Name='Test Coverage',
            Cowork_Reservable__c = true,
            Reservation_Room_Type__c = 'Conference Room'
        );
        insert space;

        Date d = Date.today().addDays(-1);

        Reservation__c res = new Reservation__c(
            Contact__c = c.Id,
            Membership__c = membership.Id,
            Space__c = space.Id,
            Start__c = DateTime.newInstance(d.year(),d.month(),d.day(), 6,0,0),
            End__c = DateTime.newInstance(d.year(),d.month(),d.day(), 8,0,0),
            Status__c = 'Active'
        );
        insert res;
    }

    @isTest
    public static void testSetup() {
        setup();
    }

    @isTest
    public static void testScheduleAndBatch() {
        setup();
        String CRON_EXP = '0 0 0 15 3 ? *';
        
        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest', CRON_EXP, new MembershipChargeSchedulable());
        Test.stopTest();

    }
}