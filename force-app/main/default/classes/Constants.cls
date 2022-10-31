public class Constants {

    //Conference Scheduling Constants
    public static Map<String, String> monthToNum = new Map<String,String>{
        'Jan' => '01',
        'Feb' => '02',
        'Mar' => '03',
        'Apr' => '04',
        'May' => '05',
        'Jun' => '06',
        'Jul' => '07',
        'Aug' => '08',
        'Sep' => '09',
        'Oct' => '10',
        'Nov' => '11',
        'Dec' => '12'};
    public static Integer blockLength = (Integer)getBookingSettings().Minimum_Conference_Room_Reservation__c; //The smallest block that can be reserved, in minutes. 
    public static Integer maxReservationLength = (Integer)getBookingSettings().Maximum_Conference_Room_Reservation__c; //The largest block that can be reserved, in minutes.



    //Payment Constants
    public static Integer includedGroupSize = 4;
    public static Integer groupBasePrice = 175;
    public static Integer groupAddOnPrice = 25;

    public static Integer dayPassBasePrice = 15;
    public static Integer individualBasePrice = 49;
    public static Integer studentBasePrice = 29;
    public static Integer virtualTenantBasePrice = 100;
    
    public static String groupPlanId = 'price_0KkgrT25GAigWUtfjMKEDrc1';
    public static String dayPassPrice = '$15 (One-Time)';
    public static String individualPrice = '$49 (Monthly)';
    public static String studentPrice = '$29 (Per Month)';
    public static String virtualTenantPrice = '$100 (Per Month)';

    //Conference room price constants
    public static Decimal podcastBoothMemberPrice = (Decimal)getBookingSettings().Podcast_Booth_Member_Price__c;
    public static Decimal podcastBoothNonMemberPrice = (Decimal)getBookingSettings().Podcast_Booth_Non_Member_Price__c;
    public static Decimal conferenceRoomMemberPrice = (Decimal)getBookingSettings().Conference_Room_Member_Price__c;
    public static Decimal conferenceRoomNonMemberPrice = (Decimal)getBookingSettings().Conference_Room_Non_Member_Price__c;

    //Not a constant, but it seems easiest to handle some Room Booking work here. 
    static Cowork_Room_Booking__c bookingSettings;

    public static Cowork_Room_Booking__c getBookingSettings() {
        if (bookingSettings == null) {
            bookingSettings = Cowork_Room_Booking__c.getInstance();
        }

        return bookingSettings;
    }
}