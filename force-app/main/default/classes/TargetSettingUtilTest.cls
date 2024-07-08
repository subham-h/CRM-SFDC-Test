@IsTest
public class TargetSettingUtilTest {
    @IsTest static void getRofoVersionYearTest() {
        // GIVEN
        String rofoVersion = 'ROFOQ12004';
        
        // WHEN
        Test.startTest();
        String rofoYear = TargetSettingUtil.getYearRofoVersion(rofoVersion);
        Test.stopTest();
        
        // THEN
		System.assertEquals('2004', rofoYear);
    }
    
	@IsTest static void getRofoVersionYearNegativeTest() {
        // GIVEN
        String rofoVersion = 'ROF';
        
        // WHEN
        Test.startTest();
        String errorMessage;
        try {
        	String rofoYear = TargetSettingUtil.getYearRofoVersion(rofoVersion);
        } catch (Exception caughtException) {
            errorMessage = caughtException.getMessage();
        }
        Test.stopTest();
        
        // THEN
		System.assertEquals('Starting position out of bounds: 6', errorMessage);
    }
    
    @IsTest static void getMeasureFromRofoVersionTest() {
        // GIVEN
        String rofoVersionQ1 = 'ROFOQ12004';
        String rofoVersionQ2 = 'ROFOQ22004';
        String rofoVersionQ3 = 'ROFOQ32004';
        String rofoVersionQ4 = 'ROFOQ42004';
        
        // WHEN
        Test.startTest();
        String rofoYearQ1 = TargetSettingUtil.getMeasureFromRofoVersion(rofoVersionQ1);
        String rofoYearQ2 = TargetSettingUtil.getMeasureFromRofoVersion(rofoVersionQ2);
        String rofoYearQ3 = TargetSettingUtil.getMeasureFromRofoVersion(rofoVersionQ3);
        String rofoYearQ4 = TargetSettingUtil.getMeasureFromRofoVersion(rofoVersionQ4);
        Test.stopTest();
        
        // THEN
		System.assertEquals('Rolling Forecast', rofoYearQ1);
		System.assertEquals('Rolling Forecast', rofoYearQ2);
		System.assertEquals('Rolling Forecast', rofoYearQ3);
		System.assertEquals('Budget', rofoYearQ4);
    }
    
    @IsTest static void getMeasureFromRofoVersionNegativeTest() {
        // GIVEN
        String rofoVersion = 'ROFOQ92004';
        
        // WHEN
        Test.startTest();
        String rofoYear = TargetSettingUtil.getMeasureFromRofoVersion(rofoVersion);
        Test.stopTest();
        
        // THEN
		System.assertEquals(null, rofoYear);
    }
    
    @IsTest static void generateUniqueIdFromStringTest() {
        // GIVEN
        String inputString = '4PL PFMaersk LineIndia';
        
        // WHEN
        Test.startTest();
        String output = TargetSettingUtil.generateUniqueIdFromString(inputString);
        Test.stopTest();
        
        // THEN
		System.assertEquals(EncodingUtil.base64Encode(Blob.valueOf(inputString)), output);
    }
    
    @IsTest static void getPicklistValuesTest() {
        // GIVEN
        String objectName = 'Target_Item_Group__c';
        String fieldName = 'BrandMnA__c';
        
        // WHEN
        Test.startTest();
        Set<String> retVal = TargetSettingUtil.getPicklistValues(objectName, fieldName);
        Test.stopTest();
        
        // THEN
		System.assert(retVal.contains('Maersk Line'));
        System.assert(retVal.contains('Safmarine'));
        System.assert(retVal.contains('Hamburg Sud'));
    }
}