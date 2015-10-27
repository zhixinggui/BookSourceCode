//
//  Constants.h
//  Mobile Banking
//
//  Created by Nathan Jones on 2/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

enum {
    NJRequestSigningOptionNone = 0,
    NJRequestSigningOptionQuerystring,
    NJRequestSigningOptionPayload,
    NJRequestSigningOptionHeader
}; typedef NSUInteger NJRequestSigningOption;

#define kNJStatusCode @"NJ-StatusCode"
#define kNJResultSet @"NJ-ResultSet"

#define kAESEncryptionKey @"b36013521d0f5dbea0e4ac1fd7af804a"
#define kDESEncryptionKey @"b36013521d0f5dbea0e4ac1f"
#define kMACKey @"065a62448fb75fce3764dcbe68f9908d"

#define kAccountOperationSuccessful @"AccountOperationSuccessful"
#define kAccountOperationError @"AccountOperationError"

#define kNormalLoginStartNotification @"NormalLoginStart"
#define kNormalLoginSuccessNotification @"NormalLoginSuccess"
#define kNormalLoginFailedNotification @"NormalLoginFailed"

#define kRegisteredLoginStartNotification @"RegisteredLoginStart"
#define kRegisteredLoginSuccessNotification @"RegisteredLoginSuccess"
#define kRegisteredLoginFailedNotification @"RegisteredLoginFailed"

#define kFundsTransferStartNotification @"FundsTransferStart"
#define kFundsTransferSuccessNotification @"FundsTransferSuccess"
#define kFundsTransferFailedNotification @"FundsTransferFailed"