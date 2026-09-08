# Sahayak UI/UX Refresh from Reference Recording Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refresh Sahayak's visual layout, spacing, typography, card structures, and component designs to match the reference recording's modern home-services UX patterns while preserving 100% of Sahayak's existing brand colors, functionality, cooperative labour business model, data flow, and navigation.

**Architecture:** Maintain existing Flutter MVVM architecture (`AppViewModel` + `AppRepository` + feature screens). Preserve the established `SahayakColors` cooperative palette. Re-layout and refresh feature screens one-by-one (`MarketplaceHomeScreen`, `Step1ProblemDetailsScreen`, `Step3WorkerMatchingScreen`, `BookingDetailsScreen`, `ProfileSettingsScreen`) using modular sub-widgets (carousels, variant grids, star breakdowns, review cards, settings list tiles).

**Tech Stack:** Flutter 3.x, Dart 3.x, Material 3, `SahayakColors` (preserved), `AppViewModel` (ChangeNotifier).

**Spec:** Antigravity Implementation Prompt — Sahayak UI/UX Refresh from Reference Recording.

## Global Constraints

- **DO NOT CHANGE THE COLORS**: Retain Sahayak's established color scheme in `lib/core/theme/colors.dart` (`SahayakColors.primary` #004AC6, `primaryContainer` #2563EB, `secondary` #006C49, `surface` #FAF8FF, etc.).
- Do NOT clone reference branding, logo, company name, or proprietary text.
- Do NOT add unrelated features (e.g. No "Invest" tab, no multi-item shopping cart).
- Preserve existing 3-tab navigation (`Home`, `Bookings`, `Profile`).
- Preserve all existing business logic: Doorstep 4-digit OTP, 1-hour cancellation policy, multi-domain trade matching, transparent cooperative pricing.
- Work one screen at a time, verifying tests and static analysis after each step.

---

### Task 1: Shell & Persistent Bar Layout (Preserving Colors)

**Files:**
- Modify: `lib/ui/shared_widgets/cooperative_app_bar.dart`
- Modify: `lib/ui/shared_widgets/bottom_nav_bar.dart`
- Test: `test/widget_test.dart`

**Interfaces:**
- Consumes: `AppViewModel` getters: `selectedLanguage`, `currentWard`, `currentUser`, `currentTab`.
- Produces: Polished location header with location selector & profile avatar; clean bottom tab bar with 3 tabs and active state.

- [ ] **Step 1: Polish CooperativeAppBar Layout**
In `lib/ui/shared_widgets/cooperative_app_bar.dart`:
- Maintain `SahayakColors.surface` / `surfaceContainerLowest`.
- Align brand logo, "📍 Ward 5 / Location" chip with dropdown arrow, and profile avatar.
- Provide clean back button support with `SahayakColors.onSurface` when `showBackButton: true`.
- Keep the `_showWardPicker` bottom sheet with GPS detection and society list fully functional.

- [ ] **Step 2: Polish CooperativeBottomNavBar with Reference Structural Pattern**
In `lib/ui/shared_widgets/bottom_nav_bar.dart`:
- Clean white surface with subtle top border (`SahayakColors.borderSubtle`).
- Active tab uses `SahayakColors.primary` for icon and label text.
- Inactive tabs use `SahayakColors.onSurfaceVariant`.
- Preserve badge count on Bookings tab.
- Keep exact 3 tabs: Home, Bookings, Profile.

- [ ] **Step 3: Verify with Automated Tests**
Run `flutter test test/widget_test.dart`.
Expected: PASS.

- [ ] **Step 4: Commit Shell Updates**
```bash
git add lib/ui/shared_widgets/
git commit -m "style: polish app bar and bottom nav bar layout preserving brand colors"
```

---

### Task 2: Marketplace Home Screen — Search-First, Icon Grid & Promo Carousel

**Files:**
- Modify: `lib/ui/features/marketplace/marketplace_home_screen.dart`
- Test: `test/widget_test.dart`

**Interfaces:**
- Consumes: `AppViewModel.filteredServices`, `AppViewModel.setSearchQuery`, `AppViewModel.setTimingMode`.
- Produces: Refreshed Home Screen with search bar, category icon grid, auto-sliding promo banner, and horizontal "See All" service rows using existing colors.

- [ ] **Step 1: Implement Search Bar and Live Discovery List**
In `lib/ui/features/marketplace/marketplace_home_screen.dart`:
- Add a prominent search input field with search icon, clear button, and placeholder ("Search 'plumber', 'tap leak', 'electrician'...").
- Wire onChanged to `widget.viewModel.setSearchQuery` to filter services in real time.
- When search query is non-empty, render a flat category list with thumbnail, title, description, and chevron, matching the reference Search pattern.

- [ ] **Step 2: Implement 8-Category Icon Grid**
- Render an 8-item category grid (2 rows x 4 columns) with circular/rounded icon badges:
  - Plumber, Electrician, Cleaner, Carpenter, Caregiver, Driver, Gardener, Appliance Tech.
- Each tile displays icon container (using `SahayakColors.primaryFixed`), title label, and starting price tag (e.g. `₹249`).
- Tapping any category selects the mode and opens the booking wizard for that service.

- [ ] **Step 3: Implement Auto-Rotating Promo Banner Carousel**
- Create a horizontal page-view carousel displaying 3 curated cooperative banners using existing theme palettes:
  1. *Cooperative Fair-Wage Guarantee*: 100% of labour fees go directly to verified local workers. Zero surge pricing.
  2. *Monsoon Preparedness Drive*: Roof leakage, concealed pipe, and drainage inspection by certified pros.
  3. *Emergency SOS Dispatch*: Priority technician arrival in under 20 minutes across your ward.
- Include auto-timer rotation and smooth dot indicators.

- [ ] **Step 4: Implement Horizontally-Scrolling "See All" Service Rows**
- Add section headers with "See All" action buttons:
  - "Popular Services": Horizontally scrolling cards with service icon, title, rating (`4.9 ★`), base rate, and "Book" button.
  - "Emergency Ready (SOS)": Priority dispatch trade cards with emergency accent pill and rapid response ETA.
- Preserve Sahayak's emergency vs standard mode selection cards and bottom-sheet domain selector.

- [ ] **Step 5: Run Static Analysis & Tests**
Run `dart analyze` and `flutter test`.
Expected: PASS with 0 issues.

- [ ] **Step 6: Commit Home Screen Refresh**
```bash
git add lib/ui/features/marketplace/marketplace_home_screen.dart
git commit -m "feat(ui): refresh home screen with search-first bar, category grid, and promo carousel"
```

---

### Task 3: Category Landing & Step 1 Wizard — Segmented Tabs, Service Cards & Variant Grid

**Files:**
- Modify: `lib/ui/features/booking_wizard/step1_problem_details.dart`
- Test: `test/widget_test.dart`

**Interfaces:**
- Consumes: `ServiceItem`, `ServiceSubcategory`, `AppViewModel.wizardProblemDescription`, `wizardSelectedSubcategoryId`.
- Produces: Category landing screen with segmented intent tabs, service cards with duration and price, variant grid, expandable trust accordion, and problem details input.

- [ ] **Step 1: Add Header Strip & Segmented Intent Tabs**
In `lib/ui/features/booking_wizard/step1_problem_details.dart`:
- Add top offer/guarantee strip: "🛡️ Cooperative Certified • Fixed Standard Rates • 0% Platform Commission".
- Add segmented tab row: `[ Service ]`, `[ Repair ]`, `[ Installation ]`, `[ Inspection ]` allowing users to filter sub-trades.

- [ ] **Step 2: Re-skin Subcategory Variant Grid with Individual Pricing**
- For the selected service, render subcategories (e.g. Tap Repair, Leakage & Pipe, Drainage & Blockage, Sanitary Fitting, Tank & Motor, Other) in a clean variant grid.
- Each variant card includes:
  - Clean thumbnail/icon, title, and subtext.
  - Starting price tag (e.g. `₹249 base`).
  - Radio/checkbox indicator showing selected state.

- [ ] **Step 3: Add Expandable Process, Included & FAQ Content**
Below the variant grid and problem description:
- Numbered process steps:
  1. *Formulate Request*: Describe issue & optionally attach photos.
  2. *Worker Match*: Nearest verified society worker bids or accepts.
  3. *Doorstep OTP*: Secure 4-digit code starts the job.
  4. *Fair Settlement*: Transparent invoice & rating.
- Checklist of what's included:
  - "✓ Certified cooperative member technician"
  - "✓ Standard visit & diagnosis included"
  - "✓ 30-day post-service workmanship guarantee"
  - "✗ Cost of major spare replacement parts (billed at MRP)"
- FAQ Accordion with expandable items:
  - "How does cooperative pricing work?"
  - "Can I cancel or reschedule?"
  - "How is the Doorstep OTP verified?"

- [ ] **Step 4: Preserve Mandatory Description & Attachments**
- Maintain required problem description validation (`* Required`).
- Maintain photo and video attachment carousels.
- Maintain multi-trade toggle support for complex issues.

- [ ] **Step 5: Verify Step 1 Wizard Navigation**
Run `dart analyze` and `flutter test`.
Expected: PASS.

- [ ] **Step 6: Commit Step 1 Wizard Refresh**
```bash
git add lib/ui/features/booking_wizard/step1_problem_details.dart
git commit -m "feat(ui): refresh booking wizard step 1 with segmented tabs, variant grid, and trust accordion"
```

---

### Task 4: Worker Acceptance, Ratings & Reviews Screen

**Files:**
- Modify: `lib/ui/features/booking_wizard/step3_worker_matching.dart`
- Test: `test/widget_test.dart`

**Interfaces:**
- Consumes: `AppViewModel.availableOffers`, `AppViewModel.selectOffer`, `WorkerOffer.worker`.
- Produces: Big rating summary, 5-star bar breakdown, review cards with avatar initial and date, and "Why this worker" panel using existing colors.

- [ ] **Step 1: Implement Big Rating & Star-Bar Breakdown Component**
In `lib/ui/features/booking_wizard/step3_worker_matching.dart`:
- When viewing a worker's details or offer, render a prominent rating header:
  - Large numeric rating (e.g., `4.9`), 5 gold stars (`SahayakColors.tertiary`), and total verified job count (`142 jobs`).
  - 5-row bar breakdown:
    - 5 ★ [====================] 88%
    - 4 ★ [====                ] 9%
    - 3 ★ [=                   ] 2%
    - 2 ★ [                    ] 1%
    - 1 ★ [                    ] 0%

- [ ] **Step 2: Refresh Individual Review Cards**
- Render each customer review with:
  - Avatar circle with author initial and distinct pastel background.
  - Author name + "Verified Resident (Sector 4)" badge.
  - Star rating and relative date (e.g. "3 days ago").
  - Quoted customer comment text.

- [ ] **Step 3: Implement "Why this worker" Trust Panel**
- Highlight key cooperative worker credentials:
  - "Cooperative Member ID: SAH-WRK-2024"
  - "Police verification & trade certification verified"
  - "Resident within 1.4 km of your society"
  - "Average response time: 14 mins"

- [ ] **Step 4: Keep Sort Bar and Selection Mechanism**
- Keep sort tabs: Rating, Fee, Distance.
- Keep one-click radio selection and "Confirm & Book Pro" primary action button.

- [ ] **Step 5: Run Static Analysis & Tests**
Run `dart analyze` and `flutter test`.
Expected: PASS.

- [ ] **Step 6: Commit Step 3 Matching Refresh**
```bash
git add lib/ui/features/booking_wizard/step3_worker_matching.dart
git commit -m "feat(ui): refresh worker matching with big rating, star breakdown, and review cards"
```

---

### Task 5: Booking Details & Job Proof Display

**Files:**
- Modify: `lib/ui/features/booking_status/booking_details_screen.dart`
- Test: `test/my_bookings_screen_test.dart`

**Interfaces:**
- Consumes: `Booking`, `AppViewModel.simulate1HourPreServiceUpdate`, `AppViewModel.verifyDoorstepOtp`.
- Produces: Enhanced job timeline tracker, job proof showcase (interactive before/after slider or photo cards), OTP card, and invoice breakdown.

- [ ] **Step 1: Implement Before/After Job Proof Showcase**
In `lib/ui/features/booking_status/booking_details_screen.dart`:
- For completed or in-progress bookings with media, add an interactive before/after image card with comparison toggle/slider or clean side-by-side tabs.
- Allows residents to inspect work completion evidence.

- [ ] **Step 2: Re-skin Timeline & Security OTP Card**
- Re-skin the vertical status timeline with clean step nodes, active pulse, and clear timestamp labels using existing colors.
- Format the 4-digit Doorstep OTP card with high-contrast digits and security warning ("Share only after pro arrives").

- [ ] **Step 3: Verify All Existing Booking Screen Actions**
Run `flutter test test/my_bookings_screen_test.dart`.
Expected: PASS.

- [ ] **Step 4: Commit Booking Details Refresh**
```bash
git add lib/ui/features/booking_status/booking_details_screen.dart
git commit -m "feat(ui): refresh booking details with job proof showcase and polished timeline"
```

---

### Task 6: Account & Profile Screen — Plain Settings List

**Files:**
- Modify: `lib/ui/features/profile/profile_settings_screen.dart`
- Test: `test/widget_test.dart`

**Interfaces:**
- Consumes: `AppViewModel.currentUser`, `userMemberId`, `addresses`, `whatsappUpdates`, `smsOtp`, `strings`.
- Produces: Clean plain settings list layout organized into clear functional groups using existing colors.

- [ ] **Step 1: Group Settings into Clear Functional Sections**
In `lib/ui/features/profile/profile_settings_screen.dart`:
- Reorganize into structured sections with subtle section headers:
  1. *Profile Header Card*: User avatar, name, phone, society, cooperative member ID chip (`#SHK-482109`).
  2. *Addresses & Locations*: Saved addresses (Home, Office), "+ Add New Address".
  3. *Cooperative Membership & Finance*: Co-op Dividend Share, Tax Invoices & Payment Receipts.
  4. *Preferences*: App Language (English / தமிழ் / हिंदी / ಕನ್ನಡ), Notification Toggles (WhatsApp, SMS OTP, Booking Reminders).
  5. *Trust & Transparency*: Fair Work Charter, Zero-Surge Guarantee, Cooperative By-laws.
  6. *Account Actions*: Log Out button with confirmation modal.

- [ ] **Step 2: Implement Reference Plain Settings List Tile Pattern**
- Use clean list rows with icon in subtle container, title, subtitle / value pill, and trailing chevron (`>`).
- Preserve all existing dialogs: Edit Profile, Add/Edit Address, Tax Invoice popup, Language bottom sheet, Logout dialog.

- [ ] **Step 3: Verify Profile Screen Interactions**
Run `flutter test test/widget_test.dart`.
Expected: PASS.

- [ ] **Step 4: Commit Profile Screen Refresh**
```bash
git add lib/ui/features/profile/profile_settings_screen.dart
git commit -m "feat(ui): refresh profile screen into clean grouped settings list"
```

---

### Task 7: Full Verification & Remote Push

**Files:**
- All modified files
- Remote: `https://github.com/SiddharthNishkalan/Sahayak.git`

- [ ] **Step 1: Run Full Test Suite**
Run: `flutter test`
Expected: All tests PASS.

- [ ] **Step 2: Run Dart Analyzer**
Run: `dart analyze`
Expected: No issues found!

- [ ] **Step 3: Push to GitHub Remote**
Run: `git push origin main`
Expected: Successfully pushed to `https://github.com/SiddharthNishkalan/Sahayak.git`.
