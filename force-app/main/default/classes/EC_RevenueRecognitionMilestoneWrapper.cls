/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-09-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class EC_RevenueRecognitionMilestoneWrapper {

    public class EC_OpportunityData {
        @AuraEnabled public Date closedDate;
        @AuraEnabled public Decimal recogoRecognizedAmount = 0;
        @AuraEnabled public Decimal invoicedAmount = 0;
        @AuraEnabled public Boolean showRevenueRecognition = false;
        @AuraEnabled public List<EC_RevenueRecognitionData> revRecMilestonesList = new List<EC_RevenueRecognitionData>();
    }

    public class EC_RevenueRecognitionData {
        @AuraEnabled public String key;
        @AuraEnabled public String name;
        @AuraEnabled public Date milestoneDate;
        @AuraEnabled public Decimal recognizedRevenue;
        @AuraEnabled public String invoiceStatus;
        @AuraEnabled public List<EC_RevenueRecognitionItemData> revRecMilestonesItemList = new List<EC_RevenueRecognitionItemData>();

        public EC_RevenueRecognitionData(String name, Date milestoneDate, Decimal recognizedRevenue) {
            this.name = name;
            this.milestoneDate = milestoneDate;
            this.recognizedRevenue = recognizedRevenue;
            this.key = name;
        }
    }

    public class EC_RevenueRecognitionItemData {
        @AuraEnabled public String name;
        @AuraEnabled public Decimal recognizedRevenue;
        @AuraEnabled public Date milestoneDate;
        @AuraEnabled public String invoiceStatus;
    }
}