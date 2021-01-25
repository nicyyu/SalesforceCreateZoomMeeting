@isTest
private class CreateClassSessionZoomMeetingTest {
    @isTest static void testCreateZoomMeeting(){
        
        Program__c testProgram = new Program__c();
        testProgram.Name = 'test program';
        insert testProgram;

        Dance_Studio__c testStudio = new Dance_Studio__c();
        testStudio.Name = '中贸广场店';
        insert testStudio;

        Class_Room__c testClassRoom = new Class_Room__c();
        testClassRoom.Name = 'ZM01';
        testClassRoom.Dance_Studio__c = testStudio.Id;
        testClassRoom.Zoom_API_Key__c = 'SRFRjFUMQO6OVkR5bhUevQ';
        testClassRoom.Zoom_API_Secret__c = 'wCDMaPhrtbx7JsmWVnQexyquZdura0SkS0a7';
        insert testClassRoom;
        
        Class__c testClass = new Class__c();
        testClass.Name = 'testClass';
        testClass.Program__c = testProgram.Id;
        insert testClass;

        Class_Session__c testClassSession = new Class_Session__c();
        testClassSession.Class__c = testClass.id;
        testClassSession.Sesssion_Duration__c = 30;
        testClassSession.Session_Start_DateTime__c = System.now();
        testClassSession.Class_Room__c = testClassRoom.Id;
        insert testClassSession;

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
            WHERE Id =: testClassSession.Id
        ];

        List<List<Class_Session__c>> ClassSessionListFinal = new List<List<Class_Session__c>>();
        ClassSessionListFinal.add(ClassSessions);

        Test.startTest();
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseZoomMeetingCreation());
        // Start to call the class
        CreateClassSessionZoomMeeting.CreateClassSessionZoomMeeting(ClassSessionListFinal);

		Test.stopTest();

    }
}
