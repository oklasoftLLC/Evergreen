//
//  NSData+RSParser.m
//  RSParser
//
//  Created by Brent Simmons on 6/24/17.
//  Copyright © 2017 Ranchero Software, LLC. All rights reserved.
//

#import <RSParser/NSData+RSParser.h>

/* TODO: find real-world cases where the isProbably* cases fail when they should succeed, and add them to tests.*/

static BOOL bytesAreProbablyHTML(const char *bytes, NSUInteger numberOfBytes);
static BOOL bytesAreProbablyXML(const char *bytes, NSUInteger numberOfBytes);
static BOOL bytesStartWithStringIgnoringWhitespace(const char *string, const char *bytes, NSUInteger numberOfBytes);
static BOOL didFindString(const char *string, const char *bytes, NSUInteger numberOfBytes);

@implementation NSData (RSParser)

- (BOOL)isProbablyHTML {

	return bytesAreProbablyHTML(self.bytes, self.length);
}

- (BOOL)isProbablyXML {

	return bytesAreProbablyXML(self.bytes, self.length);
}

- (BOOL)isProbablyJSON {

	return bytesStartWithStringIgnoringWhitespace("{", self.bytes, self.length);
}

- (BOOL)isProbablyJSONFeed {

	if (![self isProbablyJSON]) {
		return NO;
	}
	return didFindString("https://jsonfeed.org/version/", self.bytes, self.length);
}

- (BOOL)isProbablyRSSInJSON {

	if (![self isProbablyJSON]) {
		return NO;
	}
	const char *bytes = self.bytes;
	NSUInteger length = self.length;
	return didFindString("rss", bytes, length) && didFindString("channel", bytes, length) && didFindString("item", bytes, length);
}

- (BOOL)isProbablyRSS {

	if (![self isProbablyXML]) {
		return NO;
	}

	return didFindString("<rss", self.bytes, self.length);
}

- (BOOL)isProbablyAtom {

	if (![self isProbablyXML]) {
		return NO;
	}

	return didFindString("<feed", self.bytes, self.length);
}

@end


static BOOL didFindString(const char *string, const char *bytes, NSUInteger numberOfBytes) {

	char *foundString = strnstr(bytes, string, numberOfBytes);
	return foundString != NULL;
}

static BOOL bytesStartWithStringIgnoringWhitespace(const char *string, const char *bytes, NSUInteger numberOfBytes) {

	NSUInteger i = 0;
	for (i = 0; i < numberOfBytes; i++) {

		const char ch = bytes[i];
		if (ch == ' ' || ch == '\r' || ch == '\n' || ch == '\t') {
			continue;
		}

		if (ch == string[0]) {
			return strnstr(bytes, string, numberOfBytes) == bytes + i;
		}
		break;
	}
	return NO;
}

static BOOL bytesAreProbablyHTML(const char *bytes, NSUInteger numberOfBytes) {

	if (didFindString("<html", bytes, numberOfBytes)) {
		return YES;
	}
	if (didFindString("<HTML", bytes, numberOfBytes)) {
		return YES;
	}

	if (didFindString("<body", bytes, numberOfBytes)) {
		return YES;
	}
	if (didFindString("<meta", bytes, numberOfBytes)) {
		return YES;
	}

	if (didFindString("<", bytes, numberOfBytes)) {
		if (didFindString("doctype html", bytes, numberOfBytes)) {
			return YES;
		}
		if (didFindString("DOCTYPE html", bytes, numberOfBytes)) {
			return YES;
		}
		if (didFindString("DOCTYPE HTML", bytes, numberOfBytes)) {
			return YES;
		}
	}

	return NO;
}

static BOOL bytesAreProbablyXML(const char *bytes, NSUInteger numberOfBytes) {

	return bytesStartWithStringIgnoringWhitespace("<?xml", bytes, numberOfBytes);
}

