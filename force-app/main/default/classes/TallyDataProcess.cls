public class TallyDataProcess {
    @auraenabled(cacheable=true)
    public Static String GetTallyData( Id recordId) {
        System.debug('recordId'+recordId);
        system.debug('Insert');
        TallyBatch oppAssessmentUpdate = new TallyBatch(recordId);
        Id batchjobId = database.executeBatch(oppAssessmentUpdate,200);
        AsyncApexJob aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors
                            FROM AsyncApexJob WHERE ID =: batchJobId ];
        System.debug('Job Id: ' + batchJobid + ' Status: ' + aaj.Status);
        return batchJobId;
    }
    
}