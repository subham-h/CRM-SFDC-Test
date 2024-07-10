/**
 * @description: Case Survey Component Controller.
 * 
 * Revision Ref Number  Date        Owner                   Description
 * -------- ----------  ----------- -------------------     -----------
 * 1.0      SPI-100     07-09-2022  Ronnie@SF               Removal of brand hardcoding from VF component
 */
public class CaseSurveyComponentCtrl {
    
    public String allNamesMCC{get;set;}
    
    /**
     * @description Constructor. Retrieve all names for brands to allow for references in VF. Currently only contains MCC.
     */
    public CaseSurveyComponentCtrl() {
        allNamesMCC = BrandUtilities.getBrandAllNames(BrandUtilities.MCC);
    }
}