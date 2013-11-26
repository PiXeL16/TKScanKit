//
//  TKScanKit
//
//  Copyright (c) 2013 Taras Kalapun. All rights reserved.
//

#import "ScanditSDKProvider.h"


#ifdef COCOAPODS_POD_AVAILABLE_ScanditSDK
#import "ScanditSDKBarcodePicker.h"
#import "ScanditSDKOverlayController.h"

@interface ScanditSDKProvider ()<ScanditSDKOverlayControllerDelegate>

@end

#endif

@implementation ScanditSDKProvider
#if TKSK_SCANDITSDK_EXISTS && defined(COCOAPODS_POD_AVAILABLE_ScanditSDK)

@synthesize scannerController=_scannerController;

- (UIViewController *)scannerController
{
    if (!_scannerController) {
        if (!self.appKey) {
            self.appKey = @"yIEPYlHWEeOXIVmiVOy7cX4H1tURXXfLg8TJoRK4TbA";
        }
        ScanditSDKBarcodePicker *vc = [[ScanditSDKBarcodePicker alloc] initWithAppKey:self.appKey];
        
        ScanditSDKOverlayController *ovc = vc.overlayController;
        ovc.delegate = self;
        [ovc setTorchEnabled:NO];
        [ovc showToolBar:NO];
        [ovc showSearchBar:NO];
        
        if (self.isIntegrated) {
            self.dismissOnFinish = NO;
            //[ovc drawViewfinder:NO];

            //[ovc setViewfinderHeight:50 width:50 landscapeHeight:50 landscapeWidth:50];
            //[ovc setViewfinderColor:0.949 green:0.008 blue:0.008];
        }
        
        _scannerController = vc;
    }
    return _scannerController;
}

- (void)start
{
    [(ScanditSDKBarcodePicker *)self.scannerController startScanning];
}

- (void)stop
{
    [(ScanditSDKBarcodePicker *)self.scannerController stopScanning];
}

- (void)setSize:(CGSize)size
{
    [(ScanditSDKBarcodePicker *)self.scannerController setSize:size];
}

- (void)presentScannerFromViewController:(UIViewController *)viewController
{
    ScanditSDKBarcodePicker *vc = self.scannerController;
    
    ScanditSDKOverlayController *ovc = vc.overlayController;
    [ovc setTorchEnabled:YES];
    [ovc setCameraSwitchVisibility:CAMERA_SWITCH_ALWAYS];
    [ovc showToolBar:YES];
    [ovc showSearchBar:YES];
    
    self.dismissOnFinish = YES;
    
    [viewController presentViewController:self.scannerController animated:YES completion:nil];
    [self start];
}

- (UIView *)scanningView
{
    return self.scannerController.view;
}

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController
                     didScanBarcode:(NSDictionary *)barcode
{
    [self stop];
    
    NSString *symbology = [barcode objectForKey:@"symbology"];
    NSString *barcodeStr= [barcode objectForKey:@"barcode"];
    if ([symbology isEqualToString:@"UPC12"] && [barcodeStr length] == 12) {
        // Force UPC12 barcodes to be handled as EAN13 barcodes
        symbology = @"EAN13";
        barcodeStr = [@"0" stringByAppendingString:barcodeStr];
    }
    
    [self finishedScanningWithText:barcodeStr info:barcode];
    
    if (self.isIntegrated) {
        ScanditSDKOverlayController *ovc = [(ScanditSDKBarcodePicker *)self.scannerController overlayController];
        [ovc resetUI];
        [self start];
    }

}

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController
                didCancelWithStatus:(NSDictionary *)status
{
    
    [self stop];
    [self cancelledScanning];
}

- (void)scanditSDKOverlayController:(ScanditSDKOverlayController *)overlayController
                    didManualSearch:(NSString *)text
{
    [[(ScanditSDKBarcodePicker *)self.scannerController overlayController] resetUI];
    
	[self stop];
    
    [self finishedScanningWithText:text info:nil];
    
}

#endif
@end