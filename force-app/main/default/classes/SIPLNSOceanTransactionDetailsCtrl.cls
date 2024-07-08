/**
 * Date         Owner            Description
 ************************************************************************************************************
 * 20/10/2022  Sidhartha@Maersk  Class created for SIP Ocean and Transactional DetailspowerBi report data.
 */
public class SIPLNSOceanTransactionDetailsCtrl {
    
    @AuraEnabled(cacheable=true)
    public static List<sipMeasureWrapper> getApplicablePeriodAndProductPortfolio(String sipMeasureId) {
        system.debug('sipMeasureId ' + sipMeasureId);
        List<sipMeasureWrapper> sipmWrapper = new List<sipMeasureWrapper>();
        List<SIP_Measure__c> lstMeasure = [SELECT Id, Applicable_Period__c ,KPI_Code__c, SIP_Participant__r.SIP_Participant__r.Name, SIP_Participant__r.SIP_Participant__r.Email, SIP_KPI__r.Product_Portfolio__c FROM SIP_Measure__c
                                       WHERE Id =:sipMeasureId];
        for(SIP_Measure__c sim : lstMeasure) {
            sipMeasureWrapper sipm = new sipMeasureWrapper();
            sipm.applicablePeriod = sim.Applicable_Period__c;
            sipm.productPortfolio = sim.SIP_KPI__r.Product_Portfolio__c;
            sipm.participantEmail = sim.SIP_Participant__r.SIP_Participant__r.Email;
            sipm.sipKpiCode = sim.KPI_Code__c;
            sipmWrapper.add(sipm);
        }
        system.debug('sipmWrapper ' + sipmWrapper);
        return sipmWrapper;
    }
    
    
    public class sipMeasureWrapper {
        @AuraEnabled
        public string applicablePeriod { get; set; }
        @AuraEnabled
        public string productPortfolio { get; set; }
        @AuraEnabled
        public string participantEmail { get; set; }
         @AuraEnabled
        public string sipKpiCode { get; set; }
        public sipMeasureWrapper() {
            applicablePeriod = '';
            productPortfolio = '';
            participantEmail = '';
            sipKpiCode = '';
        }
    }

}