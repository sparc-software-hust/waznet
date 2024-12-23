# WazNet
<img src="mobile/assets/icon/logo_green.png" width="250" height="223" />

**WazNet** (Waste zero, Net zero) is a mobile app that helps users track their contributions to greenhouse gas reduction.

A product of SPARC Lab (HUST) and CECR.

## Tech stacks
- Mobile app built with Flutter
- Supported platforms: **Android**, **iOS**
- State management with Bloc
- Push Notifications via FCM
- Back-end systems using Elixir, RabbitMQ, Redis, PostgreSQL
- Build and deploy using Docker
- Publish to Testflight (iOS), Play Console (Android) using Github Actions

## Features
- 3 roles: Admin, Household, Scraper
- Scrapers and Households contribute garbage/recycle quantity data, app will calculate to **kgCO2e** reduction
- Admin can track all contributions, export Excel statistic(upcoming)
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
### Contribution detail
| Detail                                            |
|---------------------------------------------------|
| ![](mobile/assets/images/user_info.png)    | 
</details>

## Installing

Google Play: Closed Beta Testing (send email address to email in contact)

App Store: [TestFlight](https://testflight.apple.com/join/9wRutKJ9)

## Building
Project is using git-crypt to encrypt all credentials, contributors need to contact to repo's owner to get decryption key.

## Roadmap
- iOS/Android Push Notification
- Custom time schedule for sending reminder notification to users
- ZNS to forgot password flow
- Export Excel statistics

## Contact
Email: thai.dm279@gmail.com
