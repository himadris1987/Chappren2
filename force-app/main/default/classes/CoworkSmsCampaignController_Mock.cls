@isTest
global class CoworkSmsCampaignController_Mock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{}');
        response.setStatusCode(200);
        return response; 
    }
}