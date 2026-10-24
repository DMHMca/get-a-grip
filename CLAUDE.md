# Get a grip: project brief for Claude Code

Read this first. It records what this app is, how it is built and hosted, the rules the owner has agreed, and what is still to do.

## The owner and how to work with them

- The owner has very little coding experience. Explain what you are doing in plain English, give step-by-step instructions for anything they must do themselves, and say exactly what screen they should see.
- Use British English. Be practical and direct. Prefer short prose over bullet lists when talking to them.
- They are frustrated by fragmented tools and sessions. Keep things simple, tell them what changed after each piece of work, and avoid jargon.
- They use an Android phone (Chrome) and a Windows PC. The app is used mostly on the phone.
- Never ask them to paste secrets into chat. Prefer signing in through the tool's own GitHub login.

## What the app is

A minimalist to-do list called **Get a grip**. It is deliberately NOT project-management software: no due dates, no priorities, no nesting.

It is a Progressive Web App (PWA): static files on GitHub Pages, installed on the phone through Chrome ("Install and create shortcut"). There is no server and no build step.

- Repository: `DMHMca/get-a-grip`, branch `main`, root folder.
- Live address: `https://dmhmca.github.io/get-a-grip/`
- The repository is public by choice. Never commit secrets. (A Google OAuth client ID is not a secret.)

## Files

- `index.html`: the whole app (HTML, CSS and vanilla JavaScript in one file, no libraries).
- `sw.js`: service worker. Pages are fetched network-first so updates arrive; other files are cached. **Bump the `CACHE` version string (currently `get-a-grip-v18`) on every release.**
- `manifest.webmanifest`: install details (name, colours, icons).
- `icon-192.png`, `icon-512.png`, `icon-maskable-512.png`, `apple-touch-icon.png`: the icon (six white dots, 2 by 3, on navy).
- `LICENSE`: the MIT licence.
- `privacy.html`: plain-English privacy page, linked from the Sync page and meant for the Google consent screen. Keep it true to what the app does (it mentions Google Fonts and the Drive app-data file).
- `README.md`: the public documentation for GitHub (what the app is, privacy, how the two syncs work, why there is no hosted database, how to use your own Google Cloud project). Keep it in step with the app. It replaces the old `README.txt` upload notes.

## Product rules the owner has agreed (do not change without asking)

1. **Activities** (never called "projects") each hold a flat, ordered list of tasks. No sub-activities and no folders.
2. **Master tasks** shows all open tasks (from activities and standalone tasks) in one list. It was called "All tasks" earlier; the owner renamed it "Master tasks".
3. New tasks go at the **top** of their list. Tasks can be reordered by dragging the grip handle on the right (or ArrowUp/ArrowDown on the focused handle). Activities can be reordered the same way on the Activities page (the order is the order of `activities` in the data; archived activities keep their own slots). New activities are added at the END of the activity list (not the top), which the owner has not asked to change.
4. Ticking a task removes it from Master tasks but keeps it in its activity, struck through, so progress stays visible there. Master tasks has a "Just ticked" strip with a one-tap Restore.
5. A task can be added with no activity, from Master tasks. The add box has an activity picker that can also create a new activity.
6. **Archive** applies to activities, not tasks. Archiving removes the activity from the Activities page into a searchable, sortable Archive page (Archived date, Created date, A to Z; tapping the active sort again reverses it). Open tasks of an archived activity STAY in Master tasks. Archive search covers activity names, dates AND the text of tasks inside archived activities. Restore brings an activity back.
7. Created and ticked dates are recorded silently on activities and tasks. They are never shown on tasks in the normal UI. No due dates and no priorities, ever.
8. Navigation: bottom bar with four buttons, in this order: Archive, Activities, Master tasks, then the last-used activity (named). Swiping left and right moves along the same order. The top bar also has "Master tasks", the current activity tab (tap for the "Go to activity" switcher) and a "+" for a new activity.
9. Tapping a task opens an edit sheet (change text, move to another activity, delete).
10. **Details** (agreed later): any task can carry optional free-text details (a web address, a phone number, extra information). Nothing is shown for a task without details, so there are no empty boxes. A task with details shows a small chevron beside the grip handle that opens and closes the details under the task (closed by default, remembered only until the page is reloaded). Details are added in the task's edit sheet through an "Add details" button, which only then reveals the text box. Web addresses become links and phone numbers (9 to 15 digits) become tap-to-call; everything else stays plain text. Archive search also looks inside details.
11. **Add several** (agreed later): a small "Add several" button beside the add box (on an activity page it targets that activity; on Master tasks it targets the picked activity, or none) opens a sheet where a pasted list, one task per line, is added at the TOP in the order given (`addMany`). It only adds: blank lines and lines already in that activity are skipped, every new task gets a fresh id with `created` and `updated` set, and it refuses to save if any existing task would change. Activities are still created the normal way first.
12. Alarms and reminders are out of scope (a web app cannot do them reliably).

## Design

- The app title "Get a grip" appears once, in small accent-coloured type, above the top bar of every page (`viewKids` adds it; the page views must not add their own). The owner asked for it after it had appeared twice and then disappeared.

- Font: Atkinson Hyperlegible (Google Fonts, with system fallbacks).
- Colours: accent `#234E70`, background `#F3F4F2`, text `#1B1F1D`. Dark mode is supported through CSS variables (`prefers-color-scheme`), keep both themes working.
- Large touch targets (44px or more), safe-area insets respected, `prefers-reduced-motion` respected.
- Use proper typographic punctuation in visible text (’ “ ”).

## Data

- Everything is stored on the phone in `localStorage` under the key `tasks.v1`, as one JSON object: `{ v, updatedAt, activities: [...], tasks: [...] }`.
- Activity: `{ id, name, created, archived }` (`archived` is an ISO date string or `null`).
- Task: `{ id, text, activityId, created, done, gid?, notes?, sid?, gs?, updated? }` (`done` is an ISO date or `null`; `gid` is set on tasks imported from Google Tasks, as `listId:taskId`; `notes` is the optional details text and is absent when empty; `sid` is the two-way sync link `listId:taskId`; `gs` is what Google held at the last sync, `{title,notes,done}`, used to tell which side changed; `updated` is an ISO time stamped on adding, ticking, restoring and editing, used to settle clashes between devices and with Google). Activities also carry an optional `updated`.
- Device-sync fields: `S.gone` is a list of `{id,at}` notes of deleted tasks; `S.ord` is `{t,a}`, the time tasks and activities were last reordered; `S.drive` is this device's on/off setting. Sync settings live in `S.sync`; `S.deleted` holds notes of linked tasks deleted in the app so the deletion can be passed on. Both are optional, so old backups still load. A safety copy is saved in `localStorage` under `tasks.v1.presync` before the first sync.
- Task array order is the display order. Master and activity views are filtered views of the same array; reordering keeps the positions of tasks not shown.
- "Download a backup" and "Restore from backup" (bottom of the Activities page) export and import this JSON. Do not break that format without a migration.
- First-run data is empty (no activities, no tasks). The owner's "AI project audit" starter activity was removed from the code at their request, because a fresh browser (for example on the PC) would otherwise push those four tasks into Google Tasks on its first sync. Do not add starter data back.

## Google Tasks import (built and working)

Activities page, "Import from Google Tasks". One-off, read-only import.

- Uses Google Identity Services token flow (`https://accounts.google.com/gsi/client`, loaded only when needed) and the Tasks REST API with scope `https://www.googleapis.com/auth/tasks.readonly`.
- The owner's OAuth client ID is pasted into the app once and stored in `localStorage` under `gag.clientId`.
- Flow: connect, choose a Google Tasks list, assign each task to an activity (or use "Put all of these in"), then import. There is a "New activity" button in the bottom bar so activities can be created without leaving the page.
- "Only import tasks I have given an activity" is ON by default (`gag.impOnly`). Assignments are kept as a draft in `localStorage` so they survive leaving the page.
- Imported tasks carry `gid`, so re-importing skips ones already imported. Completed Google tasks are not imported. Due dates and notes are dropped. Subtasks arrive as ordinary tasks.
- Google Cloud project: named `get-a-grip` (separate from the owner's SEO project). OAuth consent screen is External and in **Testing**, with the owner's Google account as the only test user. Authorised JavaScript origin: `https://dmhmca.github.io`. Google shows an "unverified app" warning, which is expected.

## Making it easy for family and friends (built; waiting on one value)

Owner's aim: family and friends can use it without Google Cloud work. How it is built:
- `DEFAULT_CID` (top of the sign-in code in `index.html`) is the app's built-in Google client ID, from the owner's second, family-only Google project `get-a-grip-family` (client ID `941879453696-6ob1dsj9mnna0ifiv5dki1h62k78vl3i.apps.googleusercontent.com`; a client ID is public, only a client secret must never be shared, and this app has none). The project is PUBLISHED (status "In production") and the owner confirmed Google showed no unverified-app warning at sign-in. Not yet tried by someone else's Google account. NOTE: the Drive app-data file belongs to the project that created it, so the family sign-in does not see the owner's data (saved under the original `get-a-grip` project). The owner's own devices all use the original project's client ID, pasted under Advanced, which they need anyway for the Google Tasks sync. One client ID per device, so a device cannot use the family file and the Tasks sync together.
- The family project must have ONLY the Google Drive API enabled and ONLY the `drive.appdata` scope (the owner confirmed Google lists it as non-sensitive), authorised JavaScript origin `https://dmhmca.github.io`, and be published to production, with `privacy.html` as the privacy policy and the app address as the homepage. Google may insist on proving ownership of the homepage; github.io pages can usually be proved through a Search Console URL-prefix property. The owner's existing `get-a-grip` project (Tasks scope, Testing mode) stays separate and must not be published.
- `getCid()` = the user's own stored ID (`gag.clientId`) or else `DEFAULT_CID`. With only the built-in ID: Sync shows just "Between my devices" plus a folded "Advanced"; the Import row and the whole Google Tasks list section are hidden, because they need the Tasks scope. Pasting an own client ID in Advanced shows them. The owner's phone and PC already have their own ID stored, so nothing changes for them.
- `sw.js` now leaves other pages (such as `privacy.html`) alone; before, any page navigation overwrote the saved offline copy of the app.

## Sync between devices through Google Drive (built and working on the owner's phone and PC)

Decided with the owner: a hosted database (Firebase etc.) is ruled out because the owner will not host or pay for other people's task lists, and wants the app usable by others. Each person's data therefore lives in their own Google account. Documented in `README.md`; keep that true.

- Activities page, "Sync" (the page was "Google Tasks sync" before; `viewSync`). Section "Between my devices" keeps one file, `get-a-grip-data.json`, in the Drive app-data folder (scope `https://www.googleapis.com/auth/drive.appdata`, Drive API v3 over `fetch`). Section "Google Tasks list" is the sync below. "When to sync" (automatic on/off, interval) applies to both.
- The shared document is `{v:2, activities, tasks, gone, ord}` (`toDoc`). Settings, tokens and `S.sync`/`S.deleted` are never shared. `mergeDocs(local, remote)` merges item by item: later `updated` (or `created`) wins; a deletion in `gone` stands unless the task changed after it; same-named activities (same archived state) become one, keeping the older id so every device settles on the same one (`lastAlias` remaps ids in tasks and in `ui`); two tasks with the same `sid` become one; order follows whichever side has the later `S.ord` stamp, with the other side's extra tasks on top and extra activities at the end; tombstones older than 90 days are dropped.
- `driveCycle`: find file, read, merge, apply locally (`applyMerged`), and write back only if the merged result differs (`stable` JSON compare), re-reading up to three times if the file's `version` changed meanwhile. First join asks for confirmation with counts and saves `tasks.v1.predrive`. There is no deletion confirmation screen for Drive; the safety copy is the protection.
- `syncAll` runs Drive first, then the Google Tasks list, then Drive again if the list changed anything. All triggers (open, return, 4 seconds after a change, timer) call `syncAll`. One sign-in covers whichever scopes are switched on (`needScopes`).
- The Google Tasks sync should run on ONE device only (the owner's phone); the others get its results through Drive. Running it on two at once risks duplicates in Google.
- Tested against a pretend Drive and Tasks server with two simulated devices (36 checks) plus the 46 Tasks checks and 18 checks of the family/own-ID modes, all passing. The owner has since run it for real: phone turned on, PC joined, tasks, activities and archive all arrived. The Drive API is enabled and `drive.appdata` is added in the owner's own project.
- RUNAWAY BUG FIXED (v15): after the app had been closed for a while, the sign-in pass had expired, the quiet renewal failed, and Google's window opening and closing made the page lose and regain focus; the 'return to the app' trigger read that as a new visit and asked again, endlessly, redrawing the screen each time (the owner saw constant flashing on Android). Fixes: a failed quiet attempt is remembered for ten minutes (`silentFailAt`), only one quiet request at a time (`pendingTok`), focus changes within six seconds of a request are ignored (`askingUntil`), 'return' and 'timer' runs happen at most every 30 seconds and not at all while a sign-in waits for a tap, and a circuit breaker pauses automatic syncing for five minutes after more than eight runs in a minute. Reproduce with a Google stub that fails the quiet request and fires `visibilitychange`: Google should be asked once, not repeatedly.
- Real-phone finding: on opening the app, the quiet sign-in renewal did not work and the "Tap to keep syncing" banner appeared; tapping Sign in worked. Whether the banner returns on every cold start is being watched. If it does, store the sign-in pass in `localStorage` for its one-hour life (security trade-off to be agreed first).
- Diagnostic readout (v17): the Sync page shows how many activities and tasks this device has, which sign-in it uses (own project or built-in) and what Drive held at the last look, with the end of the file id (`D.seen`). Added when the owner's laptop and phone seemed not to share new items; a simulated laptop-to-phone run (7 checks) passed, so the suspected causes are device-specific: devices on different Google projects (separate hidden files), pressing the Google Tasks "Sync now" instead of the devices one, or a stale cached copy of the app.
- Not done: a Drive deletion confirmation screen, and sending drag-reordering to Google Tasks.

## Two-way Google Tasks sync (built; needs a real-Google trial)

Activities page, "Sync", section "Google Tasks list" (`viewSync`, engine in the "Google Tasks sync" section of `index.html`). Tested against a pretend Google Tasks server in a scripted browser (46 checks, all passing), NOT yet against real Google. Status after the owner's first real trial should be recorded here.

- Scope is now `https://www.googleapis.com/auth/tasks` for both the import and the sync (the consent screen lists only that scope; the owner has saved it under Data Access). OAuth consent screen is still in Testing.
- The owner chooses one existing Google Tasks list. First sync shows a preview ("add N to Google, bring in M") and waits for "Start syncing". Trial on a spare list called "Get a grip test" first.
- Google notes field = `Activity: <name>`, a blank line, then the task's details. Reading back, that first line is split off again.
- Three-way merge per field (title, notes, done) against `gs`: if only one side changed, it wins; if both changed, the later change wins (`updated` against Google's `updated`).
- Only open tasks are sent up. Ticked tasks already linked keep their ticked state in step. Completed Google tasks that were never linked are not imported. A linked ticked task missing from Google is never deleted from the app.
- Deletions: owner's setting is "ask me first" (default), "carry across" or "never (put the task back)". A safety stop always asks first if one sync would delete more than max(3, a third of linked tasks), or if every linked task vanished from Google. Pending deletions are recomputed each sync and shown with "Delete them" / "Keep them".
- Direction (both / Google into app only / app into Google only), ticks, new tasks and edits can each be switched off. Automatic sync: on open, on return to the app, 4 seconds after a change, and on a timer (2, 5 or 15 minutes, or off) while the app is open. A web page cannot sync while closed.
- Sign-in: Google's token flow gives about an hour and no refresh token. Background attempts use `prompt:'none'`; if Google needs to show something, the status becomes "needs" and a "Tap to keep syncing" banner appears on Master tasks and activity pages. This silent renewal has NOT been proved on a real phone. Consider moving the Google project to "In production" (unverified, personal use) to avoid the seven-day Testing expiry.
- Not done yet: sending drag-reordering to Google (only new tasks go to the top; order from Google is not applied to existing tasks).
- Syncs never redraw over a text box or an open sheet (`softRender`, `patchAround`); keep that rule.

## Smaller open items

- Idea from the owner: a "Utilities" page gathering Google sync, import, backup and restore (and future extras), leaving the Activities page for activities. Not built; do it when there is another utility to add.
- Multi-device: a task arriving from Google Tasks whose notes name an activity that does not exist on that device lands with no activity. Largely solved by the Drive sync (activities travel with it); creating a missing activity on pull was proposed but the owner has not asked for it. A wider layout on large screens was also proposed and not yet answered.
- Licence: MIT (`LICENSE`, copyright line "2026 David McAughtry", the owner's name as they gave it).

- On narrow phone screens the bottom-bar labels truncate ("Master ta…", and long activity names). Shorten or rebalance.
- The top bar and the bottom bar partly duplicate navigation. The owner may want the top buttons dropped.
- A search-results view that shows the matching task under its archived activity is only partly done (matching tasks are shown in the result row).
- Drag handles (tasks and activities) have been tested in a simulated browser only, not extensively by thumb.
- Keyboard (Gboard) behaviour: the owner saw the keyboard sometimes fail to appear or edit. The likely cause was whole-page redraws replacing the focused text box (fixed for Archive search; `render()` now restores focus and cursor, and the viewport meta uses `interactive-widget=resizes-content`). Not reproduced on a real device, so ask the owner whether it recurs. Never rebuild a text box while the user is typing in it.

## Working agreements

- Keep it a single static site. No frameworks or build tooling unless there is a strong reason and the owner agrees.
- Make small, safe commits with plain-English messages. Push to `main` so GitHub Pages republishes.
- After pushing, tell the owner how to see the update: wait for the green tick under the repository's Actions tab, then close and reopen the installed app once or twice.
- Test changes before pushing (for example with a scripted browser) and say honestly what was and was not tested.
- Keep accessibility basics: labels on controls, visible focus, sensible contrast in both themes.
