/** 
* @description 
* Created By   : sandhya@Maersk
* Purpose  : Wrapper class to hold ShipmentReferences response data. 
*        
* Revision Ref Number  Date        Owner                   Description
* -------- ----------  ----------- -------------------     -----------
* 1.0      SC-8937     23-01-2024   sandhya@maersk         Wrapper class for short transit RQ
*/
global class ShipmentReferenceWrapper {
    
    public List<ReferenceWrapper> references { get; set; }
    
    public class ReferenceWrapper {
        public String referenceType { get; set; }
        public String name { get; set; }
        public String value { get; set; }
    }
    
    public String getShortSeaValue() {
        if (references != null) {
            for (ReferenceWrapper reference : references) {
                if (reference?.referenceType.equalsIgnoreCase('Status') && reference?.name.equalsIgnoreCase('Short Sea')) {
                    return reference?.value;
                }
            }
        }
        return null;
    }
}