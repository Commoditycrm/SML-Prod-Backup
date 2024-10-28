global class RedesignNL_patchclass implements Database.Batchable<sObject> {
    Public String query ;
    
     public RedesignNL_patchclass(String query) {
        this.query = query;      
    }
    
    public RedesignNL_patchclass() {   
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(String.isBlank(query)){
           //this.query = 'select Id,End_Time__c, Power_Reset_Time__c,Asset__r.CreatedDate,Asset__r.Battery_Replaced_Date__c, CreatedDate,  Power_Reset_Occurred__c, rsrp__c, rsrq__c, rssi__c, estBattPct__c, Est_Remaining_Battery__c from Asset_History_custom__c where Est_Remaining_Battery__c =null AND  estBattPct__c != null';
           //this.query = 'SELECT Id, Asset__c FROM Asset_History_custom__c WHERE Location__c = \'Kacey Weaver\'';
           this.query = 'Select Id, Name, Max_LKL_End_time__c from Asset where Deleted_AHC__c = true';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Asset> Scope) {
       /*Set<Id> astIdSet = new Set<Id>();
        for(Asset_History_custom__c ahc : astHistoryList){
            astIdSet.add(ahc.Asset__c);
    }
        List<Asset> astList = [SELECT Id, Deleted_AHC__C from Asset WHERE Id in :astIdSet];
        for(Asset ast : astList){
            ast.Deleted_AHC__c = true;
        }
         List<Database.SaveResult> UpdateResult = Database.update(astList, false);
         List<Database.DeleteResult> DeleteResult = Database.Delete(astHistoryList, false);*/
        String astId = Scope[0].Id;
        Asset_History_custom__c ahc = [Select Id, Still_in_this_Location__c, End_Time__c from Asset_History_custom__c WHERE Asset__c = :astId order by Start_Time__c desc LIMIT 1];
        API_Response_Childs__c apc = [Select Id, Name, status__c from API_Response_Childs__c WHERE Asset__c = :astId and Recordtype.DeveloperName = 'Location' order by CreatedDate desc LIMIT 1];
        ahc.Still_in_this_Location__c = true;
        ahc.End_Time__c = ahc.End_Time__c < Scope[0].Max_LKL_End_time__c ? Scope[0].Max_LKL_End_time__c : ahc.End_Time__c;
        Database.SaveResult UpdateAhcResult = Database.update(ahc, false);
        
        apc.Status__c = 'New';
        Database.SaveResult UpdateApcResult = Database.update(apc, false);
        
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    /*
     * RedesignNL_patchclass batch = new RedesignNL_patchclass();
Database.executeBatch(batch, 1); // Set batch size to 1
     * */
}