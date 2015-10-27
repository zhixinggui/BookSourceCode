<?php
	require_once('Utils.php');
	
	$AES_KEY = "b36013521d0f5dbea0e4ac1fd7af804a";
	$DES_KEY = "";
	$HMAC_KEY = "065a62448fb75fce3764dcbe68f9908d";
	
	$headers = getHeaders();
	$token = $headers['Auth-Token'];
	$request_method = $_SERVER["REQUEST_METHOD"];
	
	$path = explode("/", $_GET['method']);
	$root = strtolower($path[0]);
	$method = strtolower($path[1]);
	$submethod = strtolower($path[2]);
	$action = strtolower($path[3]);
	
	// here we would validate whether the user has been authenticated
	// we ignore this for authentication requests - they haven't received a token yet
	if ((!isValidToken($token)) && !($root == "user" && $method == "authenticate")) {
		sendAPIResponse(403, json_encode(buildErrorResponse("Invalid request. You are not authorized. Token $token is invalid.")));
		return;
	}
	
	switch($path[0]) {
		
		// USER specific methods - e.g. authenticate, accounts
		case "user":
			$method = $path[1];
			
			// authenticate request
			if ($method == "authenticate") {
				$realm = "mobilebanking";
				
				if ($request_method == "POST" || $request_method == "GET") {
					
					switch ($submethod) {
						// certificate authentication
						case "certificate":
							
							// only attempt authentication if a certificate was sent
							if ($_SERVER['SSL_CLIENT_VERIFY'] == "SUCCESS"){
								// this method uses the PHP $_SERVER variables for certificate data
								// optionally, you can use openssl_x509_parse($_SERVER['SSL_CLIENT_CERT'])
								// to get an array of certificate data
								
								// get the decrypted pin (in practice, decryption would be a separate method)
								$encryptedPIN = $_REQUEST['pin'];
								$non_res = mcrypt_decrypt(MCRYPT_RIJNDAEL_128, $AES_KEY, base64_decode($encryptedPIN), MCRYPT_MODE_CBC, $iv);
								$decryptedPIN = $non_res;
								$dec_s2 = strlen($decryptedPIN);
								$padding = ord($decryptedPIN[$dec_s2-1]);
								$decryptedPIN = substr($decryptedPIN, 0, -$padding);
								
								// verify the certificate serial, email, and PIN
								$certificateSerial = $_SERVER['SSL_CLIENT_M_SERIAL'];
								$certificateUserEmail = $_SERVER['SSL_CLIENT_S_DN_Email'];
								
								if ($certificateSerial == "123456" &&				// the cert serial on file
									$certificateUserEmail == "name@email.com" && 	// the email address for the user
									$decryptedPIN == "0987") {						// the pin for the user on file
									
									// user successfully authenticated
									sendAPIResponse(200, json_encode(generateSuccessfulAuthenticationResponse()));
									return;
								}
									
							}
							
							// issue failed authentication message directing user to try standard auth
							sendAPIResponse(401, json_encode(buildErrorResponse("Unable to authenticate certificate. Please use standard authentication.")));
							return;
								
							break;
						
						// authenticate using basic / the pass-through default	
						case "basic":
						default:
							// basic is the default authentication type
							if (isset($_SERVER['PHP_AUTH_USER']) && isset($_SERVER['PHP_AUTH_PW'])){
 
								$username = $_SERVER['PHP_AUTH_USER'];
								$password = $_SERVER['PHP_AUTH_PW'];
							 	
							 	// here you would authenticate against an access manager of some sort
								if ($username == 'user' && $password == 'basic'){
									$loginSuccessful = true;
								}
							}
							 
							// Login passed successful?
							if (!$loginSuccessful){

								header('WWW-Authenticate: Basic realm="'.$realm.'"');
								header('HTTP/1.0 401 Unauthorized');
							 
								die ("Authentication Cancelled.");
							 
							} else {
							 	
								// generate the success response, including the cert if they are registering the device
							 	$register = (bool)$_REQUEST['register'];
							 	$passphrase = $_REQUEST['pin'];
								sendAPIResponse(200, json_encode(generateSuccessfulAuthenticationResponse($register, $passphrase)));
							}
														
							break;
					}
					
					return;

				}
			
			// user accounts request
			} else if ($method == "accounts") {
				
				if ($request_method == "GET") {
					
					// generate the IV
					$iv = generateInitVectorOfLength(16);
					
					// return an array of bank accounts for the user
					$accounts = array();
					
					// add the various accounts
					$savings['name'] = "Savings";
					$savings['number'] = "456";
					$savings['balance'] = "13000.24";
					
					$checking['name'] = "Checking";
					$checking['number'] = "123";
					$checking['balance'] = "1300.24";
					
					$retirement['name'] = "Retirement 401K";
					$retirement['number'] = "789";
					$retirement['balance'] = "130000.24";
					
					array_push($accounts, $savings);
					array_push($accounts, $checking);
					array_push($accounts, $retirement);
					
					// create MAC from accounts data
					$mac = hash_hmac("sha256", json_encode($accounts), $HMAC_KEY);
					
					// AES encryption
					$encryptedPayload = mcrypt_encrypt(MCRYPT_RIJNDAEL_128, $AES_KEY, addEncryptionPadding(json_encode($accounts)), MCRYPT_MODE_CBC, $iv);
					
					/*
					   DES encryption - for example purposes
					   $encryptedPayload = mcrypt_encrypt(MCRYPT_3DES, $desKey, addEncryptionPadding(json_encode($accounts)), MCRYPT_MODE_CBC, $iv);
					*/
					
					// generate response
					$response['iv'] = $iv;
					$response['mac'] = $mac;
					$response['payload'] = base64_encode($encryptedPayload);
					
					sendAPIResponse(200,json_encode($response));
					return;
				
				}
			}
			
			// return error
			sendBadAPIRequest();
			return;
			
			break;
			
		case "account":
			
			if ($method == "transferfunds") {
				
				if ($request_method == "POST") {		
					
					$postData = json_decode(@file_get_contents('php://input'));
					$inboundMac = $postData->mac;
					$iv = base64_decode($postData->iv);
					$payload = $postData->payload;
					
					// decrypt the payload
					$non_res = mcrypt_decrypt(MCRYPT_RIJNDAEL_128, $AES_KEY, base64_decode($payload), MCRYPT_MODE_CBC, $iv);
					$decrypted = $non_res;
					$dec_s2 = strlen($decrypted);
					$padding = ord($decrypted[$dec_s2-1]);
					$decrypted = substr($decrypted, 0, -$padding);
					
					// convert decrypted payload to JSON
					$decryptedPayloadJSON = json_decode($decrypted);
					
					// read the transfer information
					$toAccount = $decryptedPayloadJSON->toAccount;
					$fromAccount = $decryptedPayloadJSON->fromAccount;
					$amount = $decryptedPayloadJSON->amount;
					$transferDate = $decryptedPayloadJSON->transferDate;
					$transferNotes = $decryptedPayloadJSON->transferNotes;
					
					// grab toAccount, fromAccount, amount, transferDate (in that order) and create hmac
					$macCandidate = $toAccount.$fromAccount.$amount.$transferDate;
					$derivedMac = hash_hmac("sha256", $macCandidate, $HMAC_KEY);
					
					// validate inbound hmac matches our derived value
					if ($inboundMac != $derivedMac) {
						sendAPIResponse(400, json_encode(buildErrorResponse("Message Integrity Error")));
						return;
					}
					
					// here we would perform our transfer and validate it was successful prior to issuing 200
					sendAPIResponse(200);
					return;
				
				}
			
			}
			
			// return error
			sendBadAPIRequest();
			return;
			break;
			
		default:
			
			sendBadAPIRequest();
			break;
	
	}
?>