<?php
	function getHeaders(){
	    $headers = array();
	    foreach ($_SERVER as $k => $v){
	        if (substr($k, 0, 5) == "HTTP_") {
	            $k = str_replace('_', ' ', substr($k, 5));
	            $k = str_replace(' ', '-', ucwords(strtolower($k)));
	            $headers[$k] = $v;
	        }	
	    }
	    
	    //print_r ($headers);
	    
	    return $headers;
	}  
	
	function getStatusCodeMessage($status) {
	
	    $codes = Array(
	        100 => 'Continue',
	        101 => 'Switching Protocols',
	        200 => 'OK',
	        201 => 'Created',
	        202 => 'Accepted',
	        203 => 'Non-Authoritative Information',
	        204 => 'No Content',
	        205 => 'Reset Content',
	        206 => 'Partial Content',
	        300 => 'Multiple Choices',
	        301 => 'Moved Permanently',
	        302 => 'Found',
	        303 => 'See Other',
	        304 => 'Not Modified',
	        305 => 'Use Proxy',
	        306 => '(Unused)',
	        307 => 'Temporary Redirect',
	        400 => 'Bad Request',
	        401 => 'Unauthorized',
	        402 => 'Payment Required',
	        403 => 'Forbidden',
	        404 => 'Not Found',
	        405 => 'Method Not Allowed',
	        406 => 'Not Acceptable',
	        407 => 'Proxy Authentication Required',
	        408 => 'Request Timeout',
	        409 => 'Conflict',
	        410 => 'Gone',
	        411 => 'Length Required',
	        412 => 'Precondition Failed',
	        413 => 'Request Entity Too Large',
	        414 => 'Request-URI Too Long',
	        415 => 'Unsupported Media Type',
	        416 => 'Requested Range Not Satisfiable',
	        417 => 'Expectation Failed',
	        500 => 'Internal Server Error',
	        501 => 'Not Implemented',
	        502 => 'Bad Gateway',
	        503 => 'Service Unavailable',
	        504 => 'Gateway Timeout',
	        505 => 'HTTP Version Not Supported'
	    );
	 
	    return (isset($codes[$status])) ? $codes[$status] : '';
	}
	 
	// Helper method to send a HTTP response code/message
	function sendAPIResponse($status = 200, $body = '', $content_type = 'text/html') {
	
	    $status_header = 'HTTP/1.1 ' . $status . ' ' . getStatusCodeMessage($status);
	    header($status_header);
	    header('Content-type: ' . $content_type);
	
	    echo $body;
	
	}
	
	function sendBadAPIRequest () {
		sendAPIResponse(400, json_encode(buildErrorResponse("Bad API request.")));
	}
	
	function buildSuccessResponse ($additional_info = "") {
	
		$result = array(
			"result" => "SUCCESS",
			"additional_info" => $additional_info
		);
		
		return $result;
	
	}
	
	function buildErrorResponse ($additional_info = "") {
		
		$result = array(
			"result" => "ERROR",
			"additional_info" => $additional_info
		);
		
		return $result;
	
	}
	
	function generateSuccessfulAuthenticationResponse($register = false, $passphrase = "") {
		$response = buildSuccessResponse("Authentication Successful");
		$response['token'] = "tokenKey";
		
		if ($register) {
			$p12CertData = generateClientCertificate($passphrase);
			$response['certificate'] = $p12CertData;
		}
		
		return $response;
	}
	
	function isValidToken ($token) {
		if ($token == "tokenKey") {
			return true;
		}
		return false;
	}
	
	// function to parse the http auth header
	function http_digest_parse($txt) {
		// protect against missing data
		$needed_parts = array('nonce'=>1, 'nc'=>1, 'cnonce'=>1, 'qop'=>1, 'username'=>1, 'uri'=>1, 'response'=>1);
		$data = array();
		$keys = implode('|', array_keys($needed_parts));
	
		preg_match_all('@(' . $keys . ')=(?:([\'"])([^\2]+?)\2|([^\s,]+))@', $txt, $matches, PREG_SET_ORDER);
	
		foreach ($matches as $m) {
			$data[$m[1]] = $m[3] ? $m[3] : $m[4];
			unset($needed_parts[$m[1]]);
		}
	
		return $needed_parts ? false : $data;
	}
	
	// generates a generic p12 certificate for our user.
	// this would typically be much more secure and specific
	// to the user that is authenticating
	function generateClientCertificate($passphrase) {
		
		// fill in the distinguished name information
		$dn = array(
		    "countryName" => "US",
		    "stateOrProvinceName" => "Virginia",
		    "localityName" => "Richmond",
		    "organizationName" => "Your Bank",
		    "organizationalUnitName" => "Mobile Banking",
		    "commonName" => "User One Banking Authentication Certificate",
		    "emailAddress" => "name@email.com"
		);
		
		// Generate a new key pair
		$key = openssl_pkey_new();
		$privateKey = "";
		openssl_pkey_export($key, $privateKey);
		
		// Generate a certificate signing request
		$csr = openssl_csr_new($dn, $key);
		
		// This creates a self-signed cert that is valid for 365 days
		$cert = openssl_csr_sign($csr, null, $key, 365, null, "123456");
		
		// Export certificate as encoded p12
		if (openssl_pkcs12_export($cert, $p12Data, $key, $passphrase)) {
			return base64_encode($p12Data);
		}
		
		return false;
	}
	
	function generateInitVectorOfLength($length = 16) {
		$chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
		$size = strlen( $chars );
		for( $i = 0; $i < $length; $i++ ) {
			$iv .= $chars[ rand( 0, $size - 1 ) ];
		}
		
		return $iv;
	}
	
	function addEncryptionPadding($string) {
	     $blocksize = 16;
	     $len = strlen($string);
	     $pad = $blocksize - ($len % $blocksize);
	     $string .= str_repeat(chr($pad), $pad);
	
	     return $string;
	}
?>