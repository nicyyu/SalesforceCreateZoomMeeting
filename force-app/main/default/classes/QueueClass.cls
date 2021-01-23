public class QueueClass implements Queueable, Database.AllowsCallouts {
    public static String accessToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdWQiOm51bGwsImlzcyI6IlNSRlJqRlVNUU82T1ZrUjViaFVldlEiLCJleHAiOjE2MTEzNjMzMzIsImlhdCI6MTYxMTM1NzkzMn0.Vuy6l1Rz4DFFSjjpzlKLPzbd-7INXHMFuOykumNkn7E';
    public void execute(QueueableContext context) {
        // awesome code here
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.zoom.us/v2/users/me/');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        String body = res.getBody();
        System.debug('body: ' + body);
        
        System.debug('QueueClass runs!');
        SystemRunLog__c systemLog = new SystemRunLog__c();
        systemLog.Runtime__c = system.now();
        systemLog.Note__c = 'QueueClass runs!';
        insert systemLog;
        
    }
}
