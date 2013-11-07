package cl.cordova.plugin.share;

import java.util.ArrayList;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class CLShareCDVPLugin extends CordovaPlugin {
	//@keys
	public final String kCLShareCDVPLuginLinkKey    = "link";
	public final String kCLShareCDVPLuginImageKey   = "image";
	public final String kCLShareCDVPLuginMessageKey = "message";
	public final String kCLShareCDVPLuginTweetKey   = "tweet";
	
	//@methods
	public final String kCLShareCDVPLuginFBMethod        = "shareViaFb";
	public final String kCLShareCDVPLuginTwitterMethod   = "shareViaTwitter";
	public final String kCLShareCDVPLuginInstagramMethod = "shareViaInstagram";
	
	public ShareModel shareModel;
	
	public class  ShareModel{
		public String link;
		public String image;
		public String message;
		public String tweet;
		
		public void setByKeyAndValue(String key, String value){
			if(key == null) return;
			
			 	  if(key.equals(kCLShareCDVPLuginLinkKey))    this.link   = value;
			 else if(key.equals(kCLShareCDVPLuginImageKey))   this.image = value;
			 else if(key.equals(kCLShareCDVPLuginMessageKey)) this.message = value;
			 else if(key.equals(kCLShareCDVPLuginTweetKey))   this.tweet = value;
					 	  
		}
	}
	

	private boolean validateAndGetParams(JSONArray array, ArrayList<String>paramsKey,  ArrayList<String>concernedKeys){
		boolean isValid = true;
		
		if(shareModel == null) shareModel = new ShareModel();
		
		
		try {
			JSONObject jsonObject = (JSONObject) array.get(0);
			
			for(int i = 0 ; i  < concernedKeys.size(); i++){
				String param = jsonObject.getString(concernedKeys.get(i));
				isValid = this.isParamValid(param);
				
				if(isValid){
					shareModel.setByKeyAndValue(paramsKey.get(i), param);
				}else{
					isValid = false;
					break;
				}
				
			}
			
		} catch (JSONException e) {
			isValid = false;
			 e.printStackTrace();
		}
		
		
		return isValid;
	}
	
	private void shareViaFb(JSONArray array, CallbackContext callbackContext){
		ArrayList<String>paramskey = new ArrayList<String>();
		paramskey.add(kCLShareCDVPLuginLinkKey);
		paramskey.add(kCLShareCDVPLuginMessageKey);
		paramskey.add(kCLShareCDVPLuginImageKey);
		
		
		ArrayList<String>concernedKeys = new ArrayList<String>();
		
		
		boolean valid = this.validateAndGetParams(array, paramskey, concernedKeys);
		
		
	}
	
	
	private void shareViaTwitter(JSONArray array, CallbackContext callbackContext){
		ArrayList<String>paramskey = new ArrayList<String>();
		paramskey.add(kCLShareCDVPLuginLinkKey);
		paramskey.add(kCLShareCDVPLuginTweetKey);
		paramskey.add(kCLShareCDVPLuginImageKey);
		
		
		ArrayList<String>concernedKeys = new ArrayList<String>();
		
		
		boolean valid = this.validateAndGetParams(array, paramskey, concernedKeys);
		
		
	}
	
	
	private void shareViaInstagram(JSONArray array, CallbackContext callbackContext){
		ArrayList<String>paramskey = new ArrayList<String>();
		paramskey.add(kCLShareCDVPLuginLinkKey);
		paramskey.add(kCLShareCDVPLuginMessageKey);
		paramskey.add(kCLShareCDVPLuginImageKey);
		
		
		ArrayList<String>concernedKeys = new ArrayList<String>();
		
		
		boolean valid = this.validateAndGetParams(array, paramskey, concernedKeys);
		
		
	}
	
	
	private boolean isParamValid(String param){
		
		
		return (param != null && param.trim().length() > 0);
	}
	
	@Override
	public boolean execute(String action, JSONArray array,
			CallbackContext callbackContext) throws JSONException {
		
		if(action.equals(kCLShareCDVPLuginFBMethod))
			this.shareViaFb(array, callbackContext);
		else
		if(action.equals(kCLShareCDVPLuginTwitterMethod))
			this.shareViaTwitter(array, callbackContext);
		else
		if(action.equals(kCLShareCDVPLuginInstagramMethod))
			this.shareViaInstagram(array, callbackContext);
		else
			return false;
		
		return true;
	}
	
	
}
