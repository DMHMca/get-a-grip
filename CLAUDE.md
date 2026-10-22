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
- `sw.js`: service worker. Pages are fetched network-first so updates arrive; other files are cached. **Bump the `CACHE` version string (currently `get-a-grip-v10`) on every release.**
- `manifest.webmanifest`: install details (name, colours, icons).
- `icon-192.png`, `icon-512.png`, `icon-maskable-512.png`, `apple-touch-icon.png`: the icon (six white dots, 2 by 3, on navy).
- `README.txt`: upload notes from the first build.

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
11. Alarms and reminders are out of scope (a web app cannot do them reliably).

## Design

- Font: Atkinson Hyperlegible (Google Fonts, with system fallbacks).
- Colours: accent `#234E70`, background `#F3F4F2`, text `#1B1F1D`. Dark mode is supported through CSS variables (`prefers-color-scheme`), keep both themes working.
- Large touch targets (44px or more), safe-area insets respected, `prefers-reduced-motion` respected.
- Use proper typographic punctuation in visible text (’ “ ”).

## Data

- Everything is stored on the phone in `localStorage` under the key `tasks.v1`, as one JSON object: `{ v, updatedAt, activities: [...], tasks: [...] }`.
- Activity: `{ id, name, created, archived }` (`archived` is an ISO date string or `null`).
- Task: `{ id, text, activityId, created, done, gid?, notes?, sid?, gs?, updated? }` (`done` is an ISO date or `null`; `gid` is set on tasks imported from Google Tasks, as `listId:taskId`; `notes` is the optional details text and is absent when empty; `sid` is the two-way sync link `listId:taskId`; `gs` is what Google held at the last sync, `{title,notes,done}`, used to tell which side changed; `updated` is an ISO time stamped on ticking, restoring and editing, used only to settle a clash).
- Sync settings live in `S.sync`; `S.deleted` holds notes of linked tasks deleted in the app so the deletion can be passed on. Both are optional, so old backups still load. A safety copy is saved in `localStorage` under `tasks.v1.presync` before the first sync.
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

## Two-way Google Tasks sync (built; needs a real-Google trial)

Activities page, "Google Tasks sync" (`viewSync`, engine in the "Google Tasks sync" section of `index.html`). Tested against a pretend Google Tasks server in a scripted browser (46 checks, all passing), NOT yet against real Google. Status after the owner's first real trial should be recorded here.

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
- Multi-device: a task arriving from Google whose notes name an activity that does not exist on this device lands with no activity. Proposed (awaiting the owner's yes): create the missing activity at the end of the list. Also proposed: a wider layout on large screens.

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
