"use strict";(self.webpackChunk_crowdin_mobile_sdk_ios_website=self.webpackChunk_crowdin_mobile_sdk_ios_website||[]).push([[806],{3905:(e,t,n)=>{n.d(t,{Zo:()=>u,kt:()=>m});var i=n(7294);function r(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function o(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var i=Object.getOwnPropertySymbols(e);t&&(i=i.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,i)}return n}function a(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?o(Object(n),!0).forEach((function(t){r(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):o(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function l(e,t){if(null==e)return{};var n,i,r=function(e,t){if(null==e)return{};var n,i,r={},o=Object.keys(e);for(i=0;i<o.length;i++)n=o[i],t.indexOf(n)>=0||(r[n]=e[n]);return r}(e,t);if(Object.getOwnPropertySymbols){var o=Object.getOwnPropertySymbols(e);for(i=0;i<o.length;i++)n=o[i],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(r[n]=e[n])}return r}var s=i.createContext({}),d=function(e){var t=i.useContext(s),n=t;return e&&(n="function"==typeof e?e(t):a(a({},t),e)),n},u=function(e){var t=d(e.components);return i.createElement(s.Provider,{value:t},e.children)},p="mdxType",c={inlineCode:"code",wrapper:function(e){var t=e.children;return i.createElement(i.Fragment,{},t)}},f=i.forwardRef((function(e,t){var n=e.components,r=e.mdxType,o=e.originalType,s=e.parentName,u=l(e,["components","mdxType","originalType","parentName"]),p=d(n),f=r,m=p["".concat(s,".").concat(f)]||p[f]||c[f]||o;return n?i.createElement(m,a(a({ref:t},u),{},{components:n})):i.createElement(m,a({ref:t},u))}));function m(e,t){var n=arguments,r=t&&t.mdxType;if("string"==typeof e||r){var o=n.length,a=new Array(o);a[0]=f;var l={};for(var s in t)hasOwnProperty.call(t,s)&&(l[s]=t[s]);l.originalType=e,l[p]="string"==typeof e?e:r,a[1]=l;for(var d=2;d<o;d++)a[d]=n[d];return i.createElement.apply(null,a)}return i.createElement.apply(null,n)}f.displayName="MDXCreateElement"},7409:(e,t,n)=>{n.r(t),n.d(t,{assets:()=>s,contentTitle:()=>a,default:()=>c,frontMatter:()=>o,metadata:()=>l,toc:()=>d});var i=n(7462),r=(n(7294),n(3905));const o={},a="SDK Structure",l={unversionedId:"guides/sdk-structure",id:"guides/sdk-structure",title:"SDK Structure",description:"Subspecs",source:"@site/docs/guides/sdk-structure.md",sourceDirName:"guides",slug:"/guides/sdk-structure",permalink:"/mobile-sdk-ios/guides/sdk-structure",draft:!1,editUrl:"https://github.com/crowdin/mobile-sdk-ios/tree/master/website/docs/guides/sdk-structure.md",tags:[],version:"current",frontMatter:{},sidebar:"tutorialSidebar",previous:{title:"Swift UI Localization guide",permalink:"/mobile-sdk-ios/guides/swift-ui"},next:{title:"Example project",permalink:"/mobile-sdk-ios/example"}},s={},d=[{value:"Subspecs",id:"subspecs",level:2},{value:"Core",id:"core",level:3},{value:"CrowdinProvider",id:"crowdinprovider",level:3},{value:"CrowdinAPI",id:"crowdinapi",level:3},{value:"MappingManager",id:"mappingmanager",level:3},{value:"Screenshots",id:"screenshots",level:3},{value:"RealtimeUpdate",id:"realtimeupdate",level:3},{value:"RefreshLocalization",id:"refreshlocalization",level:3},{value:"Login",id:"login",level:3},{value:"IntervalUpdate",id:"intervalupdate",level:3},{value:"Settings",id:"settings",level:3}],u={toc:d},p="wrapper";function c(e){let{components:t,...n}=e;return(0,r.kt)(p,(0,i.Z)({},u,n,{components:t,mdxType:"MDXLayout"}),(0,r.kt)("h1",{id:"sdk-structure"},"SDK Structure"),(0,r.kt)("h2",{id:"subspecs"},"Subspecs"),(0,r.kt)("p",null,"CrowdinSDK divided into separate parts called subspecs. To install some of these parts via cocoapods you'll need to add ",(0,r.kt)("inlineCode",{parentName:"p"},"pod 'CrowdinSDK/Subspec_Name'")," in your pod file."),(0,r.kt)("p",null,"CrowdinSDK contains several submodules:"),(0,r.kt)("h3",{id:"core"},"Core"),(0,r.kt)("p",null,"This submodule contains core SDK functionality, such as functionality for switching localized strings, algorithms for current language detection."),(0,r.kt)("p",null,"This is the default submodule, which means if you set up SDK via cocapods with pod ",(0,r.kt)("em",{parentName:"p"},"CrowdinSDK")," this submodule will be included."),(0,r.kt)("h3",{id:"crowdinprovider"},"CrowdinProvider"),(0,r.kt)("p",null,"Submodule for downloading localizations from the Crowdin server."),(0,r.kt)("p",null,"This is the default submodule, which means if you set up SDK via cocapods with pod ",(0,r.kt)("em",{parentName:"p"},"CrowdinSDK")," this submodule will be included by default."),(0,r.kt)("h3",{id:"crowdinapi"},"CrowdinAPI"),(0,r.kt)("p",null,"Crowdin API implementation to work with the Crowdin server."),(0,r.kt)("h3",{id:"mappingmanager"},"MappingManager"),(0,r.kt)("p",null,"All classes related to strings mapping downloading and parsing. This subspec is used only as a dependency for realtime updates and screenshots subspecs."),(0,r.kt)("h3",{id:"screenshots"},"Screenshots"),(0,r.kt)("p",null,"It contains all functionality related to Screenshots feature. To enable this feature please add pod ",(0,r.kt)("inlineCode",{parentName:"p"},"CrowdinSDK/Screenshots")," to your pod file."),(0,r.kt)("h3",{id:"realtimeupdate"},"RealtimeUpdate"),(0,r.kt)("p",null,"It contains all functionality related to the Real-Time Preview feature. To enable this feature please add pod ",(0,r.kt)("inlineCode",{parentName:"p"},"CrowdinSDK/RealtimeUpdate")," to your pod file."),(0,r.kt)("h3",{id:"refreshlocalization"},"RefreshLocalization"),(0,r.kt)("p",null,"It contains functionality to force refresh localization strings. To enable this feature please add pod ",(0,r.kt)("inlineCode",{parentName:"p"},"CrowdinSDK/RefreshLocalization")," to your pod file."),(0,r.kt)("h3",{id:"login"},"Login"),(0,r.kt)("p",null,"It contains login functionality. To enable this feature please add pod ",(0,r.kt)("inlineCode",{parentName:"p"},"CrowdinSDK/Login")," to your pod file."),(0,r.kt)("p",null,"To set up this feature you need to setup create ",(0,r.kt)("inlineCode",{parentName:"p"},"CrowdinLoginConfig")," object and pass it to ",(0,r.kt)("inlineCode",{parentName:"p"},"CrowdinSDKConfig"),"."),(0,r.kt)("h3",{id:"intervalupdate"},"IntervalUpdate"),(0,r.kt)("p",null,"It contains functionality for update localization strings every defined time interval. To enable this feature please add pod ",(0,r.kt)("inlineCode",{parentName:"p"},"CrowdinSDK/IntervalUpdate")," to your pod file."),(0,r.kt)("h3",{id:"settings"},"Settings"),(0,r.kt)("p",null,"Submodule for testing all features. It contains a simple view with the possibility to enable/disable the following features: Force localization refresh, Interval localization updates, Real-time Preview, Screenshots. To enable this feature please add pod ",(0,r.kt)("inlineCode",{parentName:"p"},"CrowdinSDK/Settings")," to your pod file."),(0,r.kt)("p",null,"To display settings view you can call ",(0,r.kt)("inlineCode",{parentName:"p"},"CrowdinSDK.showSettings()")," method for Swift and ",(0,r.kt)("inlineCode",{parentName:"p"},"[CrowdinSDK showSettings]")," for Objective-C. Note that you need to set up all features with ",(0,r.kt)("inlineCode",{parentName:"p"},"CrowdinSDKConfig")," object."),(0,r.kt)("p",null,"Settings view has two states: Closed and open."))}c.isMDXComponent=!0}}]);