fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
### rsb_match_init
```
fastlane rsb_match_init
```
Create all certificates and profiles via match
### rsb_match
```
fastlane rsb_match
```
Download all certificates and profiles via match
### rsb_match_nuke
```
fastlane rsb_match_nuke
```
Remove all certificates and profiles
### rsb_start_ticket
```
fastlane rsb_start_ticket
```

### rsb_code_review_ticket
```
fastlane rsb_code_review_ticket
```

### rsb_finish_ticket
```
fastlane rsb_finish_ticket
```


----

## iOS
### ios rsb_fabric
```
fastlane ios rsb_fabric
```

### ios rsb_testflight
```
fastlane ios rsb_testflight
```

### ios rsb_fabric_testflight
```
fastlane ios rsb_fabric_testflight
```

### ios rsb_upload
```
fastlane ios rsb_upload
```

### ios rsb_add_devices
```
fastlane ios rsb_add_devices
```

### ios rsb_changelog
```
fastlane ios rsb_changelog
```

### ios rsb_post_to_slack
```
fastlane ios rsb_post_to_slack
```


----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
