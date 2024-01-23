---
description: Explore the Crowdin iOS SDK FAQ page for quick answers to your questions. Find troubleshooting tips to optimize your experience.
---

# FAQ

### Is there a caching mechanism in the SDK?

Yes, the SDK caches translations locally. The cache TTL can be configured by the developer. There is also a CDN cache. There is not much control over it, but it is usually 1 hour, so there is a possible delay for new translations to appear in the app.

### What translations will be displayed if the current locale is not present in the Crowdin project?

The app will use the bundled translations or the default language as a fallback. It will not fall back to any other Crowdin locale.

### Will the SDK download all translations from Crowdin every time the app launches?

No, the SDK downloads and caches translations locally. It will only download translations if they are not in the cache or if the cache has expired.

### Will the SDK download all translations from the Crowdin CDN or just the current language?

The SDK downloads only the current language translations.

### How do I test the new translations before releasing the distribution?

You can use the Real-Time Preview feature for this. After authorization, it will download the latest translations from the Crowdin project, which can be tested before delivering all translations to users. You can also create a new distribution and test it before releasing the main distribution.

### What format is used to transfer translations from Crowdin to the app?

The translations are transferred in the same format as they are stored in the Crowdin project.

### What translations will be displayed if I lose my Internet connection?

The SDK uses the cached translations. If there are no cached translations, it will use the bundled translations or the default language as a fallback.

### If there are multiple branches in the Crowdin project, which translations will be displayed in the app?

The SDK will use the translations from the branch that is specified in the distribution configuration.
