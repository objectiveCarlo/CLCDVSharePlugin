package cl.android.share.module;

import java.io.File;
import java.io.IOException;

import twitter4j.StatusUpdate;
import twitter4j.Twitter;
import twitter4j.TwitterException;
import twitter4j.TwitterFactory;
import twitter4j.conf.Configuration;
import twitter4j.conf.ConfigurationBuilder;
import android.app.Activity;
import android.content.Context;
import cl.android.share.model.ShareModel;

import com.ppierson.t4jtwitterlogin.T4JTwitterFunctions;
import com.ppierson.t4jtwitterlogin.T4JTwitterFunctions.TwitterPostResponse;
import com.ppierson.t4jtwitterlogin.T4JTwitterLoginActivity;

public class TwitterModule extends ShareModule {
	public static final int TWITTER_LOGIN_REQUEST_CODE = 9000;

	private String consumerKey;

	private String consumerSecretKey;
	
	public TwitterModule(Activity activity, ShareModel shareModel) {
		super(activity, shareModel);
		shareModel.isFacebook = false;
	}


	public String getConsumerKey() {
		return consumerKey;
	}


	public void setConsumerKey(String consumerKey) {
		this.consumerKey = consumerKey;
	}


	public String getConsumerSecretKey() {
		return consumerSecretKey;
	}


	public void setConsumerSecretKey(String consumerSecretKey) {
		this.consumerSecretKey = consumerSecretKey;
	}

	public void share() throws IOException{
//		File imageFile = new File("http://us.123rf.com/400wm/400/400/snehit/snehit1105/snehit110500001/9435487-an-illustration-of-3d-city-icon-with-colorful-buildings.jpg");

		this.postToTwitter(this.activity.getApplicationContext(), this.activity,
				this.consumerKey, this.consumerSecretKey,
				this.shareModel.message+" -"+this.shareModel.link, null, new T4JTwitterFunctions.TwitterPostResponse(){
			@Override
			public void OnResult(Boolean success) {

			}
		});
	}

	private void postToTwitter(Context c, final Activity callingActivity, final String consumerKey, final String consumerSecret, final String message, final File image, final TwitterPostResponse postResponse){
		if(!T4JTwitterLoginActivity.isConnected(c)){
			postResponse.OnResult(false);
			return;
		}

		ConfigurationBuilder configurationBuilder = new ConfigurationBuilder();
		configurationBuilder.setOAuthConsumerKey(consumerKey);
		configurationBuilder.setOAuthConsumerSecret(consumerSecret);
		configurationBuilder.setOAuthAccessToken(T4JTwitterLoginActivity.getAccessToken((c)));
		configurationBuilder.setOAuthAccessTokenSecret(T4JTwitterLoginActivity.getAccessTokenSecret(c));
		Configuration configuration = configurationBuilder.build();
		final Twitter twitter = new TwitterFactory(configuration).getInstance();

		new Thread(new Runnable() {
			@Override
			public void run() {
				boolean success = true;
				try {
					StatusUpdate status = new StatusUpdate(message);
					status.setMedia(image);
					twitter.updateStatus(status);
				} catch (TwitterException e) {
					e.printStackTrace();
					success = false;
				}

				final boolean finalSuccess = success;

				callingActivity.runOnUiThread(new Runnable() {
					@Override
					public void run() {
						postResponse.OnResult(finalSuccess);
					}
				});

			}
		}).start();
	}

}
