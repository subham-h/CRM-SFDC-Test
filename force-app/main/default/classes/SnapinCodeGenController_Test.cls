/*
 * Author   : Pete Ryan
 * Purpose  : Test for SnapinCodeGen VF / SnapinCodeGenController
 *        
 * Revision Ref Number            Date        Owner                   Description
 * -------- --------------------  ----------- -------------------     -----------
 * 1.0      RQ-008801/RQ-008799   12-Jul-2018 Pete@UST                Created.
 * 
 *  
 */
@isTest
public class SnapinCodeGenController_Test {
    
    public static final String LOGMARK = '##### SnapinCodeGenController_Test : ';

    static testMethod void testSnapinCodeGenController() {

        PageReference pageRef = Page.SnapinCodeGen;
        Test.setCurrentPage(pageRef);

        System.Test.startTest();
        
            SnapinCodeGenController ctrlr = new SnapinCodeGenController();

            // Form validation - no missing fields
            ctrlr.sdh.eslaOrgInf.siteUrl = 'https://regsit-maersk.cs80.force.com/Survey';
            ctrlr.regenerate();
            String s = ctrlr.javaSriptCode;
            System.assert(ApexPages.getMessages().isEmpty());
            ctrlr.deleteSnapins();
            ctrlr.createSnapins();
            ctrlr.mobilesnapinCode();
           // String bln='true';
            //System.assertEquals(s, bln);
            s = ctrlr.eslaOrgInfo;
           
            //ctrlr.sdh.complete = true;
            //s = ctrlr.javaSriptCode;
            //s = ctrlr.eslaOrgInfo;
        
        System.Test.stopTest();
        
    }    
}