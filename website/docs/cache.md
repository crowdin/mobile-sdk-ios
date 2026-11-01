---
description: Learn how the Crowdin iOS SDK caches translations - what is stored on the device, when the SDK contacts the CDN, how ETags and the update interval reduce requests, and what forceRefreshLocalization really does.
---

# Cache

To optimize app performance and overall CDN costs, the Crowdin SDK caches downloaded translations on the device. Cached translations are used immediately on every launch, work offline, and let the SDK skip network requests when nothing has changed in the distribution.

Distribution usage is billed by the number of requests and the amount of content downloaded, so it helps to know exactly when the SDK goes to the network and what it downloads. This page describes that logic.

The minimum and default update interval is 15 minutes. You can change it using the [`minimumManifestUpdateInterval`](#update-interval) option.

## What is cached

Everything the SDK stores lives in a dedicated folder inside the app's *Application Support* directory (`<bundle id>.Crowdin`). It is never shared between apps and is removed when the app is uninstalled.

| Data                    | Purpose                                                                                                                        |
|-------------------------|--------------------------------------------------------------------------------------------------------------------------------|
| Translations            | Strings and plurals for every language the SDK has downloaded so far, one file per language. This is what your app reads at runtime. |
| Distribution manifest   | The `manifest.json` of your distribution: the list of files, languages and the **timestamp of the latest release**.            |
| Last manifest check     | When the manifest was last downloaded. Used to enforce the update interval.                                                    |
| File timestamps         | For every downloaded file, the release timestamp it was downloaded for. Used to skip files that have not changed.              |
| ETags                   | The `ETag` HTTP header returned by the CDN for every downloaded file, per language. Used to avoid re-downloading identical content. |
| Supported languages     | The `languages.json` of your distribution (language codes mapping). Refreshed only when a new release is detected.             |

## How it works

The SDK works with two levels of freshness checks: the **manifest** tells whether there is a new release at all, and **ETags** tell whether a particular file actually changed. Both are designed to make the common case, "nothing changed", cost nothing or almost nothing.

### First launch

1. The SDK downloads the distribution manifest (`manifest.json`). It is a small file that lists the available languages and files and carries the timestamp of the latest release.
2. The SDK downloads the translation files for the **current language only**. Files for other languages are not downloaded.
3. Translations are saved to the device cache together with the manifest, the release timestamp for each file, and the `ETag` of each file.

### Next launches

1. **Cached translations are loaded from the device first.** This is instant and does not need a network connection. The app is fully localized from this point on, even offline.
2. **Update interval check.** The SDK looks at when the manifest was last downloaded. If it was less than `minimumManifestUpdateInterval` ago (15 minutes by default), the SDK stops here. **No requests are made.**
3. **Manifest check.** Otherwise the SDK downloads `manifest.json` again (one small request) and compares the release timestamp inside it with the timestamp stored for each cached file of the current language.
   - If the timestamps match, there is no new release. The SDK keeps the cached translations and makes **no further requests**.
   - If the manifest contains a newer timestamp, a new release exists and the SDK moves on to download the files.
4. **File download with ETags.** For every file of the current language the SDK sends a request with the `If-None-Match` header set to the stored `ETag`.
   - If the file content has not changed since the last download, the CDN answers `304 Not Modified` without a body. The SDK keeps the cached translations and marks the file as up to date for the new release. This counts as a request but transfers almost no data.
   - If the file content has changed, the CDN answers `200 OK` with the new content and a new `ETag`. The SDK saves both.
5. New translations are merged into the device cache and become available to the SDK. Use the [`addDownloadHandler`](/setup#adddownloadhandler-closure) closure to refresh already rendered UI if needed.

:::info
The update interval is persisted on the device, so it applies across app launches as well as within a long-running app session.
:::

:::tip Why both the timestamp and the ETag?
The release timestamp is a cheap check that covers the whole release: one request tells the SDK whether anything was released at all. ETags work per file: when a release *was* made but, for example, only the French translations changed, a German user still downloads nothing because every German file answers `304`.
:::

## ETag

The ETag is a content fingerprint the CDN returns for every file. The SDK stores it for every downloaded file per language and sends it back in the `If-None-Match` header the next time the same file is requested. The CDN then returns the content only if it differs from what the SDK already has.

Things to keep in mind:

- ETags are used for translation files and `languages.json`. The manifest itself is always downloaded in full, but it is requested only once per update interval and is small.
- ETags only come into play after a new release is detected. If the manifest timestamp has not changed, files are not requested at all, so there is nothing to validate.
- ETags are stored per language. Switching the app to a language that has not been downloaded yet triggers a full download of that language's files.

## Update interval

The `minimumManifestUpdateInterval` option of `CrowdinProviderConfig` defines how often the SDK is allowed to check the distribution for a new release. The value is in seconds, and the default is 15 minutes (900 seconds).

```swift
let crowdinProviderConfig = CrowdinProviderConfig(
    hashString: "{distribution_hash}",
    sourceLanguage: "{source_language}",
    minimumManifestUpdateInterval: 60 * 60 // check for updates at most once per hour
)
```

Until the interval elapses the SDK does not contact the CDN at all, so the interval is the main lever for controlling the number of requests your app makes. A longer interval means fewer requests and a longer delay before new translations reach users.

A value of `0` makes the SDK check the manifest on every launch. This is handy for development builds but increases the number of requests in production.

:::info
The interval controls how often the SDK *checks* for updates. It does not limit how often translations are *downloaded*: files are downloaded only when a new release is detected, and even then only the files that actually changed.
:::

## Force refresh

`CrowdinSDK.forceRefreshLocalization()` (and the *Reload translations* button in [SDK Controls](/advanced-features/sdk-controls)) re-runs the update flow for the current language on demand, ignoring the update interval. Here is what it does:

- It **clears the stored ETags** for the current language and reloads the cached translations from the device.
- It **bypasses the update interval** and downloads the manifest again, even if the previous check was a moment ago.
- If the manifest contains a new release, all files of the current language are downloaded in full, because the ETags were cleared and the CDN cannot answer `304`. If there is no new release, nothing else is downloaded.

A force refresh therefore always costs at least one request, and when a new release exists it downloads more than a regular update would. Use it for explicit user actions such as a "Refresh translations" button, and avoid calling it on a timer or on every app launch in production.

To wipe the whole cache (translations, manifest, timestamps and ETags), call `CrowdinSDK.deintegrate()`. The next launch will behave like a first launch.

:::caution
[Real-Time Preview](/advanced-features/real-time-preview) does not use the distribution cache at all. It fetches the latest translations directly from the Crowdin project via the API and is intended for development and staging only.
:::

## Cost overview

The table summarizes how many requests the SDK makes to the CDN in typical situations. "N" is the number of translation files for the current language in your distribution.

| Situation                                                    | Requests        | Content downloaded                                   |
|--------------------------------------------------------------|-----------------|------------------------------------------------------|
| App launch within the update interval                        | 0               | Nothing                                              |
| App launch after the interval, no new release                | 1 (manifest)    | Manifest only                                        |
| App launch after the interval, new release, nothing changed for this language | 1 + N (+ 1 for `languages.json`) | Manifest only; every file answers `304`              |
| App launch after the interval, new release, some files changed | 1 + N (+ 1 for `languages.json`) | Manifest plus only the files that changed            |
| `forceRefreshLocalization()`, no new release                 | 1 (manifest)    | Manifest only                                        |
| `forceRefreshLocalization()`, new release                    | 1 + N (+ 1 for `languages.json`) | Manifest plus **all** files of the current language  |
| First launch, or switching to a language not yet downloaded  | 1 + N (+ 1 for `languages.json`) | All files of that language                           |

## CDN Cache

The CDN cache is a CloudFront (Content Delivery Network) edge cache used to deliver translations to the application faster. It is not controlled by the SDK and usually has a TTL of 1 hour. This means that there may be a delay before new translations appear in the application, even when the SDK checks the manifest right after a release.

Translation files are requested with the release timestamp as a query parameter, so once the SDK sees a new manifest, it always receives the files of that release rather than stale copies from the edge cache.

## See also

- [Content Delivery](https://support.crowdin.com/cdn-distributions/)
- [Config Options Reference](/setup#config-options-reference)
- [Translations Update Interval](/setup#translations-update-interval)
