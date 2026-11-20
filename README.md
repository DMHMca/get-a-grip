# Get a grip

A deliberately simple to-do list. It is not project-management software: there are no due dates, no priorities and no nesting.

It is a Progressive Web App: a few static files, no server and no build step. You can use it in a browser tab or install it on a phone from Chrome ("Install app").

The app: https://dmhmca.github.io/get-a-grip/

For the ideas behind the app and a map of its parts, see [OVERVIEW.md](OVERVIEW.md).

## The idea

Every day, make progress on a **big** task and fit in a few **small** ones. Big tasks are what move you forward; small tasks keep life going. Instead of one endless list that looks impossible, the **Today** page builds a short menu for the day, automatically or by hand: a big piece (one to three subtasks of a big task) and up to six small tasks. There are no due dates, no priorities and no schedules, so nothing is ever overdue. A "Slot" finder answers "I have 15 minutes and my phone: what should I do?".

## Quick start for family and friends

1. Open the link above in Chrome on your phone or computer. On a phone, use the menu, then **Install app**, so it sits on your home screen like any other app.
2. Add a few tasks on the **Small** or **Big** pages, then open **Today** and tap **Automatic**.
3. Want the same tasks on a second device? Open the three-dot menu, choose **Sync**, and tap **Turn on**. Sign in with your Google account and approve the single permission it asks for. Your tasks are kept in a hidden file in your own Google Drive, and nobody else, including the person who made the app, can see them.

You do not need a Google Cloud account or anything technical. The "Advanced" part of the Sync page is only for people who want to run their own Google project.

## What it does

- **Today**: a plan for the day, built automatically or by hand, with Refresh, Redo, Finish and Slot buttons.
- **Big** and **Small** lists, in your own hand-sorted order; **Master** is a reference list of everything you could do next. **Activities** are broad areas ("Finance", "House") that never finish.
- **Subtasks** hang under any task. A small task finishes itself when its last subtask is ticked.
- **Wait** puts a task off for a day, a week, a month, a chosen date, or until another big task is finished. It is a snooze, never a deadline.
- Optional **time and equipment** tags (15 minutes, phone and so on) feed the Slot finder.
- Optional **details** (web addresses and phone numbers become tappable), **Add several** from a pasted list, an archive for finished activities, backups, light and dark mode, and an "Update now" banner when a new version is ready.

## Where your data lives

Everything is stored in your own browser (`localStorage`, key `tasks.v1`). By default nothing leaves your device. There are no accounts, no analytics and no server belonging to this project.

If you want your tasks to follow you between devices, the app has an optional sync, described below. It uses your own Google account. This project never receives or stores anyone's tasks. The full details are on the [privacy page](https://dmhmca.github.io/get-a-grip/privacy.html).

## Syncing (optional)

Open the three-dot menu, then **Sync**.

### Between my devices

Keeps the same activities, tasks, archive and order on every device you use, for example a phone and a computer. It saves one small file in the hidden "app data" area of **your own Google Drive**. Only this app can open that file, and it does not appear among your normal Drive files.

- Each device merges with the file when the app opens, shortly after you make a change, and on a timer while the app is open. A web page cannot sync while it is closed, so changes made on one device reach another when that device next opens the app.
- Merging works item by item. If two devices change the same task, the later change wins. Deleting a task on one device deletes it on the others, unless it was changed after the deletion. If two devices each create an activity with the same name, they become one.
- Order follows whichever device reordered last; if two devices are equally recent they settle on the same order. Tasks added elsewhere appear at the top. A button on the Sync page, "Use this device's order everywhere", lets you choose which device's order the others follow.
- Before a device first joins, the app saves a safety copy of its data in the browser.
- If a device's Google sign-in ever changes while syncing is on (for example a different client ID is entered), the app switches syncing off and says why, instead of quietly switching to a different file. Turning it on again shows what each side holds before joining.
- What is shared: activities, tasks and a note of deletions. What stays on each device: settings and sign-in state.

### Why there is no hosted database

A shared database (Firebase, Supabase and similar) would mean that whoever runs this project holds everyone's task lists, pays for them, and carries the responsibility for that personal data. For a small open project that is the wrong trade. Using each person's own Google Drive means the data stays with its owner and the project has nothing to host, which is why this is built the way it is. If you prefer a different backend, the sync code is a self-contained section of `index.html` and is easy to replace.

## Using your own copy

The sync features need a Google "client ID", which identifies an app to Google. The live copy has one built in that carries only the Drive permission, so Drive sync needs nothing from you. If you run your own copy, you need your own client ID. It costs nothing, and a client ID is not a secret.

To make Drive sync work for everyone who uses your copy without them setting anything up, put your client ID in the `DEFAULT_CID` line near the top of the script in `index.html`. For that shared project, enable only the Google Drive API, add only the `drive.appdata` scope, and publish the consent screen to production. That permission is classed as non-sensitive, so Google does not require a formal review for it.

1. Fork this repository. In **Settings, then Pages**, set the source to "Deploy from a branch", `main`, `/ (root)`. After a minute your copy is at `https://YOURNAME.github.io/REPOSITORYNAME/`.
2. In the Google Cloud console (https://console.cloud.google.com), create a project.
3. Under **APIs & Services, then Library**, enable the **Google Drive API** (for syncing between devices).
4. Under **Google Auth Platform**, set up the consent screen as **External**. In **Data Access**, add the scopes you need:
   - `https://www.googleapis.com/auth/drive.appdata` for syncing between devices.
5. Under **Audience**, add your own Google account as a **test user**. While the app is in Testing mode only the people listed there can sign in, and Google may ask you to approve again every seven days. Google also shows an "unverified app" warning, which is expected for your own project.
6. Under **Clients**, create an **OAuth client ID** of type **Web application**. Under "Authorised JavaScript origins" add the address of your copy, for example `https://YOURNAME.github.io`. No redirect address is needed.
7. Copy the client ID (it ends in `.apps.googleusercontent.com`). In the app, open **the three-dot menu, then Sync, then Advanced**, and paste it in. It is stored only in that browser.

The app works fully without any of this. Everything above is only for syncing.

## Limitations

- Syncing runs only while the app is open or comes back into view. Nothing can sync in the background.
- Google's sign-in gives the app a pass that lasts about an hour, with no way to renew it silently. When the pass has run out, a strip appears on the main pages saying "Tap to keep syncing"; tap anywhere on it, approve the Google window, and syncing carries on. Your tasks are never lost while you wait.
- Alarms and reminders are out of scope: a web app cannot do them reliably.

## Data format

One JSON object: `{ v, updatedAt, activities, tasks }`, plus optional sync fields. The array order of `tasks` and `activities` is the display order. "Download a backup" and "Restore from backup" use this format directly, and older backups still load. `CLAUDE.md` describes every field.

## Files

- `index.html`: the whole app (HTML, CSS and vanilla JavaScript, no libraries).
- `sw.js`: the service worker. Pages are fetched from the network first so updates arrive; other files are cached. Bump the `CACHE` version on every release.
- `manifest.webmanifest`, `icon-*.png`, `apple-touch-icon.png`: install details and icons.
- `privacy.html`: the privacy page, linked from the Sync page. Google asks for one when a project is published.
- `CLAUDE.md`: a working brief for the AI assistant that helps maintain this project, and a useful technical overview for anyone else.

## Updating

Push to `main` and GitHub Pages republishes. On a device, open the app while online and it picks up the new version. If it does not appear straight away, close it fully and open it again once or twice.

## Licence

MIT. See the [LICENSE](LICENSE) file. You are welcome to use, copy and change this app, including for your own family and friends, as long as the copyright notice stays with it.
