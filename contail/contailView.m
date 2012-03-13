//
//  contailView.m
//  contail
//
//  Created by Edward Marczak on 3/9/12.
//  Copyright (c) 2012 Radiotope. All rights reserved.
//

#import "contailView.h"

@implementation contailView

@synthesize filePath;

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
  self = [super initWithFrame:frame isPreview:isPreview];
  if (self) {
//    [self setDefaultValues];
//    [self loadFromUserDefaults];
//    currentData = [[NSMutableString alloc] init];
    [self setAnimationTimeInterval:1.3];
  }
  return self;
}

- (void)startAnimation
{
  [super startAnimation];
}

- (void)stopAnimation
{
  [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
  NSError *err = nil;
  [super drawRect:rect];
  
  // Draw a black background.
	[[NSColor blackColor] set];
	[NSBezierPath fillRect:[self bounds]];
  NSSize windowSize = [[[self window] contentView] frame].size;
  float fontSize = windowSize.height/75.0f;  
  
  // Initialize the text matrix to a known value
	CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
  
  // Set the drawing rect
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathAddRect(path, NULL, self.bounds);
  
  NSString *logs = [[NSString alloc] initWithContentsOfFile:@"/etc/bashrc"
                                                   encoding:NSASCIIStringEncoding
                                                      error:&err];
  
//  buffer = [fileHandle readDataToEndOfFile];
//  if ([buffer length] > 0) {
//    // remove buffer length from front of string
//    NSRange range;
//    range.location = 0;
//    range.length = [buffer length];
//    [currentData deleteCharactersInRange:range];
//    // Append the new data
//    NSString *newData = [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding];
//    [currentData appendString:newData];
//  }
  
  CTFontRef consoleFont = CTFontCreateWithName(CFSTR("Apple2Forever"), fontSize, NULL);
  NSDictionary *textAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSColor greenColor], kCTForegroundColorAttributeName,
                             consoleFont, kCTFontAttributeName,
                             [NSColor greenColor], (NSString *)kCTStrokeColorAttributeName,
                             nil];
  NSAttributedString *attString = [[NSAttributedString alloc] initWithString:logs
                                                                  attributes:textAttrs];
  CTFramesetterRef framesetter =
  CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
  CTFrameRef frame =
  CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attString length]), path, NULL);
  
  CTFrameDraw(frame, context);
  
  CFRelease(consoleFont);
  CFRelease(frame);
  CFRelease(path);
  CFRelease(framesetter);
}

- (void)animateOneFrame
{
  [self setNeedsDisplay:YES];
  return;
}

#pragma mark - Configuration Methods

- (BOOL)hasConfigureSheet
{
  return NO;
}

/*
- (BOOL)hasConfigureSheet
{
  return YES;
}


- (void)loadConfigurationXib
{
  if (debug) {
    NSLog(@"In loadConfigurationXib");
  }
	[NSBundle loadNibNamed: @"configureSheet" owner: self];
	
	NSString *vers = [[NSBundle bundleForClass: [self class]] objectForInfoDictionaryKey: @"CFBundleVersion"];
	vers = [NSString stringWithFormat: @"version %@", vers];
	[versionText setStringValue: vers];
	
	NSUserDefaults *def = [ScreenSaverDefaults defaultsForModuleWithName:
                         [[NSBundle bundleForClass:[self class]] bundleIdentifier]];
	NSUserDefaultsController *controller = [[NSUserDefaultsController alloc] initWithDefaults:def initialValues:nil];
	[configController setContent: controller];
	[controller release];
}


- (NSWindow*)configureSheet
{
  if(!configureSheet) {
    if (debug) {
      NSLog(@"Loading Xib.");
    }
		[self loadConfigurationXib];
  }
	
	return configureSheet;
  return nil;
}


- (IBAction)configOK:(id)sender
{
  if (debug) {
    NSLog(@"In configOK");
  }
	[(NSUserDefaultsController *)[configController content] save:sender];
	[self loadFromUserDefaults];
  
	[NSApp endSheet:configureSheet];
  
	[self stopAnimation];
	[self startAnimation];
}


- (void)setDefaultValues
{
	NSUserDefaults *def = [ScreenSaverDefaults defaultsForModuleWithName: [[NSBundle bundleForClass: [self class]] bundleIdentifier]];
	[def registerDefaults:
   [NSDictionary dictionaryWithObjectsAndKeys:
    [NSString stringWithString:@"/var/log/opendirectoryd.log"], @"filePath",
    [NSNumber numberWithBool:NO], @"debug",
    nil]];
}


- (void)loadFromUserDefaults
{
	NSUserDefaults *def = [ScreenSaverDefaults defaultsForModuleWithName: [[NSBundle bundleForClass: [self class]] bundleIdentifier]];
  debug = [def boolForKey: @"debug"];
  filePath = [def stringForKey:@"filePath"];
  fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
  [fileHandle seekToEndOfFile];
  [fileHandle seekToFileOffset:[fileHandle offsetInFile] - 5000];
  buffer = [fileHandle readDataToEndOfFile];
  currentData = [[NSMutableString alloc] initWithData:buffer encoding:NSUTF8StringEncoding];
}


- (IBAction)askUserForTextFile:(id)sender {
  NSOpenPanel*    panel = [[NSOpenPanel openPanel] retain];
  [panel setCanChooseDirectories:NO];
  [panel setAllowsMultipleSelection:NO];
  [panel setMessage:@"Choose the file to display."];
  
  // Let the user select any text document.
  [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"txt", @"log", nil]];
  
  [panel beginWithCompletionHandler:^(NSInteger result){
    if (result == NSFileHandlingPanelOKButton) {
      filePath = [[panel URLs] objectAtIndex:0];
      fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
      [fileHandle seekToEndOfFile];
      [fileHandle seekToFileOffset:[fileHandle offsetInFile] - 5000];
      buffer = [fileHandle readDataToEndOfFile];
      currentData = [[NSMutableString alloc] initWithData:buffer encoding:NSUTF8StringEncoding];
      NSLog(@"From panel: %@", filePath);
    }
    
    [panel release];
  }];
}

*/

@end
