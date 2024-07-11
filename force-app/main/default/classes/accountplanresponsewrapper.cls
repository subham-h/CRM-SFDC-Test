/********************************************************************************************
 * Sno		Version		Story		Author				Date			Descrition
 * 1.		1.0			SFSE-9838	Sidhartha@Maersk	12/11/2022		Response wrapper used in Loli document generation. 
 ********************************************************************************************/
public class accountplanresponsewrapper {
    public List<CompositeResponse> compositeResponse {get;set;} 
    public class CompositeResponse {
        public Integer httpStatusCode {get;set;} 
    }
}