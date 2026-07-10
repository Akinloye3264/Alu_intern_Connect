# ALU Intern Connect

A Flutter + Firebase marketplace that connects **ALU students** with **internship
and gig opportunities** posted by **startups**, with an **admin** review layer
that vets startups before they're allowed to post. Student signup is
restricted to `@alustudent.com` email addresses, tying the app specifically to
African Leadership University.

## Table of Contents

- [Features](#features)
- [User Roles](#user-roles)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Data Model](#data-model)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Firebase Setup](#firebase-setup)
  - [Environment Configuration](#environment-configuration)
  - [Running the App](#running-the-app)
- [Firestore Structure](#firestore-structure)
- [State Management](#state-management)
- [Known Limitations / Roadmap](#known-limitations--roadmap)
- [Testing](#testing)

## Features

### For students
- Sign up / log in with an ALU email (or Google Sign-In, which defaults new
  accounts to the student role).
- Browse all open opportunities, with a **skill-matching** recommendation
  feed that ranks postings by overlap with the student's own skills.
- Search and filter opportunities.
- Apply to an opportunity with an optional cover message.
- Track applications by status (Applied, Under Review, Interview, Accepted,
  Closed) in a tabbed view.
- Maintain a profile: skills list and bio.

### For startups
- Sign up with company details, website, and registration number.
- Sit in a **pending verification** state until an admin approves the
  account — startups cannot post opportunities until approved.
- Post, edit, and manage opportunities (title, description, category,
  required skills, commitment, location type).
- Review applicants for each posting and advance their application status.

### For admins
- Review the queue of pending startup signups.
- Approve or reject startups, unlocking (or blocking) their ability to post.

## User Roles

Role is stored on the `AppUser` model (`student | startup | admin`) and
drives which home screen is shown after login:

| Role | Landing screen |
|---|---|
| `student` | Student shell (Home + My Applications tabs) |
| `startup` | Startup home (manage own postings) |
| `admin` | Admin startup-review screen |

> There is currently no self-serve admin signup flow — the `admin` role is
> assigned manually via the Firestore console.

## Tech Stack

- **Framework:** Flutter (Dart SDK `^3.12.1`)
- **State management:** [`flutter_bloc`](https://pub.dev/packages/flutter_bloc) /
  `bloc`, using **Cubits** (`AuthCubit`, `OpportunityCubit`,
  `ApplicationCubit`, `ThemeCubit`) rather than full Bloc event/state classes.
- **Backend:** Firebase
  - `firebase_core`, `firebase_auth`, `cloud_firestore`
  - `google_sign_in` for Google OAuth
- **Other notable packages:**
  - `equatable` — value equality for models/state
  - `flutter_animate` — UI animations
  - `cached_network_image` — remote image caching
  - `shimmer` — loading skeletons
  - `timeago` — relative timestamps
  - `shared_preferences` — local key-value storage

## Project Structure

```
lib/
  core/
    config/
      env.dart                # Compile-time environment variables
    constants/
      firestore_paths.dart    # Firestore collection names/paths
    theme/
      app_theme.dart
      theme_cubit.dart
    utils/
      skill_matcher.dart       # Skill-overlap scoring for recommendations
      validators.dart
    widgets/
      opportunity_card.dart
      primary_button.dart
  features/
    admin/
      view/admin_startups_screen.dart
    applications/
      cubit/                   # application_cubit.dart, application_state.dart
      view/                    # my_applications_screen.dart, applicants_screen.dart
    auth/
      cubit/                   # auth_cubit.dart, auth_state.dart
      view/                    # login, signup, forgot_password, verification screens
    home/
      view/                    # home_screen.dart (role router), student_shell.dart,
                                # student_home_screen.dart, startup_home_screen.dart
    opportunities/
      cubit/                   # opportunity_cubit.dart, opportunity_state.dart
      view/                    # post_opportunity_screen.dart, opportunity_detail_screen.dart
    profile/
      profile_screen.dart
  models/
    app_user.dart
    startup.dart
    opportunity.dart
    application.dart
  repositories/
    auth_repository.dart
    startup_repository.dart    # currently unimplemented, see Known Limitations
    opportunity_repository.dart
    application_repository.dart
    profile_repository.dart
    admin_repository.dart
  firebase_options.dart
  main.dart
```

## Data Model

All models are `Equatable` and implement `toMap()` / `fromMap()` for
Firestore (de)serialization.

**AppUser** (`lib/models/app_user.dart`)
| Field | Type |
|---|---|
| `uid` | `String` |
| `fullName` | `String` |
| `email` | `String` |
| `role` | `UserRole` (`student`/`startup`/`admin`) |
| `skills` | `List<String>` |
| `bio` | `String?` |
| `photoUrl` | `String?` |
| `resumeUrl` | `String?` |
| `resumeFileName` | `String?` |
| `identityImageUrl` | `String?` |
| `createdAt` | `DateTime` |

**Startup** (`lib/models/startup.dart`)
| Field | Type |
|---|---|
| `startupId` | `String` |
| `ownerUid` | `String` |
| `name` | `String` |
| `email` | `String` |
| `description` | `String` |
| `logoUrl` | `String?` |
| `verificationStatus` | `pending`/`approved`/`rejected` |
| `category` | `String` |
| `website` | `String` |
| `registrationNumber` | `String` |
| `createdAt` | `DateTime` |

**Opportunity** (`lib/models/opportunity.dart`)
| Field | Type |
|---|---|
| `opportunityId` | `String` |
| `startupId` | `String` |
| `startupName` | `String` |
| `title` | `String` |
| `description` | `String` |
| `category` | `String` |
| `skillsRequired` | `List<String>` |
| `commitment` | `String` |
| `locationType` | `String` |
| `isOpen` | `bool` |
| `createdAt` | `DateTime` |

**Application** (`lib/models/application.dart`)
| Field | Type |
|---|---|
| `applicationId` | `String` |
| `opportunityId` | `String` |
| `opportunityTitle` | `String` |
| `startupName` | `String` |
| `studentUid` | `String` |
| `studentName` | `String` |
| `resumeUrl` | `String?` |
| `studentSkills` | `List<String>` |
| `status` | `ApplicationStatus` (`applied`/`underReview`/`interview`/`accepted`/`closed`) |
| `message` | `String?` |
| `appliedAt` | `DateTime` |

Records are denormalized on purpose (e.g. `startupName` and
`opportunityTitle` are copied onto `Application`) so list views can render
without extra joins/reads.

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) matching Dart
  `^3.12.1`
- A Firebase project with **Authentication** (Email/Password + Google) and
  **Cloud Firestore** enabled
- (Optional, for Google Sign-In) an OAuth web client ID from the Firebase/
  Google Cloud console

### Firebase Setup

1. Create a Firebase project and register your Android/iOS apps in it.
2. Enable **Email/Password** and **Google** sign-in providers under
   Authentication.
3. Create a **Cloud Firestore** database (the app expects the collections
   described in [Firestore Structure](#firestore-structure) — no manual
   creation needed, they're created on first write).
4. This repo does not commit a `firebase.json` / FlutterFire CLI config, so
   `lib/firebase_options.dart` should be regenerated for your own project
   with:
   ```powershell
   flutterfire configure
   ```

### Environment Configuration

The app reads Firebase/Google config at **compile time** via
`String.fromEnvironment` (see `lib/core/config/env.dart`) rather than a
committed config file. Copy the example file and fill in your own values:

```powershell
copy .env.example .env
```

`.env` is a JSON file with the following keys (all required):

```json
{
  "GOOGLE_SERVER_CLIENT_ID": "your-google-server-client-id",
  "FIREBASE_ANDROID_API_KEY": "your-android-api-key",
  "FIREBASE_ANDROID_APP_ID": "your-android-app-id",
  "FIREBASE_ANDROID_CLIENT_ID": "your-android-client-id",
  "FIREBASE_IOS_API_KEY": "your-ios-api-key",
  "FIREBASE_IOS_APP_ID": "your-ios-app-id",
  "FIREBASE_IOS_CLIENT_ID": "your-ios-client-id",
  "FIREBASE_IOS_BUNDLE_ID": "your-ios-bundle-id",
  "FIREBASE_MESSAGING_SENDER_ID": "your-sender-id",
  "FIREBASE_PROJECT_ID": "your-project-id",
  "FIREBASE_STORAGE_BUCKET": "your-storage-bucket"
}
```

`.env` is gitignored — never commit real credentials to source control.

### Running the App

```powershell
flutter pub get
flutter run --dart-define-from-file=.env
```

To build a release artifact, pass the same flag, e.g.:

```powershell
flutter build apk --dart-define-from-file=.env
```

## Firestore Structure

Collection paths are centralized in
`lib/core/constants/firestore_paths.dart`. All four collections are flat
(no subcollections) and use foreign-key-style fields instead:

| Collection | Doc ID | Notes |
|---|---|---|
| `users` | Firebase Auth `uid` | One `AppUser` per account |
| `startups` | Owner's `uid` | `verificationStatus` is flipped by an admin; a `verificationReviewedAt` server timestamp is stamped on review |
| `opportunities` | Auto-generated | Student feed queries `isOpen == true`; startup view queries `startupId == <uid>`; both ordered by `createdAt desc` |
| `applications` | Auto-generated | Queried by `studentUid == <uid>` or `opportunityId == <id>`; a duplicate-application check runs before a new application is created |

Storage security rules (`storage.rules`) scope reads/writes to
`users/{userId}/**` for the authenticated owner, in preparation for the
resume-upload feature described below.

## State Management

Each feature owns a Cubit that streams Firestore data into UI state:

- **`AuthCubit`** — tracks the signed-in `AppUser`, including an internal
  "auth epoch" counter to avoid race conditions between rapid sign-in/out
  events and their async profile fetches.
- **`OpportunityCubit`** — streams either the full open-opportunity feed
  (student view, ranked via `SkillMatcher`) or a startup's own postings.
- **`ApplicationCubit`** — streams a student's own applications or, for a
  given opportunity, all applicants against it.
- **`ThemeCubit`** — light/dark theme toggle, persisted via
  `shared_preferences`.

`SkillMatcher` (`lib/core/utils/skill_matcher.dart`) scores an opportunity
against a student's skills as `matches / required.length` and is used to
rank the "recommended for you" feed.

## Known Limitations / Roadmap

See [REPORT.md](REPORT.md) for the maintained list. Currently:

- **Resume upload to Firebase Storage is not implemented.** `AppUser` and
  `Application` both have a `resumeUrl` field, but there's no UI flow to
  upload a file and populate it yet — this was deferred to keep scope
  focused and avoid the storage-security surface area. In the meantime,
  students can make their case via the free-text cover `message` field on
  an application.
- **`lib/repositories/startup_repository.dart` is an empty stub.** Startup
  document creation currently happens inline inside
  `AuthRepository.signUp` rather than through a dedicated repository.
- **No self-serve admin signup** — the `admin` role must be set manually on
  a user's Firestore document.

## Testing

```powershell
flutter test
```

`test/widget_test.dart` contains the baseline widget test scaffold; expand
it alongside new features.
