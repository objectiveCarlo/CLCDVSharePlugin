package cl.android.share.model;


public class ShareModel {
	 private static ShareModel   _instance;
	//@keys
	public static final String kCLShareCDVPLuginLinkKey     = "link";
	public static final String kCLShareCDVPLuginTitleKey    = "title";
	public static final String kCLShareCDVPLuginImageKey    = "image";
	public static final String kCLShareCDVPLuginImageURLKey = "imageURL";
	public static final String kCLShareCDVPLuginMessageKey  = "message";
	public static final String kCLShareCDVPLuginTweetKey    = "tweet";
	public static final String kCLShareCDVPLuginCaptionKey  = "tweet";
	
	//@methods
	public static final String kCLShareCDVPLuginFBMethod        = "shareViaFb";
	public static final String kCLShareCDVPLuginTwitterMethod   = "shareViaTwitter";
	public static final String kCLShareCDVPLuginInstagramMethod = "shareViaInstagram";

	public ShareModel shareModel;
	
	public static ShareModel getInstance(){
		 if (_instance == null)
	        {
	            _instance = new ShareModel();
	        }
	        return _instance;
	}

	public String link;
	public String image;
	public String message;
	public String tweet;
	public String title;
	public String imageURL;
	public String caption;
	public boolean isFacebook = false;

	public void setByKeyAndValue(String key, String value){
		if(key == null) return;

		if(key.equals(kCLShareCDVPLuginLinkKey))    this.link   = value;
		else if(key.equals(kCLShareCDVPLuginImageKey))   this.image = value;
		else if(key.equals(kCLShareCDVPLuginMessageKey)) this.message = value;
		else if(key.equals(kCLShareCDVPLuginTweetKey))   this.tweet = value;
		else if(key.equals(kCLShareCDVPLuginTitleKey))   this.title = value;
		else if(key.equals(kCLShareCDVPLuginImageURLKey)) this.imageURL = value;
		else if(key.equals(kCLShareCDVPLuginCaptionKey)) this.caption = value;

	}

}
