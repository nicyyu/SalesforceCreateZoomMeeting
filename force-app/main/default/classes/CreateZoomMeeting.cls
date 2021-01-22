public with sharing class CreateZoomMeeting {

    public static List<id> idList = new List<id>();
    public static String accessToken;

    @InvocableMethod
    public static List<List<VirtualMeeting__c>> CreateZoomMeeting(List<List<Class_Session__c>> ClassSessionList) {
        List<List<VirtualMeeting__c>> VirtualMeetingListFinal = new List<List<VirtualMeeting__c>>();
        for(Class_Session__c cs : ClassSessionList[0]){
            idList.add(cs.id);
        }
        accessToken = createToken();
        System.debug('newAccessToken: ' + accessToken);
        List<VirtualMeeting__c> MeetingList = sendRequest(idList);
        VirtualMeetingListFinal.add(MeetingList);
        return VirtualMeetingListFinal;
    }

    public static List<VirtualMeeting__c> sendRequest(List<id> idList){
        List<VirtualMeeting__c> VirtualMeetingListTemp = new List<VirtualMeeting__c>();
		System.debug('sendRequest 开始');
        System.debug('accessToken: ' + accessToken);
        List<Class_Session__c> ClassSessions = [
            Select 
                Id, 
                Name, 
                Session_Start_DateTime__c, 
                Sesssion_Duration__c 
            FROM Class_Session__c 
            Where Id IN :idList
        ];
        for(Class_Session__c cs : ClassSessions){
            VirtualMeeting__c VirtualMeetingTemp = new VirtualMeeting__c();
            String formatedDt = cs.Session_Start_DateTime__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            String ReqBody = '{' + '"topic": "virtual meeting",' + '"type": "2",' + '"start_time": "' + formatedDt + '",' + '"duration": "30"}';
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://api.zoom.us/v2/users/me/meetings');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setMethod('POST');
            req.setBody(ReqBody);
            Http http = new Http();
            HttpResponse res = http.send(req);
            String body = res.getBody();
            //System.debug(body);
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
            VirtualMeetingTemp.ClassSession__c = cs.id;
            VirtualMeetingTemp.MeetingId__c = id;
            VirtualMeetingTemp.MeetingLink__c = join_url;
            VirtualMeetingTemp.MeetingPW__c = password;
            VirtualMeetingListTemp.add(VirtualMeetingTemp);
        }
        return VirtualMeetingListTemp;
    }

    Public Static String createToken() {

        String alg = 'HS256';
        String typ = 'JWT'; 
        String iss = 'SRFRjFUMQO6OVkR5bhUevQ';
        String exp = String.valueOf(System.currentTimeMillis() + 60 * 60 * 1000);
        System.debug('exp ' + exp);
        String headerJson = JSON.serialize(new Header(alg,typ));
        String bodyJson =  JSON.serialize(new Body(iss,exp));

        String token = EncodingUtil.base64Encode(Blob.valueOf(headerJson))
                + '.' + EncodingUtil.base64Encode(Blob.valueOf(bodyJson));
        String signature = EncodingUtil.base64Encode(crypto.generateMac(
                'HMACSHA256',
                Blob.valueOf(token),
                Blob.valueOf('wCDMaPhrtbx7JsmWVnQexyquZdura0SkS0a7')
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