/*
 * Copyright 2016 Mobicage NV
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * @@license_version:1.1@@
 */

// Based on https://developer.apple.com/library/mac/documentation/NetworkingInternet/Conceptual/NetworkingTopics/Articles/OverridingSSLChainValidationCorrectly.html#//apple_ref/doc/uid/TP40012544-SW1

#import "MCTSecurity.h"

static SecCertificateRef trustedCert = NULL;
static NSString *kAnchorAlreadyAdded = @"AnchorAlreadyAdded";


SecTrustRef addAnchorToTrust(SecTrustRef trust, SecCertificateRef trustedCert)
{
    CFMutableArrayRef newAnchorArray = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    CFArrayAppendValue(newAnchorArray, trustedCert);

    SecTrustSetAnchorCertificates(trust, newAnchorArray);
    SecTrustSetAnchorCertificatesOnly(trust, true); // Only trust the anchors added in the line above

    return trust;
}


@implementation MCTSecurity

+ (void)setTrustedCertificate:(NSData *)trustedCertificateData
{
    if (trustedCertificateData == nil) {
        trustedCert = NULL;
    } else {
        trustedCert = SecCertificateCreateWithData(NULL, (CFDataRef) trustedCertificateData);
        assert(trustedCert != NULL);
    }
}

+ (SecCertificateRef)trustedCertificate
{
    return trustedCert;
}

+ (BOOL)hasTrustedCertificate
{
    return trustedCert != NULL;
}

+ (NSError *)validateStream:(NSStream *)theStream
{
    if (trustedCert != NULL) {
        SecTrustRef trust = (__bridge SecTrustRef)[theStream propertyForKey:(NSString *) kCFStreamPropertySSLPeerTrust];

        /* Because you don't want the array of certificates to keep
         growing, you should add the anchor to the trust list only
         upon the initial receipt of data (rather than every time).
         */
        NSNumber *alreadyAdded = [theStream propertyForKey:kAnchorAlreadyAdded];
        if (!alreadyAdded || ![alreadyAdded boolValue]) {
            trust = addAnchorToTrust(trust, trustedCert);
            [theStream setProperty:[NSNumber numberWithBool:YES] forKey:kAnchorAlreadyAdded];
        }

        SecTrustResultType result = kSecTrustResultInvalid;
        OSStatus status = SecTrustEvaluate(trust, &result);

        if (status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
            // The host is trusted.
        } else {
            NSString *reason;
            if (status != noErr) {
                // This probably means your certificate was broken in some way or your code is otherwise wrong.
                reason = @"The trust evaluation failed for some reason.";
            } else {
                reason = @"The host is not trusted.";
            }
            return [NSError errorWithDomain:@"kCFStreamErrorDomainSSL"
                                       code:kCFStreamErrorDomainSSL
                                   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                             reason, NSLocalizedDescriptionKey,
                                             [NSNumber numberWithInt:status], @"OSStatus",
                                             [NSNumber numberWithInt:result], @"SecTrustResultType",
                                             nil]];
        }
    }

    return nil;
}

@end