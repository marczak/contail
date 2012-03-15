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
    [self setDefaultValues];
    [self loadFromUserDefaults];

    [self setAnimationTimeInterval:2.3];
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
  NSData *buffer;
//  NSError *err = nil;
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

  buffer = [fileHandle readDataToEndOfFile];
  if ([buffer length] > 0) {
    // remove buffer length from front of string
    NSRange range;
    range.location = 0;
    range.length = [buffer length];
    [currentData deleteCharactersInRange:range];
    // Append the new data
    NSString *newData = [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding];
    [currentData appendString:newData];
  }
  
  CTFontRef consoleFont = CTFontCreateWithName(CFSTR("Apple2Forever"), fontSize, NULL);
  NSDictionary *textAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSColor greenColor], kCTForegroundColorAttributeName,
                             consoleFont, kCTFontAttributeName,
                             [NSColor greenColor], (NSString *)kCTStrokeColorAttributeName,
                             nil];
  NSAttributedString *attString = [[NSAttributedString alloc] initWithString:currentData
                                                                  attributes:textAttrs];
  CTFramesetterRef framesetter =
  CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
  CTFrameRef frame =
  CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attString length]), path, NULL);
  
  CTFrameDraw(frame, context);
  
  buffer = nil;
  [buffer release];
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
  return YES;
}


- (void)loadConfigurationXib
{
  if (debug) {
    NSLog(@"In loadConfigurationXib");
  }
	[NSBundle loadNibNamed: @"ConfigSheet" owner:self];
	
	NSString *vers = [[NSBundle bundleForClass: [self class]] objectForInfoDictionaryKey: @"CFBundleVersion"];
	vers = [NSString stringWithFormat: @"version %@", vers];
	[versionText setStringValue:vers];
	
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
    [NSString stringWithString:@"/var/log/system.log"], @"filePath",
    [NSNumber numberWithBool:NO], @"debug",
    nil]];
}


- (void)loadFromUserDefaults
{
  NSData *buffer;
  long curOffset;
  long rewindAmt;

	NSUserDefaults *def = [ScreenSaverDefaults defaultsForModuleWithName: [[NSBundle bundleForClass: [self class]] bundleIdentifier]];
  debug = [def boolForKey: @"debug"];
  filePath = [def stringForKey:@"filePath"];

  // Prep the initial read
  fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
  [fileHandle seekToEndOfFile];
  curOffset = [fileHandle offsetInFile];
  // Load 5K or less
  if (curOffset > 5120) {
    rewindAmt = 5120;
  } else {
    rewindAmt = curOffset;
  }
  [fileHandle seekToFileOffset:[fileHandle offsetInFile] - rewindAmt];
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
      NSLog(@"From panel: %@", filePath);
    }
    
    [panel release];
  }];
}

@end
