# WazNet
<!-- <img src="mobile/assets/icon/logo_green.png" width="250" height="223" /> <img src="mobile/assets/icon/branding_color.png" /> -->
<p align="center">
  <img src="mobile/assets/icon/logo_branding.png" />
</p>

**WazNet** (Waste zero, Net zero) is a mobile app that helps users track their contributions to greenhouse gas reduction.

A product of SPARC Lab (HUST) and CECR. Available on [App Store](https://apps.apple.com/vn/app/waznet/id6738925384) and [Google Play](https://play.google.com/store/apps/details?id=vn.sparc.waznet).

## Tech stacks
- Mobile app built with Flutter
- Supported platforms: **Android**, **iOS**
- State management with Bloc
- Push Notifications via FCM
- Back-end systems using Elixir, RabbitMQ, Redis, PostgreSQL
- Build and deploy using Docker
- Publish to App Store (iOS), Play Console (Android) using Github Actions

## Features
- 3 roles: Admin, Household, Scraper
- Scrapers and Households contribute garbage/recycle quantity data, app will calculate to **kgCO2e** reduction
- Admin can track all contributions, export Excel statistics
- Others can track own contributions, receive notifications to remind contribute in custom time 

<details>
<summary>Screenshots</summary>

### Login/Register
| Login                                             | Register                                              |
|---------------------------------------------------|-----------------------------------------------------|
| ![](mobile/assets/images/login.PNG)               | ![](mobile/assets/images/register.PNG) |

### Home
| Admin                                             | Household                                               |
|---------------------------------------------------|-----------------------------------------------------|
| ![](mobile/assets/images/admin_home.JPG)          | ![](mobile/assets/images/household_home.JPG) |

### Contribution input
| Input                                             | Input                                               |
|---------------------------------------------------|-----------------------------------------------------|
| ![](mobile/assets/images/contribution_input_2.PNG)      | ![](mobile/assets/images/contribution_input.PNG) |

### Contribution detail
| Detail                                            | Detail                                               |
|---------------------------------------------------|-----------------------------------------------------|
| ![](mobile/assets/images/household_detail.JPG)      | ![](mobile/assets/images/contribution_1.JPG) |

### User info
| User Info                                            |
|---------------------------------------------------|
| ![](mobile/assets/images/user_info.png)    | 
</details>

## Installing

Google Play:
- [Google Play](https://play.google.com/store/apps/details?id=vn.sparc.waznet)

App Store:
- [TestFlight](https://testflight.apple.com/join/9wRutKJ9)
- [App Store](https://apps.apple.com/vn/app/waznet/id6738925384)


## Building
Project is using git-crypt to encrypt all credentials, contributors need to contact to repo's owner to get decryption key.

Install `git-crypt`: [MacOS, Ubuntu](https://github.com/AGWA/git-crypt/blob/master/INSTALL.md), [Windows](https://github.com/AGWA/git-crypt/releases/tag/0.7.0)

After saving key somewhere in your directory, command:
```bash
git-crypt unlock <path_to_key>
```
If all files are decrypted, done! You can run code normally.

## Roadmap
- ZNS to forgot password flow (on my way to find another solution)
- Add more screenshots feature
- Many inputs in one day
- Admin can delete contributions
- Divide household tab contributions

## Contact
Email: sparc.hust@gmail.com

Email: thai.dm279@gmail.com
