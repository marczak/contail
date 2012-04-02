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
  [super drawRect:rect];
  
  // Draw a black background.
	[[NSColor blackColor] set];
	[NSBezierPath fillRect:[self bounds]];
  NSSize windowSize = [[[self window] contentView] frame].size;
  float fontSize = windowSize.height/75.0f;  
  
  // Initialize the text matrix
	CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
  
  // Set the drawing rect
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathAddRect(path, NULL, self.bounds);

  // Grab the newest data
  buffer = [fileHandle readDataToEndOfFile];
  if ([buffer length] > 0) {
    // remove a 'buffer length' from front of string
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
  // Will that overflow the text area?
  NSSize logSize = [currentData sizeWithAttributes:textAttrs];
  while (logSize.height > windowSize.height) {
    // We need to lose some more from the top
    NSRange range;
    range.location = 0;
    range.length = 180;
    [currentData deleteCharactersInRange:range];
    logSize = [currentData sizeWithAttributes:textAttrs];
  }

  CTFramesetterRef framesetter =
  CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
  CTFrameRef frame =
  CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attString length]), path, NULL);
  
  CTFrameDraw(frame, context);
  
  // Plain old draw methods for status line
  NSColor *fg = [NSColor greenColor];
  
  NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
  [dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
  [dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss z"];
  [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
  NSDate *date = [NSDate date];
  NSString *dateString = [dateFormatter stringFromDate:date];
  
  NSFont* font = [NSFont fontWithName: @"Apple2Forever" size:fontSize];
  
  NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                         font, NSFontAttributeName,
                         fg, NSForegroundColorAttributeName, nil];
  
  NSSize statusSize = [dateString sizeWithAttributes:attrs];
  
  [dateString drawAtPoint:NSMakePoint(windowSize.width - statusSize.width, windowSize.height - (windowSize.height - statusSize.height)) withAttributes:attrs];
  
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
  if (debug) {
    NSLog(@"Got vers string from bundle: %@", vers);
  }
	[versionText setStringValue:vers];
  [filePathLabel setStringValue:filePath];
	
	NSUserDefaults *def = [ScreenSaverDefaults defaultsForModuleWithName:
                         [[NSBundle bundleForClass:[self class]] bundleIdentifier]];
	NSUserDefaultsController *controller = [[NSUserDefaultsController alloc] initWithDefaults:def initialValues:nil];
	[configController setContent:controller];
	[controller release];
}


- (NSWindow*)configureSheet
{
  if( !configSheet ) {
    if (debug)
      NSLog(@"Loading Xib.");
		[self loadConfigurationXib];
  }
	
	return configSheet;
}


- (IBAction)configOK:(id)sender
{
  if (debug) {
    NSLog(@"In configOK");
    NSLog(@"Saving controller: %@", [(NSUserDefaultsController *)[configController content] values]);
  }
  [configController setValue:filePath forKeyPath:@"content.values.filePath"];
	[(NSUserDefaultsController *)[configController content] save:sender];
	[self loadFromUserDefaults];
  
	[NSApp endSheet:configSheet];
  
	[self stopAnimation];
	[self startAnimation];
}


- (void)setDefaultValues
{
	NSUserDefaults *def = [ScreenSaverDefaults defaultsForModuleWithName:[[NSBundle bundleForClass:[self class]] bundleIdentifier]];
	[def registerDefaults:
   [NSDictionary dictionaryWithObjectsAndKeys:
    [NSString stringWithString:@"/var/log/opendirectoryd.log"], @"filePath",
    [NSNumber numberWithBool:NO], @"debug",
    nil]];
}


- (void)loadFromUserDefaults
{
  NSData *buffer;
  long curOffset;
  long rewindAmt;

	NSUserDefaults *def = [ScreenSaverDefaults defaultsForModuleWithName:[[NSBundle bundleForClass:[self class]] bundleIdentifier]];
  if (debug) {
    NSLog(@"In loadFromUserDefaults - entering with filePath of %@.", filePath);
    NSLog(@"Registered def: %@", def);
  }
  debug = [def boolForKey:@"debug"];
  filePath = [def stringForKey:@"filePath"];
  if (debug) {
    NSLog(@"Loaded filePath from defaults - got: %@", filePath);
  }

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
  NSOpenPanel *panel = [[NSOpenPanel openPanel] retain];
  [panel setCanChooseDirectories:NO];
  [panel setAllowsMultipleSelection:NO];
  [panel setMessage:@"Choose the file to display."];
  [filePathLabel setStringValue:filePath];
  // Let the user select any text document.
  [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"txt", @"log", @"out", nil]];
  
  [panel beginWithCompletionHandler:^(NSInteger result){
    if (result == NSFileHandlingPanelOKButton) {
      filePath = [[[panel URLs] objectAtIndex:0] path];
      if (debug) {
        NSLog(@"From panel: %@", [[[panel URLs] objectAtIndex:0] path]);
      }
      [filePathLabel setStringValue:[[[panel URLs] objectAtIndex:0] path]];
    }
    
    [panel release];
  }];
}

@end