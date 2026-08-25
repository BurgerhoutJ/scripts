# Intune OS version compliance automation

Keeps `osMinimumVersion` on Intune device compliance policies pinned to
**n-1** (current major version minus one) for iOS/iPadOS, macOS, Windows, and
Android, and clears `osMaximumVersion` (no upper bound). Also updates
**conditional launch** settings on App Protection Policies for iOS and Android
(minimum OS version, and for Android the minimum security patch level). Runs
as an Azure Automation runbook on a schedule.

## How it decides "n-1"

Version history comes from [endoflife.date](https://endoflife.date)'s public
JSON API (`https://endoflife.date/api/{ios,macos,windows,android}.json`) — one
consistent schema across all four platforms, community-maintained, no auth
needed.

- **iOS/iPadOS, macOS, Android**: sorted by release date, take the *second*
  most recent released major version. This is deliberately positional, not
  "current major − 1" arithmetic — Apple's numbering jumped from 18 straight
  to 26 in 2025 (unified year-based versioning), so subtraction would silently
  compute nonsense.
- **Windows**: Windows' `cycle` values encode feature update + servicing
  channel (e.g. `11-25h2-e`) and don't sort meaningfully. Instead the script
  takes the actual OS build numbers (`10.0.26200`, etc.), dedupes, and picks
  the second most recent build.

## Known rough edges

- **Windows** is the least clean of the four: with enablement-package-based
  feature updates, the "build number" doesn't always move the way you'd
  expect between H1/H2 releases. Treat its first few dry-run outputs with
  more scrutiny than iOS/macOS.
- **Android** major-version compliance is a blunt instrument in practice (most
  orgs care more about security patch level than major OS version), but the
  script follows the same n-1-major-version rule you described for
  consistency.
- If `endoflife.date` is unreachable or a platform's data doesn't parse, that
  platform is skipped for the run (nothing is guessed or left half-applied).

## App Protection Policies (conditional launch)

For iOS and Android, the script also updates `minimumRequiredOsVersion` on
Managed App Protection policies (the "conditional launch" settings in the
Intune portal).

- **Android** additionally gets `minimumRequiredPatchVersion` set to the first
  of the month N months ago, controlled by the `-PatchLevelMonthsBack`
  parameter (default: **6**).
- The same `IntuneOSVersion-AutoApplyPlatforms` whitelist and
  `IntuneOSVersion-ExcludePolicyIds` exclusion list apply to App Protection
  Policies too.

## One-time setup

1. **Automation Account**: create one (or reuse an existing one) with a
   **system-assigned managed identity** enabled (Automation Account >
   Identity > System assigned > On).
2. **Grant Graph permission**: from a machine with the
   `Microsoft.Graph.Applications` module, as a Global Administrator or
   Privileged Role Administrator, run:

   ```powershell
   ./Grant-ManagedIdentityGraphPermissions.ps1 -AutomationAccountManagedIdentityObjectId "<object-id-from-identity-blade>"
   ```

   This grants `DeviceManagementConfiguration.ReadWrite.All` (compliance
   policies) and `DeviceManagementApps.ReadWrite.All` (app protection
   policies) — application permissions, no admin consent screen needed since
   they're direct app role assignments.

3. **Import the runbook**: Automation Account > Runbooks > Import, upload
   `Update-IntuneOSVersionCompliance.ps1`, runtime = PowerShell 7.2. The
   `Az.Accounts` module is preinstalled in Automation's PowerShell 7.2
   runtime — no extra module import needed.

4. **Automation Variables** (Automation Account > Variables):
   - `IntuneOSVersion-AutoApplyPlatforms` — comma-separated list of platforms
     allowed to actually be written (`ios`, `macos`, `windows`, `android`).
     **Leave this unset/empty at first** — every platform runs as a dry run
     regardless of the `-Apply` switch until it's explicitly whitelisted here.
   - `IntuneOSVersion-ExcludePolicyIds` *(optional)* — comma-separated Intune
     compliance policy GUIDs that should never be touched.

5. **First run — dry run**: run the runbook manually with no parameters (or
   `-Apply` — it doesn't matter, nothing is whitelisted yet). Read the output
   log: it lists every policy it would change and the old → new values.
   Confirm the computed baselines look right before trusting it with writes.

6. **Turn on writes**: once you're confident, add the platforms you trust to
   `IntuneOSVersion-AutoApplyPlatforms` (e.g. start with just `ios,macos`,
   add `windows,android` later once you've watched a few Windows dry runs).

7. **Schedule**: Automation Account > Schedules, create one (weekly is
   reasonable — OS releases don't happen daily), link it to the runbook with
   parameter `Apply = true`. The Automation Variable whitelist is still the
   actual write gate, so linking with `Apply = true` is safe even before
   you've whitelisted every platform.

## Rollback

The script only ever touches `osMinimumVersion` / `osMaximumVersion` on
compliance policies and `minimumRequiredOsVersion` /
`minimumRequiredPatchVersion` on app protection policies. Intune keeps an
audit log of both compliance and app protection policy changes (Intune admin
center > Tenant administration > Audit logs), which you can use to see and
manually revert the previous values if a run ever computes something wrong.
