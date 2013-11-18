package cl.android.share.module;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Environment;
import cl.android.share.model.ShareModel;

public class InstagramModule extends ShareModule {

	public InstagramModule(Activity activity, ShareModel shareModel) {
		super(activity, shareModel);
		shareModel.isFacebook = false;
	}
	
	public  Bitmap getBitmapFromAsset(Context context, String strName) {
	    AssetManager assetManager = context.getAssets();

	    InputStream istr;
	    Bitmap bitmap = null;
	    try {
	        istr = assetManager.open(strName);
	        bitmap = BitmapFactory.decodeStream(istr);
	    } catch (IOException e) {
	        return null;
	    }

	    return bitmap;
	}

	public void share(){
		if(verificaInstagram()){
			Intent shareIntent = new Intent(android.content.Intent.ACTION_SEND);
			shareIntent.setType("image/*");                 

			String file_path = Environment.getExternalStorageDirectory().getAbsolutePath() + 
					"/vape";
			File dir = new File(file_path);
			if(!dir.exists())
				dir.mkdirs();
			File file = new File(dir, "icon"  + ".png");
			FileOutputStream fOut;
			
			Bitmap bmp = getBitmapFromAsset(this.activity, "www/img/logo.png");
			
			if(bmp == null) bmp = getBitmapFromAsset(this.activity, "assets/www/img/logo.png");
			if(bmp == null) bmp = getBitmapFromAsset(this.activity, "img/logo.png");
			if(bmp == null) bmp = getBitmapFromAsset(this.activity, "logo.png");
			if(bmp == null) return;
			try {
				fOut = new FileOutputStream(file);
				bmp.compress(Bitmap.CompressFormat.PNG, 85, fOut);
				fOut.flush();
				fOut.close();
			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
				return;
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
				return;
			}
			
			

			shareIntent.putExtra(Intent.EXTRA_STREAM, Uri.parse(file.getAbsolutePath()));
			shareIntent.putExtra(Intent.EXTRA_TEXT, this.shareModel.caption);
			shareIntent.setPackage("com.instagram.android");
			this.activity.startActivity(shareIntent);
		}else{

		}
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
