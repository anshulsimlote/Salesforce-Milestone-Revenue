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
            EC_RevenueRecognitionMilestoneWrapper.EC_OpportunityData oppDataWrapObj = new EC_RevenueRecognitionMilestoneWrapper.EC_OpportunityData();
            List<EC_RevenueRecognitionMilestoneWrapper.EC_RevenueRecognitionItemData> subscribedRevRecMilestonesItemList = new List<EC_RevenueRecognitionMilestoneWrapper.EC_RevenueRecognitionItemData>();
            Map<String, EC_Invoice__c> nameToInvoiceRecMap = new Map<String, EC_Invoice__c>();
            Map<String, Decimal> productRevenueMap = new Map<String, Decimal>();
            Map<String, Decimal> subscribedProductRevenueMap = new Map<String, Decimal>();
            
            Opportunity opportunityObj = [
                SELECT Id, Name, CloseDate, Amount, EC_Invoiced_Amount__c, 
                       (SELECT Id, Name, Product2.Name, TotalPrice 
                        FROM OpportunityLineItems) 
                FROM Opportunity 
                WHERE Id = :opportunityId 
                WITH SECURITY_ENFORCED
            ]; 
            if (opportunityObj.Amount == null || opportunityObj.Amount <= 0) {
                return JSON.serialize(oppDataWrapObj);
            }
            
            oppDataWrapObj.closedDate = opportunityObj.CloseDate;
            oppDataWrapObj.invoicedAmount = opportunityObj.EC_Invoiced_Amount__c;
            oppDataWrapObj.recogoRecognizedAmount = opportunityObj.Amount;
            
            for (EC_Invoice__c invoiceObj : [
                SELECT Id, Name, EC_Invoice_Date__c, EC_Opportunity__c, EC_Status__c 
                FROM EC_Invoice__c 
                WHERE EC_Opportunity__c = :opportunityId 
                WITH SECURITY_ENFORCED
            ]) {
                nameToInvoiceRecMap.put(invoiceObj.Name, invoiceObj);
            }

            Decimal totalAmount = opportunityObj.Amount;
            Decimal initialAmount = totalAmount * 0.4; 
            Decimal subscriptionAmount = totalAmount * 0.6; 

            EC_RevenueRecognitionMilestoneWrapper.EC_RevenueRecognitionData initialRevenueRecognition = new EC_RevenueRecognitionMilestoneWrapper.EC_RevenueRecognitionData(
                EC_Constants.deliveryMilestone, 
                opportunityObj.CloseDate, 
                initialAmount
            );

            initialRevenueRecognition.invoiceStatus = nameToInvoiceRecMap.containsKey(EC_Constants.deliveryMilestone) ? nameToInvoiceRecMap.get(EC_Constants.deliveryMilestone).EC_Status__c : EC_Constants.notInvoiced;

            for (OpportunityLineItem oppLineItem : opportunityObj.OpportunityLineItems) {
                String productName = oppLineItem.Product2.Name;

                Decimal currentProductRevenue = productRevenueMap.containsKey(productName) ? productRevenueMap.get(productName) : 0;
                productRevenueMap.put(productName, currentProductRevenue + (oppLineItem.TotalPrice * 0.4));

                Decimal currentSubscriptionRevenue = subscribedProductRevenueMap.containsKey(productName) ? subscribedProductRevenueMap.get(productName) : 0;
                subscribedProductRevenueMap.put(productName, currentSubscriptionRevenue + ((oppLineItem.TotalPrice * 0.6) / 12));
            }

            for (String productName : productRevenueMap.keySet()) {
                EC_RevenueRecognitionMilestoneWrapper.EC_RevenueRecognitionItemData revenueItem = new EC_RevenueRecognitionMilestoneWrapper.EC_RevenueRecognitionItemData();
                revenueItem.productName = productName;
                revenueItem.TotalPrice = productRevenueMap.get(productName);
                initialRevenueRecognition.revRecMilestonesItemList.add(revenueItem);
            }

            oppDataWrapObj.revRecMilestonesList.add(initialRevenueRecognition);

            for (String productName : subscribedProductRevenueMap.keySet()) {
                EC_RevenueRecognitionMilestoneWrapper.EC_RevenueRecognitionItemData revenueItem = new EC_RevenueRecognitionMilestoneWrapper.EC_RevenueRecognitionItemData();
                revenueItem.productName = productName;
                revenueItem.TotalPrice = subscribedProductRevenueMap.get(productName);
                subscribedRevRecMilestonesItemList.add(revenueItem);
            }

            Date subscriptionStart = opportunityObj.CloseDate;
            Decimal monthlyAmount = subscriptionAmount / 12;

            for (Integer month = 1; month <= 12; month++) {
                Date milestoneDate = subscriptionStart.addMonths(month);

                EC_RevenueRecognitionMilestoneWrapper.EC_RevenueRecognitionData subscriptionRecognition = new EC_RevenueRecognitionMilestoneWrapper.EC_RevenueRecognitionData(
                    EC_Constants.subscriptionMilestone + month, 
                    milestoneDate, 
                    monthlyAmount
                );

                subscriptionRecognition.invoiceStatus = nameToInvoiceRecMap.containsKey(EC_Constants.subscriptionMilestone + month) 
                    ? nameToInvoiceRecMap.get(EC_Constants.subscriptionMilestone + month).EC_Status__c 
                    : EC_Constants.notInvoiced;

                subscriptionRecognition.revRecMilestonesItemList.addAll(subscribedRevRecMilestonesItemList);
                oppDataWrapObj.revRecMilestonesList.add(subscriptionRecognition);
            }

            oppDataWrapObj.showRevenueRecognition = true;
            return JSON.serialize(oppDataWrapObj);


        }catch(Exception ex){
            throw new  AuraHandledException(ex.getMessage());
        }
    }
}