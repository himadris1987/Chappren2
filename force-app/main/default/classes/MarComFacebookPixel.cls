public class MarComFacebookPixel {
    
    
    public static HttpResponse postFacebookPixel(String accessToken, String data) {
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        String body = 'access_token=' + EncodingUtil.urlEncode(accessToken, 'UTF-8');
        body += '&data=' + EncodingUtil.urlEncode(data, 'UTF-8');
        req.setEndpoint('https://graph.facebook.com/v10.0/3024182424388533/events');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(body);
        res = http.send(req);
        System.debug(res);
        System.debug(res.getBody());
        return res;
    }
   
    public static HTTPResponse WFTRegistrationVisit(PageReference currentPage, String classCost) {
       String accessToken = 'EAAGFvXkqqxUBAB9wceZAXyl0n7BXXT826UMpI3H4Xe8iAqFLcZAuzJMfV4BqJEVX04SVoZCw9ZCSgP6pvUVnl3r1RLAGSGosNaR7uCX4hRWu7BZAjhaLiSPH5z0Xu78u0nvZAmK52XPQQXuZAc2GUyDHhE9FCgnAuaE07PnwdXnP06ZBGc2XoZBe3';
       String clientIpAddress = getIpAddress(currentPage);
       String clientUserAgent = currentPage.getHeaders().get('User-Agent');
       String pageUrl = currentPage.getHeaders().get('Host') + currentPage.getUrl();
       Datetime dt = Datetime.now();
       Data dataObject = new Data();
      
       dataObject.event_name = 'InitiateCheckout';
       dataObject.event_time = dt.getTime()/1000;
       dataObject.event_source_url = pageUrl;
       dataObject.user_data.client_ip_address = clientIpAddress;
       dataObject.user_data.client_user_agent = clientUserAgent;
       dataObject.custom_data.value = classCost;
       dataObject.custom_data.event_url = pageUrl;

       String data = '['+ JSON.serialize(dataObject) + ']';
       data = data.replace('xcurrency', 'currency');

       System.debug(data);
       HTTPResponse res = postFacebookPixel(accessToken,data);
       return res;
    }

    private class data {
        String event_name;
        Long event_time;
        String event_source_url;
        String action_source = 'website';
        UserData user_data = new UserData();
        CustomData custom_data = new CustomData();
    }

    private class UserData {
        String client_ip_address;
        String client_user_agent;
    }

    private class CustomData {
        String xcurrency = 'USD';
        String value;
        String event_url;
    }

    
    public static String getIpAddress(PageReference currentPage) {
        
        // True-Client-IP has the value when the request is coming via the caching integration.
        String ipAddress = currentPage.getHeaders().get('True-Client-IP');
        
        // X-Salesforce-SIP has the value when no caching integration or via secure URL.
        if (String.isBlank(ipAddress)) {
            ipAddress = currentPage.getHeaders().get('X-Salesforce-SIP');
        } 
        
        // get IP address when no caching (sandbox, dev, secure urls)        
        if (String.isBlank(ipAddress)) {
            ipAddress = currentPage.getHeaders().get('X-Forwarded-For');
        }

        return ipAddress;
    }
}