@isTest
global class EmailArchivalDataSourceProviderMock implements HttpCalloutMock {
     // Implement this interface method
     global HTTPResponse respond(HTTPRequest req) {
      string responseString ='[{"istracked":"null","parentid":"5001X00000IxaWQQAZ","incoming":"null","headers":"null","firstopeneddate":"null","isclientmanaged":"null","activityid":"null","fromaddress":"null","replytoemailmessageid":"null","subject":"test","htmlbody":"null","lastopeneddate":"null","lastmodifieddate":"null","textbody":"testbody","isdeleted":"null","systemmodstamp":"null","isexternallyvisible":"null","messageidentifier":"null","lastmodifiedbyid":"null","emailtemplateid":"null","status":"null","bccaddress":"null","isbounced":"null","isopened":"null","threadidentifier":"null","ccaddress":"null","messagedate":"null","fromname":"null","createddate":"null","toaddress":"null","createdbyid":"null","validatedfromaddress":"null","hasattachment":null,"casevisibility":null,"created__in_heroku":"2022-10-12","emailid":"x031X0000000WIbQAM","heroku_id":"2"}]';
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody(responseString);
      res.setStatusCode(200);
      res.setStatus('Success');
      if(req.getMethod().equalsIgnoreCase( 'POST')){
         res.setStatus('Created');
      }
      return res;
     }
}