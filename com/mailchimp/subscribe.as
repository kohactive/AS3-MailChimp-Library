/**

	
	ABOUT THIS CLASS
	////////////////////////////////////////////////////////////////
	
	* VESRION 1.5
	* DATE: 09/24/2010
	* AS3 
	* UPDATES AND DOCUMENTATION AT: http://www.kohactive.com
	
	
	AS3 MAILCHMP LIBRARY V1.5
	
	
	This is a simple, lightweight AS3 class that allows you create
	Flash based newsletter subscription forms on your website. For
	updates and information check out the post on our blog at
	http://www.kohactive.com
	




	DOCUMENTATION AND EXAMPLES
	////////////////////////////////////////////////////////////////
	
	HOW TO USE:
	
	This class is extremely easy to use, just import the class,
	create a instant and boom!
	
	
	EXAMPLE:
	
	import com.mailchimp.subscribe; 
	var SubscribeUser : subscribe = new subscribe( "data center", "API Key", "List ID", "Email Address", "First Name", "Last Name" )
	
	
	ADDITIONAL FUNCTIONS
	
	SubscribeUser.addEventListener("sendingAPIRequest", connecting);
	SubscribeUser.addEventListener("connectingToAPI", connecting);
	SubscribeUser.addEventListener("subscribeError", error);
	SubscribeUser.addEventListener("invalidEmail", error);
	SubscribeUser.addEventListener("subscribeSuccess", error);
	
	function error(e:Event) {
		trace( SubscribeUser.getError() );
	}
	
	
	SubscribeUser.getError()    <== this will return the "progressResponse"
	
	the event listeners will alert you when something happens
	


	
	
	LEGAL
	////////////////////////////////////////////////////////////////
	
	 Copyright (c) 2010  kohactive (http://www.kohactive.com)
 
	 Permission is hereby granted, free of charge, to any person
	 obtaining a copy of this software and associated documentation
	 files (the "Software"), to deal in the Software without
	 restriction, including without limitation the rights to use,
	 copy, modify, merge, publish, distribute, sublicense, and/or sell
	 copies of the Software, and to permit persons to whom the
	 Software is furnished to do so, subject to the following
	 conditions:
	
	 The above copyright notice and this permission notice shall be
	 included in all copies or substantial portions of the Software.
	
	 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	 OTHER DEALINGS IN THE SOFTWARE.

	
	
	
 **/

package com.mailchimp {

	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	
	
	public class subscribe extends MovieClip {
		
		private var progressResponse:String;
		private var url:String;
		
		public function subscribe( dataCenter:String, apiKey:String, listID:String, emailAddress:String, firstName:String = null, lastName:String = null ) {
			
			
			/**
				
				CHECK REQUIREMENTS:
			
				Check the basic requirements before proceeding. The only 
				requirements of the user is the email addresss, but you
				should have your API KEY, List ID and Data Center information
				hardwired into the class or loaded externally. 
				
			**/
			if ( checkRequirements(dataCenter, apiKey, listID, emailAddress) ) {
	
				/*
					This is a basic subscription URL without first and last
					name for the subscription
				*/
				url = "method=listSubscribe&output=xml&apikey=" + apiKey + "&id=" + listID + "&email_address=" + emailAddress;
				
				
				/*
					Check to see if the user has submitted first and last
					name. If so, add it to teh subscription URl to be
					added to their contact information.
				*/
					if (firstName != null) { //if first name is provided
							url = url + "&merge_vars[FNAME]=" + firstName;
					}
					
					if ( lastName != null ) { //if last name is provided
							url = url + "&merge_vars[LNAME]=" + lastName;
					}
				
				
				//set response text
				progressResponse = "sending API Request...";
				dispatchEvent( new Event("sendingAPIRequest", true, true) );
				
				
				/*
					
					SET UP THE API CALL
					
					Given the variables (see url above), create the
					connection to the API to the list subscribe
					function.
					
					You'll need the correct Data Center information
					here (i.e., "us1", "us2", "uk1", etc.)
					
				*/
				var variables:URLVariables = new URLVariables(url);
				var request:URLRequest = new URLRequest();
				request.url = "http://" + dataCenter + ".api.mailchimp.com/1.2/?method=listSubscribe";
				request.method = URLRequestMethod.POST;
				request.data = variables;
				
				//create the loader
				var loader:URLLoader = new URLLoader();
				loader.dataFormat = URLLoaderDataFormat.VARIABLES;
				loader.addEventListener(Event.COMPLETE, completeHandler);
				
				
				try {
						trace("loading...");
						progressResponse = "connecting...";
						dispatchEvent( new Event("connectingToAPI", true, true) );
						loader.load(request);
				} 
				
				//catch all errors
				catch(error:Error) {
						trace("unable to load URL");
						progressResponse = "Oh, that's embarassing. something went wrong, please try again. Thanks!";
						dispatchEvent( new Event("connectionError", true, true) );
						//trace(error.target.data);
				}
				
				/*
					check to see for errors or success. Errors are returned
					in XML format, so we'll parse the XML
				*/
				function completeHandler(e:Event) {
						var _t:String = unescape(e.target.data); //decode the uri
						var _xml:XMLList = new XMLList(_t); //parse the xml						
						trace(_xml.@type);
						
						//check to see if there is an error
						if (_xml.@type == "array") { 
						
							trace(_xml.error);
							progressResponse = _xml.error;
							dispatchEvent( new Event("subscribeError", true, true) );
							
						} 
						
						//check to see if successfully added
						else if (_xml.@type == "boolean") { 
						
							trace("successfully added to list");
							progressResponse = "You have beeen successfully added to our list. Thank you!";				
							dispatchEvent( new Event("subscribeSuccess", true, true) );
							
						}
				}
				
				
			} else {
				
				/** 
					This will go off if the user has submitted an 
					incorrect email address AND if the Data Center, API Key,
					or List ID are incorrect! 
				
				**/
				trace ("invalid email, datacenter, api key or something!");
				progressResponse = "invalid email!";
				dispatchEvent( new Event("invalidEmail", true, true) );
				
			}
			
		}
		
		
		public function getError():String {
			return progressResponse; 
		}
		
		
		/**
			Simple check to make sure none of the required fields are
			empty and that the email address is valid
		**/
		function checkRequirements( dc:String, ak:String, li:String, ea:String ) : Boolean {
			
			//check for valid email address
			var exp:RegExp = /^[a-z][\w.-]+@\w[\w.-]+\.[\w.-]*[a-z][a-z]$/i;
			var b:Boolean = (exp.test(ea));
			
			//check if all required fields are filled
			if ( dc != '' && ak != '' && li != '' && b == true ) {
				return true;
			} else {
				return false;
			}
			
		}
		
		
	}
}
			
			