/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-08-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class EC_RevenueRecognitionController {
    
    /**
    * @description 
    * @author ChangeMeIn@UserSettingsUnder.SFDoc | 02-08-2025 
    * @param opportunityId 
    * @return String 
    **/
    @AuraEnabled(cacheable=true)
    public static String milestoneCalculation(Id opportunityId) {
        try{
            EC_RevenueRecognitionMilestoneWrapper.EC_OpportunityData oppDataWrapObj= new EC_RevenueRecognitionMilestoneWrapper.EC_OpportunityData();
       
            Map<String, EC_Invoice__c> nameToInvoiceRecMap = new Map<String, EC_Invoice__c>();

            Opportunity opportunityObj = [SELECT Id, Name, CloseDate, Amount, EC_Invoiced_Amount__c FROM Opportunity WHERE Id =:opportunityId WITH SECURITY_ENFORCED]; 

            if( (opportunityObj.Amount == null ) || (opportunityObj.Amount != null && opportunityObj.Amount <= 0)){
                return JSON.serialize(oppDataWrapObj);
            }

            oppDataWrapObj.closedDate = opportunityObj.CloseDate;
            oppDataWrapObj.invoicedAmount = opportunityObj.EC_Invoiced_Amount__c;
            oppDataWrapObj.recogoRecognizedAmount = opportunityObj.Amount;

            for(EC_Invoice__c invoiceObj : [SELECT Id, Name, EC_Invoice_Date__c, EC_Opportunity__c, EC_Status__c FROM EC_Invoice__c WHERE EC_Opportunity__c =:opportunityId WITH SECURITY_ENFORCED]){
                nameToInvoiceRecMap.put(invoiceObj.Name,invoiceObj);
            } 

            // 40% upon product delivery - start
            Decimal totalAmount = opportunityObj.Amount;
            Decimal initialAmount = totalAmount * 0.4; 

            EC_RevenueRecognitionMilestoneWrapper.EC_RevenueRecognitionData initialRevuneRecognition = new EC_RevenueRecognitionMilestoneWrapper.EC_RevenueRecognitionData(EC_Constants.deliveryMilestone, opportunityObj.CloseDate, initialAmount);

            initialRevuneRecognition.invoiceStatus = nameToInvoiceRecMap.containsKey(EC_Constants.deliveryMilestone) ? nameToInvoiceRecMap.get(EC_Constants.deliveryMilestone).EC_Status__c : EC_Constants.notInvoiced;

            oppDataWrapObj.revRecMilestonesList.add(initialRevuneRecognition);
            // 40% upon product delivery - end

            // 60% over subscription period - start
            Decimal subscriptionAmount = totalAmount * 0.6; 
            Date subscriptionStart = opportunityObj.CloseDate;
            Date subscriptionEnd = subscriptionStart.addMonths(12);  //Subscription for 12 months
            for (Integer month = 1; month <= 12; month++) {
                Date milestoneDate = subscriptionStart.addMonths(month);

                EC_RevenueRecognitionMilestoneWrapper.EC_RevenueRecognitionData subscribedRecognition = new EC_RevenueRecognitionMilestoneWrapper.EC_RevenueRecognitionData(EC_Constants.subscriptionMilestone + month, milestoneDate, subscriptionAmount / 12);

                subscribedRecognition.invoiceStatus = nameToInvoiceRecMap.containsKey(EC_Constants.subscriptionMilestone + month) ? nameToInvoiceRecMap.get(EC_Constants.subscriptionMilestone + month).EC_Status__c : EC_Constants.notInvoiced;

                oppDataWrapObj.revRecMilestonesList.add(subscribedRecognition);
            }        
            // 60% over subscription period - end
            
            oppDataWrapObj.showRevenueRecognition = true;
            return JSON.serialize(oppDataWrapObj);
        }catch(Exception ex){
            throw new  AuraHandledException(ex.getMessage());
        }
    }
}