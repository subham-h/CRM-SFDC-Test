public class CustomPageController {
    @AuraEnabled
    public static List<SObject> search(String searchString) {
        List<SObject> lstSearch = new List<SObject>();
        try {
            String searchStr = '*' + searchString + '*';
            String searchquery =
                'FIND\'' +
                searchStr +
                '\'IN ALL FIELDS RETURNING Contact(id, name, email where email != null), User(id, name, email where email != null AND isActive = true) LIMIT 10';
            List<List<SObject>> searchResult = search.query(searchquery);
            for (List<SObject> curList : searchResult) {
                lstSearch.addAll(curList);
            }
            system.debug('***searchList' + lstSearch.size());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return lstSearch;
    }
}