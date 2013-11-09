package cl.android.share.module;

import android.app.Activity;
import android.os.Bundle;

import cl.android.share.model.ShareModel;

import com.facebook.FacebookException;
import com.facebook.FacebookOperationCanceledException;
import com.facebook.Request;
import com.facebook.Response;
import com.facebook.Session;
import com.facebook.SessionState;
import com.facebook.model.GraphUser;
import com.facebook.widget.WebDialog;
import com.facebook.widget.WebDialog.OnCompleteListener;

public class FacebookModule extends ShareModule {

	
	
	public FacebookModule(Activity activity, ShareModel shareModel) {
		super(activity, shareModel);
	
	}


	public void share(){

		Session.openActiveSession(activity, true, new Session.StatusCallback() {

			@Override
			public void call(Session session, SessionState state, Exception exception) {
				if (session.isOpened()) {

					Request.newMeRequest(session, new Request.GraphUserCallback() {
						@Override
						public void onCompleted(GraphUser user, Response response) {
							if (user != null) {
								showFacebookFeedDialog();
							}
						}
					}).executeAsync();
				}
			}
		});
	}


	private void showFacebookFeedDialog(){
		Bundle params = new Bundle();
		params.putString("name", shareModel.title);
		params.putString("caption", shareModel.caption);
		params.putString("description", shareModel.message);
		params.putString("link", shareModel.link);
		params.putString("picture", shareModel.imageURL);

		// Invoke the dialog
		WebDialog feedDialog = (
				new WebDialog.FeedDialogBuilder(activity, Session.getActiveSession(), params))
				.setOnCompleteListener(new OnCompleteListener() {
					@Override
					public void onComplete(Bundle values, FacebookException error) {
						if (error == null) {
							final String postId = values.getString("post_id");
							if (postId != null) {
								//									cheers("Posted story, id: "+postId, false); //SUCCESS
							} else {
								//									cheers("Publish cancelled", false); // User clicked the Cancel button
							}
						} else if (error instanceof FacebookOperationCanceledException) {							
							//								cheers("Publish cancelled", false); // User clicked the "x" button
						} else {							
							//								cheers("Error posting story", false); // Generic, ex: network error
						}
					}
				})
				.build();
		feedDialog.show();
	}
}

