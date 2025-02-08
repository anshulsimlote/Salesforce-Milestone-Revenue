/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-08-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class EC_OpportunityTriggerHandler {

        /**
        * @description 
        * @author ChangeMeIn@UserSettingsUnder.SFDoc | 02-08-2025 
        * @param newList 
        **/
        public static void beforeInsert(List<Opportunity> newList){
            updateCloseDate(newList,null);
        }
        
        /**
        * @description 
        * @author ChangeMeIn@UserSettingsUnder.SFDoc | 02-08-2025 
        * @param newList 
        * @param oldMap 
        **/
        public static void beforeUpdate(List<Opportunity> newList, Map<Id,Opportunity> oldMap){
            updateCloseDate(newList,oldMap);
        }
        /**
        * @description 
        * @author ChangeMeIn@UserSettingsUnder.SFDoc | 02-08-2025 
        * @param newList 
        **/
        public static void afterInsert(List<Opportunity> newList){
            createInvoice(newList,null);
        }
    
    	/**
    	* @description 
    	* @author ChangeMeIn@UserSettingsUnder.SFDoc | 02-08-2025 
    	* @param newList 
    	* @param oldMap 
    	**/
    	public static void afterUpdate(List<Opportunity> newList, Map<Id,Opportunity> oldMap){
            createInvoice(newList,oldMap);
        }

        /**
        * @description 
        * @author ChangeMeIn@UserSettingsUnder.SFDoc | 02-08-2025 
        * @param newList 
        * @param oldMap 
        **/
        public static void updateCloseDate(List<Opportunity> newList, Map<Id,Opportunity> oldMap){
            try{
                for(Opportunity oppObj : newList){
                    if( ( oppObj.StageName == EC_Constants.closedWonStatus || oppObj.StageName == EC_Constants.closedLostStatus ) && ( ( oldMap == null ) || ( oldMap !=  null && oldMap.get(oppObj.Id).StageName != oppObj.StageName  ) ) ){
                        oppObj.CloseDate = Date.today();
                    }
                }
            }catch(Exception ex){
                throw new EC_Exception(ex.getMessage());
            }
        }
    
    
    	/**
    	* @description 
    	* @author ChangeMeIn@UserSettingsUnder.SFDoc | 02-08-2025 
    	* @param newList 
    	* @param oldMap 
    	**/
        public static void createInvoice(List<Opportunity> newList, Map<Id,Opportunity> oldMap){
            try{
                List<EC_Invoice__c> invoiceList = new List<EC_Invoice__c>();
                for(Opportunity oppObj : newList){
                    if( (oppObj.StageName == EC_Constants.closedWonStatus && oppObj?.Amount > 0) && ( ( oldMap == null ) || ( oldMap !=  null && oldMap.get(oppObj.Id).StageName != oppObj.StageName  ) ) ){
                        EC_Invoice__c tempInvoice = new EC_Invoice__c();
                        tempInvoice.Name = EC_Constants.deliveryMilestone;
                        tempInvoice.EC_Amount__c = oppObj?.Amount * 0.4;
                        tempInvoice.EC_Invoice_Date__c = Date.today();
                        tempInvoice.EC_Opportunity__c = oppObj.Id;
                        tempInvoice.EC_Status__c = EC_Constants.openStatus;
                        invoiceList.add(tempInvoice);
                    }
                }
            insert invoiceList;
            }catch(Exception ex){
                throw new EC_Exception(ex.getMessage());
            }
        }
}