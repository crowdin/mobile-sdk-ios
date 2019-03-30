# Documents folder structre:

After application will start SDK, it will detect current device localization and download strings and plurals from server for this localization. In your applications Documents folder SDK. SDK will create folder with following pattern "bundle id" + "Crowdin". In this folder it will keep all needed files and folder associated with SDK. 

## Crowdin folder
In this folder SDK will keep all files for downloaded localizations in plist format. Localization saved in files with localization code as name f.e. en.plist, de.plist. localizations.plist file - all supported localizations on Crowdin server. SupportedLanguages.json - saved response from SupportedLanguages endpoint from crowdin api.

<img src='./Documents/CrowdinFolder.png' width="600"/>

## Extracted folder

Contains all extracted localizations from application. Currently it used for easier uploading localization to crowdin server.

<img src='./Documents/ExtractedFolder.png' width="600"/>

## Plurals folder 

Used for exchanging plurals localization. 

<img src='./Documents/PluralsFilder.png' width="600"/>

#Screenshots folder

Here sdk will save all screenshots.
