public with sharing class CreateClassSessionZoomMeeting {

    public static List<id> idList = new List<id>();
    public static String accessToken = '';

    @InvocableMethod
    public static List<List<Class_Session__c>> CreateClassSessionZoomMeeting(List<List<Class_Session__c>> ClassSessionList) {
        System.debug('ClassSessionList: ' + ClassSessionList);
        List<List<Class_Session__c>> ClassSessionListFinal = new List<List<Class_Session__c>>();
        for(Class_Session__c cs : ClassSessionList[0]){
            idList.add(cs.id);
        }
        List<Class_Session__c> ClassSessionListTemp = sendRequest(idList);
        if(ClassSessionListTemp != null && !ClassSessionListTemp.isEmpty()){
            ClassSessionListFinal.add(ClassSessionListTemp);
        }
        return ClassSessionListFinal;
    }

    public static List<Class_Session__c> sendRequest(List<id> idList){
        List<Class_Session__c> ClassSessionListTemp = new List<Class_Session__c>();
		System.debug('sendRequest 开始');
        List<Class_Session__c> ClassSessions = [
            SELECT
                Id, 
                Name,
                Class_Name__c,
                Session_Start_DateTime__c,
                Day_Of_Week__c,
                Sesssion_Duration__c,
                Zoom_Meeting_Password__c,
                Zoom_Meeting_id__c,
                Zoom_Meeting_Url__c,
                Class_Room__r.Id,
                Class_Room__r.Name,
                Class_Room__r.Zoom_API_Key__c,
                Class_Room__r.Zoom_API_Secret__c
            FROM Class_Session__c 
            WHERE Id IN :idList
        ];
        System.debug('ClassSessions: ' + ClassSessions);
        if(ClassSessions != null && !ClassSessions.isEmpty()) {
            for(Class_Session__c cs : ClassSessions){
                System.debug('cs: ' + cs);
                Class_Session__c ClassSessionTemp = new Class_Session__c();
                String formatedDt = cs.Session_Start_DateTime__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                String topic = cs.Class_Name__c + ' - ' + cs.Session_Start_DateTime__c + ' - ' + '周' + cs.Day_Of_Week__c;
                String duration = String.valueOf(double.valueOf(cs.Sesssion_Duration__c) * 60);
                String ReqBody = '{' + '"topic":"' + topic + '",' + '"type": "2",' + '"start_time": "' + formatedDt + '",' + '"duration": "' + '30' + '"}';
                String apiKey = cs.Class_Room__r.Zoom_API_Key__c;
                String apiSecret = cs.Class_Room__r.Zoom_API_Secret__c;

                accessToken = createToken(apiKey, apiSecret);
                System.debug('accessToken: ' + accessToken);
                
                HttpResponse res = createMeetingFromExternalService(accessToken, ReqBody);
                System.debug('res: ' + res);

                Integer statusCode = res.getStatusCode();
                System.debug('statusCode: ' + statusCode);
                
                String body = res.getBody();
                System.debug('body: ' + body);
                
                if(statusCode == 201) {
                    JSONParser parser = JSON.createParser(body);
                    String id = '';
                    String join_url = '';
                    String password = '';
                    while (parser.nextToken() != null) {
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'id')) {
                            // Get the value.
                            parser.nextToken();
                            id = parser.getText();
                        }
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'join_url')) {
                            // Get the value.
                            parser.nextToken();
                            join_url = parser.getText();
                        }
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'password')) {
                            // Get the value.
                            parser.nextToken();
                            password = parser.getText();
                        }
                    }
                    DateTime dT = System.now();
                    Date updateDate = date.newinstance(dT.year(), dT.month(), dT.day());
                    String left3Id = id.left(3);
                    String mid4Id = id.mid(3,4);
                    String right4Id = id.right(4);
                    String formatedId = left3Id + ' ' + mid4Id + ' ' + right4Id;
                    cs.Zoom_Meeting_Update_Time__c = updateDate;
                    cs.Zoom_Meeting_id__c = formatedId;
                    cs.Zoom_Meeting_Url__c = join_url;
                    cs.Zoom_Meeting_Password__c = password;
                    ClassSessionListTemp.add(cs);
                }
            }
        }
        return ClassSessionListTemp;
    }

    public static HttpResponse createMeetingFromExternalService(String accessToken, String ReqBody){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.zoom.us/v2/users/me/meetings');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setMethod('POST');
        req.setBody(ReqBody);
        Http http = new Http();
        HttpResponse res = http.send(req);
        return res;
    }

    public static String createToken(String apiKey, String apiSecret) {

        String alg = 'HS256';
        String typ = 'JWT'; 
        String iss = apiKey;
        String exp = String.valueOf(System.currentTimeMillis() + 60 * 60 * 1000);
        String headerJson = JSON.serialize(new Header(alg,typ));
        String bodyJson =  JSON.serialize(new Body(iss,exp));

        String token = EncodingUtil.base64Encode(Blob.valueOf(headerJson))
                + '.' + EncodingUtil.base64Encode(Blob.valueOf(bodyJson));
        String signature = EncodingUtil.base64Encode(crypto.generateMac(
                'HMACSHA256',
                Blob.valueOf(token),
                Blob.valueOf(apiSecret)
                ));
        token += '.' + signature;

        return token;
    }

    private class Header {
        String alg;
        String typ;
        Header(String alg,String typ) {
            this.alg = alg;
            this.typ = typ;
        }
    }

    private class Body {
        String iss;
        String exp;
        Body(String iss, String exp) {
            this.iss = iss;
            this.exp = exp;
        }
    }
}
