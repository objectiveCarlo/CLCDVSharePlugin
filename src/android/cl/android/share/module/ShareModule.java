package cl.android.share.module;

import android.app.Activity;
import cl.android.share.model.ShareModel;

public class ShareModule {
	protected Activity activity;
	
	protected ShareModel shareModel;
	
	
	
	
	public ShareModule(Activity activity, ShareModel shareModel){

		this.activity = activity;
		this.shareModel = shareModel;

	}


	
	
	
}
