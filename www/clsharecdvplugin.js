
var argscheck = require('cordova/argscheck'),
               channel = require('cordova/channel'),
               utils = require('cordova/utils'),
               exec = require('cordova/exec'),
               cordova = require('cordova');
               
channel.createSticky('onCordovaInfoReady');
               
               // Tell cordova channel to wait on the CordovaInfoReady event
 channel.waitForInitialization('onCordovaInfoReady');

var CLShareCDVPluginClass = function () {

    var kClassName = "CLShareCDVPLugin";

    var self = this;
    var p    = CLShareCDVPluginClass.prototype;
    var params = {};

    p.SupportedSocialMedia = {
        FACEBOOK  : "shareViaFb",
        TWITTER  : "shareViaTwitter",
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

    p.init = function (){

    };
    
    p.setSocialMedia = function(socilaMediaArgs){
        
        var valid =self.determineIfKeyIsValid(socilaMediaArgs, self.SupportedSocialMedia);
        
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

    p.share = function(successCallback, errorCallback){
            
            if(typeof exec === 'undefined')
            {
                if(typeof cordova === 'undefined' || typeof cordova.exec === 'undefined')
                {
                     exec = function (){};
                }else
                {
                    exec = cordova.exec;
                }
            }

            exec(successCallback, errorCallback, kClassName, socialMediaMethod, [params]);
    };

    p.addToParams = function(key, value){
        var valid =self.determineIfKeyIsValid(key, self.SupportedKeys);
        
        if(valid) params[key] = value;

        return valid;

    };
               
    self.init();
}
module.exports =   CLShareCDVPluginClass;


