public class GoogleCalendarServiceCalloutMock implements HttpCalloutMock{
    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(response);
        res.setStatusCode(200);
        return res;
    }

    static String response = '{"items": [{"summary": "TestsPass", "start": {"dateTime": "2019-09-16T12:00:00-07:00"}, "end": {"dateTime": "2019-09-16T13:00:00-07:00"}}, {"summary": "Deployment", "start": {"dateTime": "2019-09-16T16:00:00-07:00"}, "end": {"dateTime": "2019-09-16T17:00:00-07:00"}}]}';
}