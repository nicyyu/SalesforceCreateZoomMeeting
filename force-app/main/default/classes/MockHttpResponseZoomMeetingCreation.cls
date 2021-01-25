@isTest
global class MockHttpResponseZoomMeetingCreation implements HttpCalloutMock {

  private static String resBodyJSON = '{"id":"74159012357", "join_url":"https://us04web.zoom.us/j/74159012357?pwd=KytoOWcvaWdjcWRMRHF3bDVzQ3Vsdz09", "password":"550055"}';

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('https://api.zoom.us/v2/users/me/meetings', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(resBodyJSON);
        res.setStatusCode(201);
        return res;
    }
}
