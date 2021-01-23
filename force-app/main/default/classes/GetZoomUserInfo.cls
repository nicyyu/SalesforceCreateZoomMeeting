public with sharing class GetZoomUserInfo {
    public static List<id> idList = new List<id>();
    @InvocableMethod
    public static void GetZoomUserInfo(List<List<Class_Session__c>> ClassSessionList) {
        for(Class_Session__c cs : ClassSessionList[0]){
            idList.add(cs.id);
        }
        System.debug('QueueClass prepare to start!');
        QueueClass updateJob = new QueueClass();
        ID jobID = System.enqueueJob(updateJob);
        System.debug('jobID: ' + jobID);
        AsyncApexJob[] jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob WHERE Id=:jobID];
        System.debug('jobInfo: ' + jobInfo);
    }
}