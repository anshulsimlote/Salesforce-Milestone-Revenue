/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-08-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class EC_CreateOpportuniyInvoiceBatch implements Database.Batchable<sobject>, Schedulable {
    
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 02-08-2025 
    * @param bc 
    * @return Database.Querylocator 
    **/
    public Database.Querylocator start (Database.BatchableContext bc)
    {
        String query = 'SELECT Id, Amount, StageName, EC_Invoiced_Amount__c, (SELECT Id, Name, EC_Invoice_Date__c, EC_Opportunity__c FROM Invoices__r ORDER BY EC_Invoice_Date__c DESC LIMIT 1) FROM Opportunity WHERE StageName = \'Closed Won\' AND EC_Remaning_Amount__c > 0 WITH SECURITY_ENFORCED';
        return Database.getQueryLocator(query);
    }
    
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 02-08-2025 
    * @param bc 
    * @param opportunityList 
    **/
    public void execute(Database.BatchableContext bc, List<Opportunity> opportunityList){
        try{
            List<EC_Invoice__c> invoiceList = new List<EC_Invoice__c>();
            for(Opportunity oppObj : opportunityList){
                if(oppObj.Invoices__r.isEmpty()){
                    continue;
                }else if(oppObj.Invoices__r[0].EC_Invoice_Date__c.addMonths(1) > Date.today()){
                    continue;                
                }
                String invoiceName = oppObj.Invoices__r[0].Name;
                String tempInvoiceNameCount;
                if (invoiceName.contains(EC_Constants.subscriptionMilestone)) {
                    tempInvoiceNameCount = String.valueOf(Integer.valueOf(invoiceName.replace(EC_Constants.subscriptionMilestone, '')) + 1 );
                } else {
                    tempInvoiceNameCount = '1'; 
                }
                EC_Invoice__c tempInvoice = new EC_Invoice__c();
                tempInvoice.Name = EC_Constants.subscriptionMilestone+tempInvoiceNameCount;
                tempInvoice.EC_Amount__c = (oppObj.Amount * 0.6) / 12;
                tempInvoice.EC_Invoice_Date__c = Date.today();
                tempInvoice.EC_Opportunity__c = oppObj.Id;
                tempInvoice.EC_Status__c = EC_Constants.openStatus;
                invoiceList.add(tempInvoice);
            }
            insert invoiceList;
        }catch(Exception ex){
            throw new EC_Exception(ex.getMessage());
        }
    }
    
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 02-08-2025 
    * @param bc 
    **/
    public void finish (Database.BatchableContext bc)
    {

    }

    
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 02-08-2025 
    * @param sc 
    **/
    public void execute(SchedulableContext sc){
        EC_CreateOpportuniyInvoiceBatch batchObj = new EC_CreateOpportuniyInvoiceBatch();
        database.executebatch(batchObj, 200);
    }  

}