# -*- coding: utf-8 -*-
# Copyright 2016 Mobicage NV
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# @@license_version:1.1@@

import os
import pprint
import re
import shutil
import subprocess
import sys
from PIL import Image

import yaml

CURRENT_DIR = os.path.dirname(os.path.realpath(__file__))
APPS_REPO_DIR = os.path.join(CURRENT_DIR, "..", "..", "apps", 'res')
sys.path.append(os.path.join(CURRENT_DIR, "..", "..", "rogerthat-build", 'src'))
import app_utils

MAIN_APP_ID = "rogerthat"

APP_TYPE_ROGERTHAT = 0
APP_TYPE_CITYPAPP = 1
APP_TYPE_ENTERPRISE = 2
APP_TYPE_CONTENT_BRANDING = 3
APP_TYPE_YSAAA = 4  # not implemented yet

HOME_SCREEN_STYLE_TABS = "tabs"
HOME_SCREEN_STYLE_2X3 = "2x3"
HOME_SCREEN_STYLE_3X3 = "3x3"

FRIENDS_CAPTION_FRIENDS = "friends"
FRIENDS_CAPTION_COLLEAGUES = "colleagues"
FRIENDS_CAPTION_CONTACTS = "contacts"


def generate_homescreen_view_controller():
    # reading license text from tools repository
    LICENSE = app_utils.get_license_header()

    ##### ICONS & MCTHomescreen.m #############################################
    color = doc["HOMESCREEN"]["color"]
    output = u'''%s

// This file is generated. DO NOT MODIFY

#import "MCTComponentFramework.h"
#import "MCTHomeScreenVC.h"
#import "MCTLocationUsageVC.h"

@implementation MCTHomeScreenVC

@synthesize items = items_;

- (void)viewDidLoad
{
    self.items = [NSMutableDictionary dictionary];
''' % LICENSE

    main_screen_contains_friends = False
    main_screen_contains_profile = False
    for item in doc["HOMESCREEN"]["items"]:
        base_filename = "menu_%sx%s" % (item["position"][0], item["position"][1])
        app_utils.download_icon(item["icon"], item.get("color", color), 512,
                                get_image_destination_path("%s.png" % base_filename))
        base_size = 58 if doc["APP_CONSTANTS"]["APP_TYPE"] == APP_TYPE_CITYPAPP else 90
        for scale in (3, 2, 1):
            filename = base_filename if scale == 1 else (base_filename + "@%sx" % scale)
            app_utils.resize_image(get_image_destination_path("%s.png" % base_filename),
                                   get_image_destination_path("%s.png" % filename),
                                   scale * base_size, scale * base_size)

        if "coords" in item:
            click = 'nil'
            coords = '@[%s]' % ', '.join(["@(%s)" % c for c in item["coords"]])
        else:
            click = '@"%s"' % item["click"]
            coords = 'nil'

            if item["click"] == "friends":
                main_screen_contains_friends = True
            if item["click"] == "profile":
                main_screen_contains_profile = True

        collapse = 'YES' if item.get('collapse', False) else 'NO'

        output += '''
    [self.items setObject:[MCTHomeScreenItem homeScreenItemWithPositionY:%(y)s
                                                                       x:%(x)s
                                                                   label:NSLocalizedString(@"%(label)s", nil)
                                                                   click:%(click)s
                                                                  coords:%(coords)s
                                                                collapse:%(collapse)s]
                   forKey:@"%(y)sx%(x)s"];
''' % dict(y=item["position"][0],
           x=item["position"][1],
           label=item["text"],
           click=click,
           coords=coords,
           collapse=collapse)

    output += '''
    [super viewDidLoad];
}

- (void)startLocationUsage
{
    T_UI();
    MCTIntent *intent = [MCTIntent intentWithAction:kINTENT_LOCATION_START_AUTOMATIC_DETECTION];
    [[MCTComponentFramework intentFramework] broadcastStickyIntent:intent];
}

- (MCTHomeScreenItem *)itemForPositionX:(MCTlong)x y:(MCTlong)y
{
    NSString *key = [NSString stringWithFormat:@"%lldx%lld", y, x];

    if ([self.items containsKey:key]) {
        return [self.items valueForKey:key];
    }
    return nil;
}

@end
'''

    path = os.path.join(CURRENT_DIR, "..", "src-gen")
    with open(os.path.join(path, "MCTHomeScreenVC.m"), 'w+') as f:
        f.write(output.encode('utf-8'))

    return main_screen_contains_friends, main_screen_contains_profile


def update_info_plist(color_scheme, d):
    ##### rogerthat_Info.plist #####################################
    subprocess.check_output('gcc -framework Foundation %s/updateRogerthatInfo.m -o %s/updateRogerthatInfo' % (d, d),
                            shell=True)

    for key in doc["STRINGS"]:
        if key["name"] == "app_name":
            app_name = key["value"]
            break
    else:
        app_name = "Rogerthat"

    use_voip = doc['CLOUD_CONSTANTS'].get('USE_XMPP_KICK_CHANNEL', False) \
            and doc['BUILD_CONSTANTS'].get("USE_VOIP", True)
    use_voip = False  # For now we can never use VOIP because we don't get it submitted in the AppStore
    subprocess.check_output('cd %s; ./updateRogerthatInfo "%s" "%s" "%s" "%s" "%s"'
                            % (d, APP_ID, app_name, doc["APP_CONSTANTS"]["FACEBOOK_APP_ID"],
                               str(use_voip), color_scheme),
                            shell=True)

    ##### rogerthat.xcodeproj/project.pbxproj  #####################################
    build = os.path.join(os.path.dirname(__file__), '..', 'rogerthat.xcodeproj', 'project.pbxproj')
    with open(build, 'r+') as f:
        s = f.read()
        for m in set(re.findall('PRODUCT_NAME = (.*);', s)):
            if '$(TARGET_NAME)' not in m:
                s = s.replace('PRODUCT_NAME = %s;' % m, 'PRODUCT_NAME = "%s";' % APP_ID)

        iphoneos_deployment_target = doc["BUILD_CONSTANTS"].get("IPHONEOS_DEPLOYMENT_TARGET", None)
        if iphoneos_deployment_target:
            for m in set(re.findall('IPHONEOS_DEPLOYMENT_TARGET = (.*);', s)):
                s = s.replace('IPHONEOS_DEPLOYMENT_TARGET = %s;' % m,
                              'IPHONEOS_DEPLOYMENT_TARGET = %s;' % iphoneos_deployment_target)

        device_type = doc["BUILD_CONSTANTS"].get("DEVICE_TYPE", "phone")
        for m in set(re.findall('TARGETED_DEVICE_FAMILY = (.*);', s)):
            if device_type == "phone":
                s = s.replace('TARGETED_DEVICE_FAMILY = %s;' % m, 'TARGETED_DEVICE_FAMILY = 1;')
            elif device_type == "tablet":
                s = s.replace('TARGETED_DEVICE_FAMILY = %s;' % m, 'TARGETED_DEVICE_FAMILY = 2;')
            else:
                raise Exception("Could not apply DEVICE_TYPE '%s'" % device_type)

        for m in set(re.findall('ASSETCATALOG_COMPILER_APPICON_NAME = (.*);', s)):
            if device_type == "phone":
                s = s.replace('ASSETCATALOG_COMPILER_APPICON_NAME = %s;' % m,
                              'ASSETCATALOG_COMPILER_APPICON_NAME = "AppIcon-phone";')
            elif device_type == "tablet":
                s = s.replace('ASSETCATALOG_COMPILER_APPICON_NAME = %s;' % m,
                              'ASSETCATALOG_COMPILER_APPICON_NAME = "AppIcon-tablet";')
            else:
                raise Exception("Could not apply DEVICE_TYPE '%s'" % device_type)

        for m in set(re.findall('ASSETCATALOG_COMPILER_LAUNCHIMAGE_NAME = (.*);', s)):
            if device_type == "phone":
                s = s.replace('ASSETCATALOG_COMPILER_LAUNCHIMAGE_NAME = %s;' % m,
                              'ASSETCATALOG_COMPILER_LAUNCHIMAGE_NAME = "LaunchImage-phone";')
            elif device_type == "tablet":
                s = s.replace('ASSETCATALOG_COMPILER_LAUNCHIMAGE_NAME = %s;' % m,
                              'ASSETCATALOG_COMPILER_LAUNCHIMAGE_NAME = "LaunchImage-tablet";')
            else:
                raise Exception("Could not apply DEVICE_TYPE '%s'" % device_type)

        if device_type == "tablet":
            for m in set(re.findall('VALID_ARCHS = (.*);', s)):
                valid_archs = m.replace("armv7 ", "")
                s = s.replace('VALID_ARCHS = %s;' % m, 'VALID_ARCHS = %s;' % valid_archs)

        f.seek(0)
        f.write(s)
        f.truncate()


def generate_rogerthatconfig():
    ##### RogerthatConfig.plist ###################################
    if doc["APP_CONSTANTS"]["APP_TYPE"] == "rogerthat":
        app_type = APP_TYPE_ROGERTHAT
    elif doc["APP_CONSTANTS"]["APP_TYPE"] == "cityapp":
        app_type = APP_TYPE_CITYPAPP
    elif doc["APP_CONSTANTS"]["APP_TYPE"] == "enterprise":
        app_type = APP_TYPE_ENTERPRISE
    elif doc["APP_CONSTANTS"]["APP_TYPE"] == "content_branding":
        app_type = APP_TYPE_CONTENT_BRANDING
        if not doc['CLOUD_CONSTANTS'].get("USE_XMPP_KICK_CHANNEL", False):
            raise Exception("XMPP_KICK_CHANNEL must be enabled for content_branding")
    else:
        raise Exception("Unknown APP_TYPE: %s" % doc["APP_CONSTANTS"]["APP_TYPE"])

    home_screen_style = doc.get('HOMESCREEN', dict()).get('style')
    if home_screen_style is None:
        if app_type == APP_TYPE_CITYPAPP:
            home_screen_style = HOME_SCREEN_STYLE_3X3
        elif app_type == APP_TYPE_ENTERPRISE:
            home_screen_style = HOME_SCREEN_STYLE_2X3
        else:
            home_screen_style = HOME_SCREEN_STYLE_TABS

    if home_screen_style == HOME_SCREEN_STYLE_TABS:
        main_screen_contains_friends = True
        main_screen_contains_profile = False
    else:
        main_screen_contains_friends, main_screen_contains_profile = generate_homescreen_view_controller()

    d = os.path.dirname(os.path.realpath(__file__))
    subprocess.check_output('gcc -framework Foundation %s/updateRogerthatConfig.m -o %s/updateRogerthatConfig' % (d, d),
                            shell=True)
    friends_enabled = doc["APP_CONSTANTS"].get("FRIENDS_ENABLED", True)
    friends_caption = doc["APP_CONSTANTS"].get("FRIENDS_CAPTION", None)
    if friends_caption is None:
        if app_type == APP_TYPE_ENTERPRISE:
            friends_caption = FRIENDS_CAPTION_COLLEAGUES
        else:
            friends_caption = FRIENDS_CAPTION_FRIENDS
    color_settings = doc.get('COLORS', dict())
    color_scheme = color_settings.get('homescreen_color_scheme', 'light')
    app_tint_color = color_settings.get("app_tint_color")
    if app_tint_color and not app_tint_color.startswith("#"):
        app_tint_color = "#%s" % app_tint_color
    profile_settings = doc.get('PROFILE', dict())
    about_settings = doc.get("ABOUT_ACTIVITY", dict())
    about_website = about_settings.get('website', None)
    about_website_url = about_settings.get('website_url', None)
    about_email = about_settings.get('email', None)
    about_twitter = about_settings.get('twitter', None)
    about_twitter_app_url = about_settings.get('twitter_app_url', None)
    about_twitter_url = about_settings.get('twitter_url', None)
    about_facebook = about_settings.get('facebook', None)
    about_facebook_url = about_settings.get('facebook_url', None)
    if not about_website:
        if app_type == APP_TYPE_CITYPAPP:
            about_website = "www.onzestadapp.be"
        else:
            about_website = "www.rogerthat.net"
    if not about_website_url:
        if app_type == APP_TYPE_CITYPAPP:
            about_website_url = "http://www.onzestadapp.be"
        else:
            about_website_url = "http://www.rogerthat.net"
    if not about_email:
        if app_type == APP_TYPE_CITYPAPP:
            about_email = "info@onzestadapp.be"
        else:
            about_email = "info@mobicage.com"
    if not about_twitter:
        if app_type == APP_TYPE_CITYPAPP:
            about_twitter = "@onzestadapp"
        else:
            about_twitter = "@rogerthat"
    if not about_twitter_app_url:
        if app_type == APP_TYPE_CITYPAPP:
            about_twitter_app_url = "twitter://user?screen_name=onzestadapp"
        else:
            about_twitter_app_url = "twitter://user?screen_name=rogerthat"
    if not about_twitter_url:
        if app_type == APP_TYPE_CITYPAPP:
            about_twitter_url = "https://twitter.com/onzestadapp"
        else:
            about_twitter_url = "https://twitter.com/rogerthat"
    if not about_facebook:
        if app_type == APP_TYPE_CITYPAPP:
            about_facebook = "/onzestadapp"
        else:
            about_facebook = "/rogerthatplatform"
    if not about_facebook_url:
        if app_type == APP_TYPE_CITYPAPP:
            about_facebook_url = "https://www.facebook.com/onzestadapp"
        else:
            about_facebook_url = "https://www.facebook.com/rogerthatplatform"

    # create space-separated string of args, of which every arg is surrounded by double quotes
    args_string = ' '.join(['"%s"' % x for x in (doc["APP_CONSTANTS"].get("APP_EMAIL"),
                                                 "#%s" % color_settings.get("homescreen_background", "FFFFFF"),
                                                 "#%s" % color_settings.get("homescreen_text", "646464"),
                                                 color_scheme,
                                                 int(doc['APP_CONSTANTS'].get('FULL_WIDTH_HEADERS', False)),
                                                 app_tint_color,
                                                 app_type,
                                                 home_screen_style,
                                                 doc["CLOUD_CONSTANTS"]["HTTPS_BASE_URL"],
                                                 doc["CLOUD_CONSTANTS"]["HTTP_BASE_URL"],
                                                 int(doc["CLOUD_CONSTANTS"]["USE_TRUSTSTORE"]),
                                                 int(friends_enabled),
                                                 friends_caption,
                                                 int(friends_enabled and not main_screen_contains_friends),
                                                 int(not main_screen_contains_profile),
                                                 int(doc.get("HOMESCREEN", dict()).get("footer", False)),
                                                 "kick.%s" % doc["CLOUD_CONSTANTS"]["XMPP_DOMAIN"],
                                                 ",".join(map(str, doc['APP_CONSTANTS'].get(
                                                     'SEARCH_SERVICES_IF_NONE_CONNECTED', []))),
                                                 ",".join(map(str, profile_settings.get('DATA_FIELDS', []))),
                                                 int(profile_settings.get('SHOW_GENDER_AND_BIRTHDATE', True)),
                                                 int(doc['CLOUD_CONSTANTS'].get('USE_XMPP_KICK_CHANNEL', False)),
                                                 int(doc["APP_CONSTANTS"].get("FACEBOOK_REGISTRATION", False)),
                                                 int(doc["APP_CONSTANTS"].get('MESSAGES_SHOW_REPLY_VS_UNREAD_COUNT',
                                                                              True)),
                                                 doc["APP_CONSTANTS"]['REGISTRATION_MAIN_SIGNATURE'],
                                                 doc["APP_CONSTANTS"]['REGISTRATION_EMAIL_SIGNATURE'],
                                                 doc["APP_CONSTANTS"]['REGISTRATION_PIN_SIGNATURE'],
                                                 doc["APP_CONSTANTS"]['EMAIL_HASH_ENCRYPTION_KEY'].replace('%s', '%@'),
                                                 int(doc['APP_CONSTANTS'].get('REGISTRATION_TYPE', 1)),
                                                 doc['APP_CONSTANTS'].get('REGISTRATION_TYPE_OAUTH_DOMAIN', ""),
                                                 about_website,
                                                 about_website_url,
                                                 about_email,
                                                 about_twitter,
                                                 about_twitter_app_url,
                                                 about_twitter_url,
                                                 about_facebook,
                                                 about_facebook_url
                                                 )
                            ])
    print 'Executing ./updateRogerthatConfig %s' % args_string
    subprocess.check_output('cd %s; ./updateRogerthatConfig %s' % (d, args_string),
                            shell=True)
    return color_scheme, d


def get_image_destination_path(filename):
    return os.path.join(CURRENT_DIR, "..", "MCResources", "Art", filename)


def get_localized_image_dir(language):
    return os.path.join(CURRENT_DIR, "..", "MCResources", "%s.lproj" % language, "Art", "%s.lproj" % language)


def resize_more_icon(f, name):
    dest1 = get_image_destination_path('more_%s.png' % name)
    app_utils.resize_image(f, dest1, 35, 35)
    app_utils.increase_canvas(dest1, dest1, 50, 50)

    dest2 = get_image_destination_path('more_%s@2x.png' % name)
    app_utils.resize_image(f, dest2, 70, 70)
    app_utils.increase_canvas(dest2, dest2, 100, 100)


##### START ########################################
if __name__ == '__main__':
    if len(sys.argv) not in (2, 3):
        raise Exception, "app_id is a required argument"

    APP_ID = sys.argv[1]
    ADHOC_BUILD = len(sys.argv) > 2 and sys.argv[2].lower() == "adhoc"
    print 'Preparing', ('AdHoc' if ADHOC_BUILD else 'AppStore'), 'build of', APP_ID

    APP_DIR = os.path.join(APPS_REPO_DIR, APP_ID)
    if not os.path.exists(APP_DIR):
        raise Exception("app_id '%s' not in valid app ids" % APP_ID)

    with open(os.path.join(APP_DIR, "build.yaml"), 'r') as f:
        doc = yaml.load(f)

    print 'BUILD CFG:'
    print pprint.pformat(doc)
    print ''

    #### IMAGES ###################################

    def cp_localized_images(localized_dir):
        for language in os.listdir(localized_dir):
            if language == '.DS_Store':
                continue
            localized_src_dir = os.path.join(localized_dir, language)
            localized_dst_dir = get_localized_image_dir(language)
            for f in os.listdir(localized_src_dir):
                shutil.copy2(os.path.join(localized_src_dir, f),
                             os.path.join(localized_dst_dir, f))

    to_dir = os.path.join(CURRENT_DIR, '..', 'MCResources', 'Art')
    img_dir = os.path.join(APP_DIR, 'images', 'common')
    if os.path.exists(img_dir):
        for name in os.listdir(img_dir):
            srcname = os.path.join(img_dir, name)
            if os.path.isdir(srcname):
                if name != 'localized':
                    raise Exception("Can not move images dir '%s'" % srcname)
                cp_localized_images(srcname)
            else:
                name_ = os.path.splitext(name)[0]
                im1 = Image.open(srcname)
                w1, h1 = im1.size

                for x in [1, 2]:
                    icon_name = '%s%s.png' % (name_, ('@%dx' % x) if x != 1 else '')
                    if x == 1:
                        w2 = int(round(w1 / 3))
                        h2 = int(round(h1 / 3))
                    elif x == 2:
                        w2 = int(round((w1 / 3) * 2))
                        h2 = int(round((h1 / 3) * 2))
                    else:
                        raise Exception("Unsupported image render dimension")
                    app_utils.resize_image(srcname, get_image_destination_path(icon_name), w2, h2)

                shutil.copy2(srcname, get_image_destination_path('%s@3x.png' % name_))

    from_dir = os.path.join(APP_DIR, 'images', 'ios')
    if os.path.exists(from_dir):
        app_utils.copytree(from_dir, to_dir)

    itunes_artwork_png = os.path.join(APP_DIR, "images", "iTunesArtwork.png")
    tmp_itunes_artwork = os.path.join(APP_DIR, "build", "iTunesArtwork.png")

    shutil.copy2(itunes_artwork_png, get_image_destination_path('iTunesArtwork@2x'))
    app_utils.resize_image(itunes_artwork_png, tmp_itunes_artwork, 512, 512)
    shutil.copy2(tmp_itunes_artwork, get_image_destination_path('iTunesArtwork'))

    for base_icon_name, base_size, resolutions in [('Icon-29', 29, [1, 2, 3]),
                                                   ('Icon-40', 40, [1, 2, 3]),
                                                   ('Icon-50', 50, [1, 2]),
                                                   ('Icon-57', 57, [1, 2]),
                                                   ('Icon-60', 60, [1, 2, 3]),
                                                   ('Icon-72', 72, [1, 2]),
                                                   ('Icon-76', 76, [1, 2]),
                                                   ('Icon-83-5', 83.5, [2])]:
        for x in resolutions:
            icon_name = '%s%s.png' % (base_icon_name, ('@%dx' % x) if x != 1 else '')
            size = int(base_size * x)
            app_utils.resize_image(itunes_artwork_png, get_image_destination_path(icon_name), size, size)

    ### Assets catalog ##############################
    for img in ['Icon-29.png',
                'Icon-29@2x.png',
                'Icon-29@3x.png',
                'Icon-40@2x.png',
                'Icon-40@3x.png',
                'Icon-57.png',
                'Icon-57@2x.png',
                'Icon-60@2x.png',
                'Icon-60@3x.png']:
         shutil.copy2(get_image_destination_path(img),
                      os.path.join(CURRENT_DIR, '..', 'rogerthat', 'Images.xcassets', 'AppIcon-phone.appiconset', img))

    for img in ['Icon-29.png',
                'Icon-29@2x.png',
                'Icon-40.png',
                'Icon-40@2x.png',
                'Icon-50.png',
                'Icon-50@2x.png',
                'Icon-72.png',
                'Icon-72@2x.png',
                'Icon-76.png',
                'Icon-76@2x.png',
                'Icon-83-5@2x.png']:
        shutil.copy2(get_image_destination_path(img),
                     os.path.join(CURRENT_DIR, '..', 'rogerthat', 'Images.xcassets', 'AppIcon-tablet.appiconset', img))

    ios_img_src_dir = os.path.join(APP_DIR, 'images', 'ios')
    if os.path.exists(ios_img_src_dir):
        device_type = doc.get("BUILD_CONSTANTS", dict()).get("DEVICE_TYPE", "phone")
        if device_type == "phone":
            for src_img, dst_img in [('Default-568h@2x.png', 'Default-568h@2x.png'),
                                     ('Default-568h@2x.png', 'Default-568h@2x-1.png'),
                                     ('Default-667h@2x.png', 'Default-667h@2x.png'),
                                     ('Default-736h@3x.png', 'Default-736h@3x.png'),
                                     ('Default@2x.png', 'Default@2x.png'),
                                     ('Default@2x.png', 'Default@2x-1.png')]:
                shutil.copy2(os.path.join(ios_img_src_dir, src_img),
                             os.path.join(CURRENT_DIR, '..', 'rogerthat', 'Images.xcassets',
                                          'LaunchImage-phone.launchimage', dst_img))
        elif device_type == "tablet":
            for src_img, dst_img in [('Default-Landscape~ipad.png', 'Default-Landscape~ipad.png'),
                                     ('Default-Landscape@2x~ipad.png', 'Default-Landscape@2x~ipad.png')]:
                shutil.copy2(os.path.join(ios_img_src_dir, src_img),
                             os.path.join(CURRENT_DIR, '..', 'rogerthat', 'Images.xcassets',
                                          'LaunchImage-tablet.launchimage', dst_img))

    #### Provisioning Profiles ###################################
    debug_pp_path = os.path.join(APP_DIR, 'debug.mobileprovision')
    dpp = subprocess.check_output(
        "/usr/libexec/PlistBuddy -c 'Print :UUID' /dev/stdin <<< $(security cms -D -i %s)" % debug_pp_path, shell=True)
    debug_pp_id = dpp.strip()

    release_pp_path = os.path.join(APP_DIR, '%s.mobileprovision' % ('adhoc' if ADHOC_BUILD else 'release'))
    rpp = subprocess.check_output(
        "/usr/libexec/PlistBuddy -c 'Print :UUID' /dev/stdin <<< $(security cms -D -i %s)" % release_pp_path,
        shell=True)
    release_pp_id = rpp.strip()

    print "DEBUG_PP  :", debug_pp_id
    print "RELEASE_PP:", release_pp_id

    base_pp_path = os.path.join(os.path.expanduser('~'), "Library", "MobileDevice", "Provisioning Profiles")

    shutil.copy2(debug_pp_path, os.path.join(base_pp_path, "%s.mobileprovision" % debug_pp_id))
    shutil.copy2(release_pp_path, os.path.join(base_pp_path, "%s.mobileprovision" % release_pp_id))

    project_pbxproj_path = os.path.join(os.path.dirname(__file__), '..', 'rogerthat.xcodeproj', 'project.pbxproj')

    with open(project_pbxproj_path, "r") as f:
        data = f.read()

    a = re.findall("name = Debug|name = Release", data)
    b = re.findall("PROVISIONING_PROFILE = .*", data)

    for ind, pp in enumerate(a):
        if "Debug" in pp:
            print "Debug: %s" % ind
            pp_id = debug_pp_id
        else:
            print "Release: %s" % ind
            pp_id = release_pp_id

        old_pp_id = b[ind].split('"', 3)[1]
        print old_pp_id

        if old_pp_id:
            with open(project_pbxproj_path, 'r+') as f:
                s = f.read()
                s = re.sub(old_pp_id, pp_id, s)
                f.seek(0)
                f.write(s)
                f.truncate()

    #### MORE IMAGES ###################################
    color = doc["MORE_ACTIVITY"]["color"]

    for filename_in_app, icon_name in [('network_monitor', 'fa-commenting-o'),
                                       ('gear', 'fa-tachometer'),
                                       ('messenger', 'fa-users'),
                                       ('id', 'fa-user')]:
        app_utils.download_icon(icon_name, color, 512,
                                os.path.join(APP_DIR, "build", "%s.png" % filename_in_app))
        resize_more_icon(os.path.join(APP_DIR, "build", "%s.png" % filename_in_app), filename_in_app)

    color_scheme, d = generate_rogerthatconfig()
    if APP_ID != MAIN_APP_ID:
        update_info_plist(color_scheme, d)

    ##### TRUSTSORE ########################################
    if doc["CLOUD_CONSTANTS"]["USE_TRUSTSTORE"]:
        app_utils.create_trusstore_der(APP_ID, os.path.join(CURRENT_DIR, "..", "MCResources", "root.crt"))
