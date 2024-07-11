@isTest 
private class ChatterAnswersAuthProviderReg_Test { 
static testMethod void validateCreateUpdateUser() { 

Auth.UserData userData = new Auth.UserData('00ej0000000jJMR', 'testFirst', 'testLast', 
'testFirst testLast', 'no-reply@salesforce.com', null, 'testuserlong', 'en_US', 'facebook', 
null, new Map<String, String>{'language' => 'en_US'}); 
ChatterAnswersAuthProviderRegistration reg = new ChatterAnswersAuthProviderRegistration(); 
User newUser = reg.createUser(null, userData); 

Auth.UserData updateUserData = new Auth.UserData('00ej0000000jJMR', 'updatedFirst', 'updatedLast', 
'updatedFirst updatedLast', 'no-reply@new.salesforce.com', null, 'testuserlong', 'en_US', 'facebook', 
null, new Map<String, String>{'language' => 'en_US'}); 
reg.updateUser('00ej0000000jJMR',null,updateUserData);

} 
}