//
//  Utils.m
//  HangarEventos
//
//  Created by Francisco Buitrago Pavón on 03/05/13.
// Copyright (c) 2013 Francisco Buitrago Pavon. All rights reserved.
//






#import "Utils.h"
#import "Reachability.h"
@implementation Utils

+ (BOOL)checkConnection{
    
    
    Reachability* reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    if(remoteHostStatus == NotReachable) 
    { 
        UIAlertView *alertError = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tituloSinConexionInternet",@"") message:NSLocalizedString(@"textoSinConexionInternet",@"") delegate:self cancelButtonTitle:NSLocalizedString(@"Ok",@"") otherButtonTitles:nil];
        [alertError show];
        return TRUE;
        
    }else{
        
        return FALSE;
    }

    
}




@end
