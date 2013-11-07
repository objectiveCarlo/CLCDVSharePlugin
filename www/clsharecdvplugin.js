var argscheck = require('cordova/argscheck'),
    channel = require('cordova/channel'),
    utils = require('cordova/utils'),
    exec = require('cordova/exec'),
    cordova = require('cordova');

channel.createSticky('onCordovaInfoReady');
// Tell cordova channel to wait on the CordovaInfoReady event
channel.waitForInitialization('onCordovaInfoReady');


var CLShareCDVPlugin = function () {

	var kClassName = "CLShareCDVPlugin";

    var self = this;
    var p    = CLShareCDVPlugin.prototype;
    var params = [];

    p.SupportedSocialMedia = {
        FACEBOOK  : "shareViaFb",
        TWITTTER  : "shareViaTwitter",
        INSTAGRAM : "shareViaInstagram"
    }

    p.SupportedKeys = {
        LINK    : "link",
        IMAGE   : "image",
        MESSAGE : "message",
        TWEET   : "tweet",
    }

    //default is facebook
    var socialMediaMethod = self.SupportedSocialMedia.FACEBOOK;

	
    p.setSocialMedia = function(socilaMediaArgs){

        var valid =self.determineIfKeyIsValid(key, self.SupportedKeys);
        
        if(valid) 
            socialMediaMethod = socilaMediaArgs;

        return valid;
    };

    p.determineIfKeyIsValid = function(key, struct){
        var valid = false;
        for(var i in struct)
        {   
            var supportedKey = struct[i];
            if(supportedKey == key){
                valid = true;
                break;
            }
        }

        return valid;
    };

    p.share = function(successCallBack, errorCallback){
    		
            exec(successCallback, errorCallback, kClassName, socialMediaMethod, [params]);
    };

    p.addToParams = function(key, value){
        var valid =self.determineIfKeyIsValid(key, self.SupportedKeys);
        
        if(valid) 
            params[key] = value;

        return valid;

    };
}