# housely

Real-estate listings app built with **Flutter**, **MVVM** and **Cubit**.

## Getting started

```bash
flutter pub get
flutter run
flutter test      # unit + widget tests
flutter analyze   # must stay clean
```

## Architecture

Feature-first MVVM: every feature owns its Model, ViewModel (Cubit) and View —
shared infrastructure lives in `core/`.

```text
lib/
├── main.dart                    # bootstrap: DI → BlocObserver → runApp
├── app/                         # application shell (session scope)
│   ├── app.dart                 # HouselyApp: providers + MaterialApp.router
│   ├── theme_cubit.dart         # app-level ViewModel (light/dark/system)
│   └── bloc_observer.dart       # global transition/error logging
├── core/                        # infrastructure, feature-agnostic
│   ├── constants/               # AppColors, AppDimensions, AppAssets (design tokens)
│   ├── enums/                   # RequestStatus
│   ├── error/                   # Failure (UI) ← FailureMapper ← exceptions (data)
│   ├── network/                 # ApiClient (Dio), ApiEndpoints
│   ├── routing/                 # RoutePaths + GoRouter + AppShell
│   ├── di/                      # get_it service locator
│   ├── theme/                   # AppTheme (light/dark ThemeData)
│   ├── utils/                   # extensions (context, numbers), form_validators
│   └── widgets/                 # ErrorView, AppLoadingIndicator, PropertyImage
└── features/
    ├── splash/                  # cold start (initial route)
    │   ├── viewmodels/          # SplashCubit/State — bootstrap + min display time
    │   └── views/               # SplashView — brand animation, navigates on ready
    ├── onboarding/              # intro carousel, splash → onboarding → login
    │   ├── models/              # OnboardingPage — copy + assets for each page
    │   ├── viewmodels/          # OnboardingCubit/State — index + one-shot completion
    │   └── views/               # OnboardingView — PageView, indicator, CTA, Skip
    ├── auth/                    # sign in + sign up → location permission gate
    │   ├── models/              # User (session, optional username)
    │   ├── datasources/         # AuthDataSource + mock (signIn demo rules, signUp)
    │   ├── repositories/        # AuthRepository (+ impl) — input normalization
    │   ├── viewmodels/          # LoginCubit/State, SignUpCubit/State — validation + inline errors
    │   └── views/               # LoginView, SignUpView + shared widgets/ (fields, social button)
    ├── password_recovery/       # forgot password: one wizard, four screens
    │   ├── models/              # RecoveryContact (already-masked phone/email)
    │   ├── datasources/         # PasswordRecoveryDataSource + mock (latency + demo rules)
    │   ├── repositories/        # PasswordRecoveryRepository (+ impl) — code normalisation
    │   ├── viewmodels/          # PasswordRecoveryCubit/State — shared by all four steps
    │   └── views/               # forgot / verify / reset / success + widgets/ (OTP, cards, header)
    ├── location/                # post-auth gate: permission screen + map picker
    │   ├── models/              # Place (entity)
    │   ├── datasources/         # LocationDataSource + mock (in-memory gazetteer)
    │   ├── repositories/        # LocationRepository (+ impl) — search + selection
    │   ├── viewmodels/          # LocationPickerCubit/State — query, results, selected place
    │   └── views/               # LocationPermissionView, LocationPickerView + widgets/map_canvas
    ├── profile/                 # profile + edit profile (mockup account)
    │   ├── models/              # Profile (entity, formatDateOfBirth without intl)
    │   ├── datasources/         # ProfileDataSource + mock (Brooklyn Simmons demo)
    │   ├── repositories/        # ProfileRepository (+ impl) — read + save
    │   ├── viewmodels/          # ProfileCubit/State, EditProfileCubit/State
    │   └── views/               # ProfileView, EditProfileView + widgets/profile_avatar
    ├── home/                    # landing feed (the design's first tab)
    │   ├── models/              # TopLocation, HomeFeedPlan, HomeFeed (entities)
    │   ├── datasources/         # HomeDataSource + mock (section membership only)
    │   ├── repositories/        # HomeRepository (+ impl) — joins PropertyRepository
    │   ├── viewmodels/          # HomeCubit/State — feed, failure, selected chip
    │   └── views/               # HomeView + widgets/ (cards, tiles, chips, hearts)
    ├── booking/                  # checkout (My Booking tab + details' Rent now)
    │   ├── models/               # PaymentCard (grouped number, mask, last4)
    │   ├── datasources/          # BookingDataSource + mock (500ms confirm)
    │   ├── repositories/         # BookingRepository (+ impl) — range normalisation
    │   ├── viewmodels/           # BookingCubit/State (session), AddCardCubit/State
    │   └── views/                # BookingView, AddCardView + widgets/ (card, sheets)
    ├── properties/              # Model + ViewModel + View
    │   ├── models/              # Property (entity), PropertyModel (DTO)
    │   ├── datasources/         # PropertyDataSource + mock + REST impl
    │   ├── repositories/        # PropertyRepository (+ impl) → entities
    │   ├── viewmodels/          # PropertiesCubit/State, PropertyDetailsCubit/State
    │   └── views/               # PropertiesView, PropertyDetailsView, widgets/
    └── favorites/
        ├── viewmodels/          # FavoritesCubit/State
        └── views/               # FavoritesView
```

### MVVM contract

| Layer | Role | Rule |
| --- | --- | --- |
| **View** (`views/`, `widgets/`) | Renders state, forwards user intents | Never awaits, never contains business logic |
| **ViewModel** (`viewmodels/`, a Cubit) | Owns async flow + state for one screen | Never imports Flutter widgets |
| **Model** (`models/`, `repositories/`, `datasources/`) | Data: entities, DTO mapping, transport | Never knows a widget or a Cubit exists |

Data flows one way: **View → Cubit → Repository → DataSource**, and back as an
immutable `State` object.

Errors follow the same path: data sources throw `AppException` subtypes, the
repository normalises them, `FailureMapper` turns them into a `Failure`, and the
View renders `Failure.message` through `ErrorView`.

### State lifecycle

Every screen uses the same three-line contract from `RequestStatus`:

```text
initial → loading → success | failure
```

so views can stay a single `switch` (`PropertiesView` is the reference
implementation).

### Dependency injection

`core/di/injection.dart` registers long-lived objects only (API client, data
sources, repositories). Cubits are created per screen with `BlocProvider`;
`PropertiesCubit`, `FavoritesCubit`, `BookingCubit` and `ThemeCubit` are
session-scoped in `app/app.dart`.

The app currently runs on `MockPropertyDataSource` (an offline fixture that
mirrors the design kit's Yogyakarta/Bali listings, so Home, Explore, Favorites
and Details all render the same corpus). To go live, register
`PropertyRemoteDataSource` instead — no other file changes.

### Routing

`core/routing/app_router.dart` boots into `/splash`. The signed-in app lives in
a five-branch `StatefulShellRoute` (`/home`, `/explore`, `/favorite`,
`/bookings`, `/profile`) rendered by a custom `AppShell` bottom bar — a purple
indicator sits over the active tab and each branch keeps its own state;
`/property/:id`, `/profile/edit`, `/booking` and `/booking/add-card` are pushed
on the root navigator above the
bar, and `/home/popular` is pushed *inside* the Home branch so the tab bar
stays visible and its back arrow returns to the feed, while
`/location-permission` and `/location-picker` sit *outside* the
shell because they are the post-auth gate. Paths live in `RoutePaths` — never
inline a route string. The public flow is linear and explicit:
`/splash → /onboarding → /login ⇄ /signup`, and a successful sign-in *or*
sign-up lands on `/location-permission`. *Skip*, *Use current location*
(stubbed) and *Select it manually → Choose location* all resolve to
`/explore`. From the sign-in screen, `Forgot password ?` enters the recovery
wizard (`/forgot-password → /verify-code → /reset-password → /password-changed`),
which lives in a `ShellRoute` because the four screens are steps of one flow.

The splash itself is a normal MVVM feature: `SplashCubit` runs the bootstrap
(`sl.allReady()` today — remote config, cached reads tomorrow) while enforcing a
minimum display time, `SplashView` plays the logo/wordmark animation and calls
`context.go(RoutePaths.onboarding)` exactly once when the state turns `success`.
Onboarding mirrors that shape: `OnboardingPage` holds the copy and assets,
`OnboardingCubit` is a tiny state machine (index + one-shot `completed`), and
`OnboardingView` renders the `PageView` and hands over to the login screen on
*Next* on the last page, *Get started* or *Skip*.

Login is a full MVVM slice: `MockAuthDataSource` → `AuthRepository` →
`LoginCubit` → `LoginView`. The Cubit validates locally, maps the result with
`FailureMapper` and decides **where** an error belongs: an `AuthFailure`
becomes the inline "The entered password is wrong !" message from the design,
anything else (`NetworkFailure`, `ServerFailure`, …) becomes a snackbar. On
`RequestStatus.success` the View does `context.go(RoutePaths.locationPermission)`.

> **Demo credentials:** any valid email + password `housely123`. Anything else
> reproduces the design's error state.

Sign-up is the mirror slice with one extra gate: `SignUpCubit` validates the
email, username, password and the *Agree with terms and privacy* checkbox
(`SignUpState` carries one error slot per field, so each message renders where
the design puts it), then calls `AuthRepository.signUp`. Before an account
exists there is no credential to reject, so a repository failure is always
transport/policy-scoped and surfaces as a snackbar — never a red border. The
two auth screens link both ways (`Sign up` → `/signup`, `Sign in` → `/login`),
and shared form pieces (field label, input decoration, social button) live in
`views/widgets/` so both screens render identically.

Password recovery is one wizard in four screens — *Forgot Password* (pick a
masked contact) → *Verify your Email* → *Create New Password* → *Success*. The
steps share state, so the router wraps them in a `ShellRoute` that provides a
single `PasswordRecoveryCubit`; each screen only renders state and decides
where to go next. `MockPasswordRecoveryDataSource` returns already-masked
contacts (`mu***@gmail.com`), accepts any six digits for the code and delays
600ms so loading states are real. Field errors are local
(`Please enter the 6 digit code.`, `Passwords do not match.`); repository
failures are snackbars, never red borders; `Resend code` is stubbed with a
snackbar until a backend exists. The OTP is one hidden `TextField` behind six
designed boxes — `PasswordRecoveryState.codeLength` is the single constant if
the design ever changes length. *Continue* finishes with
`context.go(RoutePaths.login)`, dropping the whole recovery stack from history.

Location is the post-auth gate in two screens. `LocationPermissionView` is
view-only (no Cubit): *Skip*, *Use current location* (an honest snackbar — no
geolocation plugin until a backend needs it) and *Select it manually* all hand
over to `LocationPickerView`. The picker runs `LocationPickerCubit` over
`MockLocationDataSource` (in-memory gazetteer with simulated latency): search
query, results, selection. The map is a hand-authored deterministic
`CustomPainter` (`views/widgets/map_canvas.dart`) — streets, park, river,
labels and marker are drawn from `AppColors.map*`, so it renders identically
in widget tests without a maps SDK. The back arrow returns to the permission
screen; *Choose location* enters the shell.

Profile is a full MVVM slice over `MockProfileDataSource` (Brooklyn Simmons
demo account): `ProfileCubit` renders the header, the initials-based
`ProfileAvatar` and the menu rows, while `EditProfileCubit` owns prefill-once,
inline validation, the read-only `Date of birth` row
(`Profile.formatDateOfBirth`, month names without `intl`) and saving.
`EditProfileView` keeps its own controllers so typing survives rebuilds; save
success confirms with a snackbar and steps back to Profile. Menu rows and the
camera badges are honest stubs (`"$label isn't available in this build yet."`
snackbars); *Sign Out* returns to `/login`, and the avatar (or *Edit profile*)
opens `/profile/edit` on the root navigator.

Home is a full MVVM slice rendered from the design's landing feed.
`MockHomeDataSource` returns a `HomeFeedPlan` — ids only (recommended,
nearby, popular, destination chips) — and `HomeRepositoryImpl.getFeed()` joins
it against `PropertyRepository`, so one corpus backs every screen. The View is
chrome + rails: a location header with bell/chat stubs, a search field and the
promo banner (both hand off to Explore / a snackbar), then *Recommended*
(featured-card rail), *Nearby* (two-row grid rail), *Top Locations* (selection
chips driven by `HomeCubit.selectTopLocation`) and *Popular for you* (rows
whose *See all* pushes `/home/popular` — the feed shows the first three rows
like the mockup, the pushed screen the full membership through `PopularCubit`).
Rails bleed off the right edge like the mockup while text keeps the page
gutter; hearts share the session `FavoritesCubit` with the Favorites tab, and
loading shows a static skeleton — never shimmer, which would hang
`pumpAndSettle` in tests.

Favorites is the design's *Favorite* list: `FavoritesCubit` owns the liked ids
(session-scoped, seeded with the mockup's hearts) while `PropertiesCubit` owns
the listings — the View joins them into compact `PopularTile` rows split by
hairline dividers, identical to the Popular screen. Hearts toggle honestly, the
AppBar back arrow steps back to Home, and an empty set renders the designed
empty state.

Listing details is the design's full page: an inset rounded photo pager (page
dots plus a tappable thumbnail strip whose active thumb gets the primary
outline), title with the purple inline price, a `Property Details` facts grid
(`toSqft()` bills area in square feet like the mockup), a clamped description
with an inline *Read more* toggle, the agent card with call/chat stubs, a
`Location & Public Facilities` chip rail over the shared `MapCanvas`, and the
review cards — all capped by a pinned purple *Rent now* bar. The AppBar share
icon opens `ShareSheet`, a bottom sheet with the design's 3×2 grid of social
targets; *Rent now* starts the checkout session for that listing and pushes
`/booking`, while every remaining stub action (calling, messaging, sharing,
*See all* reviews) is an honest snackbar until a backend exists.

Booking is the checkout slice behind both entries — the *My Booking* tab
(renders the same `BookingView` on `/bookings`, Batavia Apartments by default)
and details' *Rent now*. The session `BookingCubit` holds the listing id, the
period, the attached card and the confirm status, so a card saved through
`/booking/add-card` is attached on either entry. `BookingView` reproduces the
design: the property card from the corpus, a tappable period row whose
`SelectDateSheet` is a real six-week range calendar (solid purple endpoints,
pale middle, working month arrows; the sheet edits a temp copy and *Save*
commits), payments where *Credit or Debit card* pushes the Add Card form while
Paypal and the voucher are honest stubs, and a price breakdown computed from
the listing (monthly payment + `$10.00` tax + total). The helper line about
checking your dates shows only while no payment method is attached — exactly
what both mockups show. `Confirm and Pay` pins only once a card exists, runs
the mock gateway's 500ms confirm with a disabled button (never a spinner) and
raises `BookingSuccessSheet` → *Explore more* → `/explore`. `AddCardCubit`
validates the four fields with per-field errors over the mockup's prefilled
sample card, and never stores the CVV when re-editing an attached card.

The shell itself is a custom five-tab `AppShell` (`Home · Explore · Favorite ·
My Booking · Profile`) with a purple indicator over the active item — Material's
`NavigationBar` cannot express the design's indicator. All five tabs are real
feature screens now — My Booking renders the checkout — and the whole surface
is covered by `test/core/routing/shell_navigation_test.dart` (tab switching
keeps branch state, a favourite card pushes details over the shell, *Rent now*
runs the checkout through Add Card to the success sheet) plus the feature
suites.

Logo, social marks, field icons, gallery photos and the promo banner are
addressed through `AppAssets`, registered under `assets:` in `pubspec.yaml`.

## Adding a feature

1. `features/<name>/models/` — entity + DTO.
2. `features/<name>/datasources/` + `repositories/` — implement the data layer.
3. Register the repository in `core/di/injection.dart`.
4. `features/<name>/viewmodels/` — `XxxCubit` + `XxxState` (`Equatable`).
5. `features/<name>/views/` — build the View on top of `RequestStatus`.
6. Add the route to `RoutePaths` / `app_router.dart`.
7. Cover the Cubit with a `bloc_test` under `test/features/<name>/…`.

## Design tokens

`core/constants/app_colors.dart` is the single source of truth for color — the
full palette from the Figma **Color** page (gray, primary, error, success,
warning and the six secondary gray scales) plus semantic aliases
(`AppColors.background`, `AppColors.textPrimary`, `AppColors.primary`, …).
Hex values never appear outside that file — including the screen-specific
map-canvas colors (`AppColors.mapLand`, `mapBlock`, `mapRoad`, `mapWater`,
`mapPark`, `mapMarker`) and the three shadow alpha hexes. Spacing/radii/motion
live in `AppDimensions`.
