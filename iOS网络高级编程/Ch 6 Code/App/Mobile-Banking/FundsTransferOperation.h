//
//  FundsTransferOperation.h
//  Mobile Banking
//
//  Created by Nathan Jones on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseOperation.h"

@interface FundsTransferOperation : BaseOperation

@property(nonatomic,strong) NSString *fromAccount;
@property(nonatomic,strong) NSString *toAccount;
@property(nonatomic,assign) double   amount;
@property(nonatomic,strong) NSDate   *transferDate;
@property(nonatomic,strong) NSString *transferNotes;

@end