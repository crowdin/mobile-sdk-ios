# Security

Crowdin iOS SDK CDN feature is built with security in mind, which means minimal access possible from the end-user is required.
When you decide to use Crowdin iOS SDK, please make sure you’ve made the following information accessible to your end-users.

- We use the advantages of Amazon Web Services (AWS) for our computing infrastructure. AWS has ISO 27001 certification and has completed multiple SSAE 16 audits. All the translations are stored at AWS servers.
- When you use Crowdin iOS SDK CDN – translations are uploaded to Amazon CloudFront to be delivered to the app and speed up the download. Keep in mind that your users download translations without any additional authentication.
- We use encryption to keep your data private while in transit.
- We do not store any Personally Identifiable Information (PII) about the end-user, but you can decide to develop the opt-out option inside your application to make sure your users have full control.
- The Automatic Screenshots and Real-Time Preview features are supposed to be used by the development team and translators team. Those features should not be compiled to the production version of your app. Therefore, should not affect end-users privacy in any way.
