//
//  contailView.h
//  contail
//
//  Created by Edward Marczak on 3/9/12.
//  Copyright (c) 2012 Radiotope. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>

@interface contailView : ScreenSaverView
{  
  IBOutlet NSWindow *configSheet;
  IBOutlet NSObjectController *configController;
  IBOutlet NSTextField *versionText;
  IBOutlet NSTextField *filePathLabel;
  
//  NSURL *filePath;
  NSString *filePath;
  NSFileHandle *fileHandle;
  NSMutableString *currentData;
  BOOL debug;
}

@property (readwrite, assign) NSString *filePath;

- (void)loadConfigurationXib;
- (IBAction)configOK: (id)sender;
- (void)loadFromUserDefaults;
- (void)setDefaultValues;
- (IBAction)askUserForTextFile:(id)sender;

@end
