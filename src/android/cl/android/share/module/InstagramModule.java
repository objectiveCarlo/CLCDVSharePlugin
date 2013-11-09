package cl.android.share.module;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager.NameNotFoundException;
import android.net.Uri;
import cl.android.share.model.ShareModel;

public class InstagramModule extends ShareModule {

	public InstagramModule(Activity activity, ShareModel shareModel) {
		super(activity, shareModel);

	}
	
	public void share(){
		
		Intent shareIntent = new Intent(android.content.Intent.ACTION_SEND);
		shareIntent.setType("image/*");                 

		shareIntent.putExtra(Intent.EXTRA_STREAM, Uri.parse(this.shareModel.image));
		shareIntent.putExtra(Intent.EXTRA_TEXT, this.shareModel.caption);
		shareIntent.setPackage("com.instagram.android");
		this.activity.startActivity(shareIntent);
	}
	
	public boolean verificaInstagram(){
		boolean installed = false;

		try {
			ApplicationInfo info = this.activity.getPackageManager().getApplicationInfo("com.instagram.android", 0);
			if(info!= null)
				installed = true;
		} catch (NameNotFoundException e) {
			installed = false;
		}
		return installed;
	}

}
