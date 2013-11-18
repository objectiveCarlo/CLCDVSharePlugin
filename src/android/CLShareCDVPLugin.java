package cl.cordova.plugin.share;

import java.io.IOException;
import java.util.ArrayList;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import cl.android.share.model.ShareModel;
import cl.android.share.module.FacebookModule;
import cl.android.share.module.InstagramModule;
import cl.android.share.module.TwitterModule;

import com.isbx.vapedup.VapedUpMobile;
import com.ppierson.t4jtwitterlogin.T4JTwitterLoginActivity;

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


	private boolean validateAndGetParams(JSONArray array, ArrayList<String>paramsKey,  ArrayList<String>concernedKeys){
		boolean isValid = true;

		if(shareModel == null) shareModel = ShareModel.getInstance();


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

		if(valid){
			FacebookModule fbModule = new FacebookModule(this.cordova.getActivity(), shareModel);
			fbModule.share();
		}
	}


	private void shareViaTwitter(JSONArray array, CallbackContext callbackContext){
		ArrayList<String>paramskey = new ArrayList<String>();
		paramskey.add(kCLShareCDVPLuginLinkKey);
		paramskey.add(kCLShareCDVPLuginTweetKey);
		paramskey.add(kCLShareCDVPLuginImageKey);
		Activity act = this.cordova.getActivity();
		String consumerKey = "KbdiEzokWhgmTbgmZZvQ";
		String consumerSecretKey = "PxF3HVENn1dWoQi12kETaVNulkdBk9iV6cqFeMJUSA";
		ArrayList<String>concernedKeys = new ArrayList<String>();


		boolean valid = this.validateAndGetParams(array, paramskey, concernedKeys);

		if(valid){
			if(T4JTwitterLoginActivity.isConnected(this.cordova.getActivity())){
				TwitterModule twitterModule = new TwitterModule(this.cordova.getActivity(), shareModel);
				twitterModule.setConsumerKey(consumerKey);
				twitterModule.setConsumerSecretKey(consumerSecretKey);
				try {
					twitterModule.share();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}else{
				
				Intent twitterLoginIntent = new Intent(act, T4JTwitterLoginActivity.class);
				twitterLoginIntent.putExtra(T4JTwitterLoginActivity.TWITTER_CONSUMER_KEY, consumerKey);
				twitterLoginIntent.putExtra(T4JTwitterLoginActivity.TWITTER_CONSUMER_SECRET, consumerSecretKey);
				act.startActivityForResult(twitterLoginIntent, VapedUpMobile.kVapedUpMobileTwitterShareRequestCode);
			}
		}
	}


	private void shareViaInstagram(JSONArray array, CallbackContext callbackContext){
		ArrayList<String>paramskey = new ArrayList<String>();
		paramskey.add(kCLShareCDVPLuginLinkKey);
		paramskey.add(kCLShareCDVPLuginMessageKey);
		paramskey.add(kCLShareCDVPLuginImageKey);


		ArrayList<String>concernedKeys = new ArrayList<String>();


		boolean valid = this.validateAndGetParams(array, paramskey, concernedKeys);

		if(valid){
			InstagramModule instagramModule = new InstagramModule(this.cordova.getActivity(), shareModel);
			instagramModule.share();

		}
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
