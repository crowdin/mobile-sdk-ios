"use strict";(self.webpackChunk_crowdin_mobile_sdk_ios_website=self.webpackChunk_crowdin_mobile_sdk_ios_website||[]).push([[199],{5680:(e,t,n)=>{n.d(t,{xA:()=>d,yg:()=>c});var a=n(6540);function i(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function r(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(e);t&&(a=a.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,a)}return n}function l(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?r(Object(n),!0).forEach((function(t){i(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):r(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function o(e,t){if(null==e)return{};var n,a,i=function(e,t){if(null==e)return{};var n,a,i={},r=Object.keys(e);for(a=0;a<r.length;a++)n=r[a],t.indexOf(n)>=0||(i[n]=e[n]);return i}(e,t);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(e);for(a=0;a<r.length;a++)n=r[a],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(i[n]=e[n])}return i}var p=a.createContext({}),g=function(e){var t=a.useContext(p),n=t;return e&&(n="function"==typeof e?e(t):l(l({},t),e)),n},d=function(e){var t=g(e.components);return a.createElement(p.Provider,{value:t},e.children)},s="mdxType",u={inlineCode:"code",wrapper:function(e){var t=e.children;return a.createElement(a.Fragment,{},t)}},y=a.forwardRef((function(e,t){var n=e.components,i=e.mdxType,r=e.originalType,p=e.parentName,d=o(e,["components","mdxType","originalType","parentName"]),s=g(n),y=i,c=s["".concat(p,".").concat(y)]||s[y]||u[y]||r;return n?a.createElement(c,l(l({ref:t},d),{},{components:n})):a.createElement(c,l({ref:t},d))}));function c(e,t){var n=arguments,i=t&&t.mdxType;if("string"==typeof e||i){var r=n.length,l=new Array(r);l[0]=y;var o={};for(var p in t)hasOwnProperty.call(t,p)&&(o[p]=t[p]);o.originalType=e,o[s]="string"==typeof e?e:i,l[1]=o;for(var g=2;g<r;g++)l[g]=n[g];return a.createElement.apply(null,l)}return a.createElement.apply(null,n)}y.displayName="MDXCreateElement"},8745:(e,t,n)=>{n.r(t),n.d(t,{assets:()=>p,contentTitle:()=>l,default:()=>u,frontMatter:()=>r,metadata:()=>o,toc:()=>g});var a=n(8168),i=(n(6540),n(5680));const r={},l="Setup",o={unversionedId:"setup",id:"setup",title:"Setup",description:"To configure iOS SDK integration you need to:",source:"@site/docs/setup.mdx",sourceDirName:".",slug:"/setup",permalink:"/mobile-sdk-ios/setup",draft:!1,editUrl:"https://github.com/crowdin/mobile-sdk-ios/tree/master/website/docs/setup.mdx",tags:[],version:"current",frontMatter:{},sidebar:"tutorialSidebar",previous:{title:"Installation",permalink:"/mobile-sdk-ios/installation"},next:{title:"Real-Time Preview",permalink:"/mobile-sdk-ios/advanced-features/real-time-preview"}},p={},g=[{value:"Swift",id:"swift",level:3},{value:"Objective-C",id:"objective-c",level:3},{value:"Alternative Setup: Info.plist",id:"alternative-setup-infoplist",level:2},{value:"Additional Features",id:"additional-features",level:2},{value:"Translations Update Interval",id:"translations-update-interval",level:3},{value:"Change locale programmatically",id:"change-locale-programmatically",level:2},{value:"SwiftUI Support",id:"swiftui-support",level:2},{value:"Apple Strings Catalog Support",id:"apple-strings-catalog-support",level:2},{value:"Config Options Reference",id:"config-options-reference",level:2},{value:"OAuth Options",id:"oauth-options",level:3}],d={toc:g},s="wrapper";function u(e){let{components:t,...n}=e;return(0,i.yg)(s,(0,a.A)({},d,n,{components:t,mdxType:"MDXLayout"}),(0,i.yg)("h1",{id:"setup"},"Setup"),(0,i.yg)("p",null,"To configure iOS SDK integration you need to:"),(0,i.yg)("ul",null,(0,i.yg)("li",{parentName:"ul"},"Upload your localization files to Crowdin. If you have existing translations, you can upload them as well. You can use one of the following options:",(0,i.yg)("ul",{parentName:"li"},(0,i.yg)("li",{parentName:"ul"},(0,i.yg)("a",{parentName:"li",href:"https://crowdin.github.io/crowdin-cli/"},"Crowdin CLI")),(0,i.yg)("li",{parentName:"ul"},(0,i.yg)("a",{parentName:"li",href:"https://store.crowdin.com/visual-studio-code"},"Crowdin VS Code Plugin")),(0,i.yg)("li",{parentName:"ul"},(0,i.yg)("a",{parentName:"li",href:"https://github.com/marketplace/actions/crowdin-action"},"Crowdin GitHub Action")),(0,i.yg)("li",{parentName:"ul"},(0,i.yg)("a",{parentName:"li",href:"https://support.crowdin.com/uploading-files/"},"and more")))),(0,i.yg)("li",{parentName:"ul"},"Set up Distribution in Crowdin."),(0,i.yg)("li",{parentName:"ul"},"Set up SDK and enable Over-The-Air Content Delivery feature.")),(0,i.yg)("p",null,(0,i.yg)("strong",{parentName:"p"},"Distribution")," is a CDN vault that mirrors the translated content of your project and is required for integration with iOS app."),(0,i.yg)("ul",null,(0,i.yg)("li",{parentName:"ul"},(0,i.yg)("a",{parentName:"li",href:"https://support.crowdin.com/content-delivery/"},"Creating a distribution in crowdin.com")),(0,i.yg)("li",{parentName:"ul"},(0,i.yg)("a",{parentName:"li",href:"https://support.crowdin.com/enterprise/content-delivery/"},"Creating a distribution in Crowdin Enterprise"))),(0,i.yg)("admonition",{type:"info"},(0,i.yg)("ul",{parentName:"admonition"},(0,i.yg)("li",{parentName:"ul"},"The download of translations happens ",(0,i.yg)("strong",{parentName:"li"},"asynchronously")," after the start of the application. The downloaded translations will be used the next time the app is launched, otherwise the previously cached translations will be used (or local translations if no cache exists)."),(0,i.yg)("li",{parentName:"ul"},"The CDN feature does not update the localization files, if you want to add new translations to the localization files, you need to do it yourself."),(0,i.yg)("li",{parentName:"ul"},"Once the SDK receives the translations, they're stored on the device as application files for future sessions to minimize requests the next time the app is launched. The storage time can be configured using the ",(0,i.yg)("inlineCode",{parentName:"li"},"intervalUpdatesEnabled")," option."),(0,i.yg)("li",{parentName:"ul"},"CDN will cache all translations in the release for up to 1 hour and even if new translations are released in Crowdin, CDN may return them with a delay."))),(0,i.yg)("h3",{id:"swift"},"Swift"),(0,i.yg)("p",null,"Open the ",(0,i.yg)("em",{parentName:"p"},"AppDelegate.swift")," file and add:"),(0,i.yg)("pre",null,(0,i.yg)("code",{parentName:"pre",className:"language-swift"},"import CrowdinSDK\n")),(0,i.yg)("p",null,"In the ",(0,i.yg)("inlineCode",{parentName:"p"},"application")," method add:"),(0,i.yg)("pre",null,(0,i.yg)("code",{parentName:"pre",className:"language-swift"},'let crowdinProviderConfig = CrowdinProviderConfig(hashString: "{distribution_hash}",\n  sourceLanguage: "{source_language}")\n\nCrowdinSDK.startWithConfig(crowdinSDKConfig, completion: {\n    // SDK is ready to use, put code to change language, etc. here\n})\n')),(0,i.yg)("h3",{id:"objective-c"},"Objective-C"),(0,i.yg)("p",null,"In the ",(0,i.yg)("em",{parentName:"p"},"AppDelegate.m")," add:"),(0,i.yg)("pre",null,(0,i.yg)("code",{parentName:"pre",className:"language-objectivec"},"@import CrowdinSDK\n")),(0,i.yg)("p",null,"or"),(0,i.yg)("pre",null,(0,i.yg)("code",{parentName:"pre",className:"language-objectivec"},"#import<CrowdinSDK/CrowdinSDK.h>\n")),(0,i.yg)("p",null,"In the ",(0,i.yg)("inlineCode",{parentName:"p"},"application")," method add:"),(0,i.yg)("pre",null,(0,i.yg)("code",{parentName:"pre",className:"language-objectivec"},'CrowdinProviderConfig *crowdinProviderConfig = [[CrowdinProviderConfig alloc] initWithHashString:@"" sourceLanguage:@""];\nCrowdinSDKConfig *config = [[[CrowdinSDKConfig config] withCrowdinProviderConfig:crowdinProviderConfig]];\n\n[CrowdinSDK startWithConfig:config completion:^{\n// SDK is ready to use, put code to change language, etc. here\n}];\n')),(0,i.yg)("p",null,"If you have a pure Objective-C project, you will need to take some additional steps:"),(0,i.yg)("p",null,"Add the following code to your Library Search Paths:"),(0,i.yg)("ol",null,(0,i.yg)("li",{parentName:"ol"},(0,i.yg)("p",{parentName:"li"},"Add to Library Search Paths:"),(0,i.yg)("pre",{parentName:"li"},(0,i.yg)("code",{parentName:"pre",className:"language-bash"},"$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)\n"))),(0,i.yg)("li",{parentName:"ol"},(0,i.yg)("p",{parentName:"li"},"Add ",(0,i.yg)("inlineCode",{parentName:"p"},"use_frameworks!")," to your Podfile."))),(0,i.yg)("h2",{id:"alternative-setup-infoplist"},"Alternative Setup: Info.plist"),(0,i.yg)("p",null,"You can also configure basic SDK settings in Info.plist:"),(0,i.yg)("ol",null,(0,i.yg)("li",{parentName:"ol"},(0,i.yg)("p",{parentName:"li"},"Add these keys to ",(0,i.yg)("em",{parentName:"p"},"Info.plist"),":"),(0,i.yg)("ul",{parentName:"li"},(0,i.yg)("li",{parentName:"ul"},(0,i.yg)("inlineCode",{parentName:"li"},"CrowdinDistributionHash")," (String) - Your Crowdin CDN hash"),(0,i.yg)("li",{parentName:"ul"},(0,i.yg)("inlineCode",{parentName:"li"},"CrowdinSourceLanguage")," (String) - Source language code in ",(0,i.yg)("a",{parentName:"li",href:"http://www.loc.gov/standards/iso639-2/php/English_list.php"},"ISO 639-1")," format"))),(0,i.yg)("li",{parentName:"ol"},(0,i.yg)("p",{parentName:"li"},"In AppDelegate call:"),(0,i.yg)("ul",{parentName:"li"},(0,i.yg)("li",{parentName:"ul"},"Swift: ",(0,i.yg)("inlineCode",{parentName:"li"},"CrowdinSDK.start()")),(0,i.yg)("li",{parentName:"ul"},"Objective-C: ",(0,i.yg)("inlineCode",{parentName:"li"},"[CrowdinSDK start]"))))),(0,i.yg)("admonition",{type:"caution"},(0,i.yg)("p",{parentName:"admonition"},"Using the ",(0,i.yg)("inlineCode",{parentName:"p"},"Info.plist")," setup method, you cannot configure Screenshots and Real-Time Preview features.")),(0,i.yg)("h2",{id:"additional-features"},"Additional Features"),(0,i.yg)("h3",{id:"translations-update-interval"},"Translations Update Interval"),(0,i.yg)("p",null,"By default, SDK searches for new translation once per application load, but not more often than 15 minutes. You can update translations in application every defined interval. To enable this feature add pod ",(0,i.yg)("inlineCode",{parentName:"p"},"CrowdinSDK/IntervalUpdate")," to your pod file:"),(0,i.yg)("ol",null,(0,i.yg)("li",{parentName:"ol"},(0,i.yg)("p",{parentName:"li"},"Add to ",(0,i.yg)("inlineCode",{parentName:"p"},"Podfile"),":"),(0,i.yg)("pre",{parentName:"li"},(0,i.yg)("code",{parentName:"pre",className:"language-swift"},"pod 'CrowdinSDK/IntervalUpdate'\n"))),(0,i.yg)("li",{parentName:"ol"},(0,i.yg)("p",{parentName:"li"},"Configure in SDK:"),(0,i.yg)("pre",{parentName:"li"},(0,i.yg)("code",{parentName:"pre",className:"language-swift"},".with(intervalUpdatesEnabled: true, interval: {interval})\n")),(0,i.yg)("p",{parentName:"li"},"Where ",(0,i.yg)("inlineCode",{parentName:"p"},"interval")," - defines translations update time interval in seconds. Minimum allowed interval is 15 minutes (900 seconds)."))),(0,i.yg)("h2",{id:"change-locale-programmatically"},"Change locale programmatically"),(0,i.yg)("p",null,"By default, the SDK relies on the device locale. To change the SDK target language on the fly regardless of the device locale, use the following method:"),(0,i.yg)("pre",null,(0,i.yg)("code",{parentName:"pre",className:"language-swift"},'CrowdinSDK.enableSDKLocalization(true, localization: "<language_code>")\n')),(0,i.yg)("p",null,"Where ",(0,i.yg)("inlineCode",{parentName:"p"},"<language_code>")," is the target language in ",(0,i.yg)("a",{parentName:"p",href:"http://www.loc.gov/standards/iso639-2/php/English_list.php"},"ISO 639-1")," format."),(0,i.yg)("h2",{id:"swiftui-support"},"SwiftUI Support"),(0,i.yg)("p",null,"SwiftUI support requires explicit localization calls. Use either:"),(0,i.yg)("pre",null,(0,i.yg)("code",{parentName:"pre",className:"language-swift"},'Text(NSLocalizedString("key", comment: "comment"))\n')),(0,i.yg)("p",null,"or the convenience extension:"),(0,i.yg)("pre",null,(0,i.yg)("code",{parentName:"pre",className:"language-swift"},'Text("key".cw_localized)\n')),(0,i.yg)("p",null,"View the ",(0,i.yg)("a",{parentName:"p",href:"/guides/swift-ui"},"Swift UI Localization guide")," for more information."),(0,i.yg)("h2",{id:"apple-strings-catalog-support"},"Apple Strings Catalog Support"),(0,i.yg)("p",null,"The Crowdin SDK supports the ",(0,i.yg)("a",{parentName:"p",href:"https://store.crowdin.com/string_catalog"},"Apple Strings Catalog")," (",(0,i.yg)("inlineCode",{parentName:"p"},".xcstrings"),") format out of the box. It doesn't require any additional setup. Just upload your localization files to Crowdin, set up the distribution and start using the SDK."),(0,i.yg)("admonition",{type:"caution"},(0,i.yg)("p",{parentName:"admonition"},"Only the CDN Content Delivery feature is available for the Apple Strings Catalog format. The Screenshots and Real-Time Preview features are not yet supported.")),(0,i.yg)("h2",{id:"config-options-reference"},"Config Options Reference"),(0,i.yg)("table",null,(0,i.yg)("thead",{parentName:"table"},(0,i.yg)("tr",{parentName:"thead"},(0,i.yg)("th",{parentName:"tr",align:null},"Option"),(0,i.yg)("th",{parentName:"tr",align:null},"Description"),(0,i.yg)("th",{parentName:"tr",align:null},"Example Value"))),(0,i.yg)("tbody",{parentName:"table"},(0,i.yg)("tr",{parentName:"tbody"},(0,i.yg)("td",{parentName:"tr",align:null},(0,i.yg)("inlineCode",{parentName:"td"},"hashString")),(0,i.yg)("td",{parentName:"tr",align:null},"Distribution Hash"),(0,i.yg)("td",{parentName:"tr",align:null},(0,i.yg)("inlineCode",{parentName:"td"},'"7a0c1...o3b"'))),(0,i.yg)("tr",{parentName:"tbody"},(0,i.yg)("td",{parentName:"tr",align:null},(0,i.yg)("inlineCode",{parentName:"td"},"sourceLanguage")),(0,i.yg)("td",{parentName:"tr",align:null},"Source language code (",(0,i.yg)("a",{parentName:"td",href:"http://www.loc.gov/standards/iso639-2/php/English_list.php"},"ISO 639-1"),")"),(0,i.yg)("td",{parentName:"tr",align:null},(0,i.yg)("inlineCode",{parentName:"td"},'sourceLanguage: "en"'))),(0,i.yg)("tr",{parentName:"tbody"},(0,i.yg)("td",{parentName:"tr",align:null},(0,i.yg)("inlineCode",{parentName:"td"},"organizationName")),(0,i.yg)("td",{parentName:"tr",align:null},"Organization domain (Enterprise only)"),(0,i.yg)("td",{parentName:"tr",align:null},(0,i.yg)("inlineCode",{parentName:"td"},'"mycompany"'))),(0,i.yg)("tr",{parentName:"tbody"},(0,i.yg)("td",{parentName:"tr",align:null},(0,i.yg)("inlineCode",{parentName:"td"},"settingsEnabled")),(0,i.yg)("td",{parentName:"tr",align:null},"Enable SDK Controls"),(0,i.yg)("td",{parentName:"tr",align:null},(0,i.yg)("inlineCode",{parentName:"td"},"true"))),(0,i.yg)("tr",{parentName:"tbody"},(0,i.yg)("td",{parentName:"tr",align:null},(0,i.yg)("inlineCode",{parentName:"td"},"accessToken")),(0,i.yg)("td",{parentName:"tr",align:null},"Crowdin API access token"),(0,i.yg)("td",{parentName:"tr",align:null},(0,i.yg)("inlineCode",{parentName:"td"},'"your_token"'))))),(0,i.yg)("h3",{id:"oauth-options"},"OAuth Options"),(0,i.yg)("table",null,(0,i.yg)("thead",{parentName:"table"},(0,i.yg)("tr",{parentName:"thead"},(0,i.yg)("th",{parentName:"tr",align:null},"Option"),(0,i.yg)("th",{parentName:"tr",align:null},"Description"),(0,i.yg)("th",{parentName:"tr",align:null},"Example Value"))),(0,i.yg)("tbody",{parentName:"table"},(0,i.yg)("tr",{parentName:"tbody"},(0,i.yg)("td",{parentName:"tr",align:null},(0,i.yg)("inlineCode",{parentName:"td"},"clientId")),(0,i.yg)("td",{parentName:"tr",align:null},"OAuth Client ID"),(0,i.yg)("td",{parentName:"tr",align:null},(0,i.yg)("inlineCode",{parentName:"td"},'"gpY2yT...x3TYB"'))),(0,i.yg)("tr",{parentName:"tbody"},(0,i.yg)("td",{parentName:"tr",align:null},(0,i.yg)("inlineCode",{parentName:"td"},"clientSecret")),(0,i.yg)("td",{parentName:"tr",align:null},"OAuth Client Secret"),(0,i.yg)("td",{parentName:"tr",align:null},(0,i.yg)("inlineCode",{parentName:"td"},'"Xz95t...EDx9T"'))),(0,i.yg)("tr",{parentName:"tbody"},(0,i.yg)("td",{parentName:"tr",align:null},(0,i.yg)("inlineCode",{parentName:"td"},"scope")),(0,i.yg)("td",{parentName:"tr",align:null},'OAuth scope (e.g., "project.screenshot", "project")'),(0,i.yg)("td",{parentName:"tr",align:null},(0,i.yg)("inlineCode",{parentName:"td"},'"project"'))),(0,i.yg)("tr",{parentName:"tbody"},(0,i.yg)("td",{parentName:"tr",align:null},(0,i.yg)("inlineCode",{parentName:"td"},"redirectURI")),(0,i.yg)("td",{parentName:"tr",align:null},"Custom URL scheme for your app"),(0,i.yg)("td",{parentName:"tr",align:null},(0,i.yg)("inlineCode",{parentName:"td"},'"crowdintest://"'))))))}u.isMDXComponent=!0}}]);