# Get a grip

A deliberately simple to-do list. It is not project-management software: there are no due dates, no priorities and no nesting.

It is a Progressive Web App: a few static files, no server and no build step. You can use it in a browser tab or install it on a phone from Chrome ("Install app").

Live copy: https://dmhmca.github.io/get-a-grip/

## Quick start for family and friends

1. Open the link above in Chrome on your phone or computer. On a phone, use the menu, then **Install app**, so it sits on your home screen like any other app.
2. Start adding tasks. That is all you need. It works on that device straight away and keeps working offline.
3. Want the same tasks on a second device, such as your phone and your computer? On each device go to **Activities, then Sync**, and tap **Turn on**. Sign in with your Google account and approve the single permission it asks for. Your tasks are then kept in a hidden file in your own Google Drive, and nobody else, including the person who made the app, can see them.

You do not need a Google Cloud account, a client ID or anything technical for this. The "Advanced" section on the Sync page is only for people who want to run their own Google project.

## What it does

- **Activities** group related tasks. Each activity is a flat, ordered list.
- **Master tasks** shows every open task in one list, whichever activity it belongs to. Tasks can also have no activity.
- New tasks go at the top. Drag the grip handle to reorder (or use the up and down arrow keys on the handle). Activities can be reordered the same way.
- Ticking a task removes it from Master tasks but leaves it struck through in its activity, so progress stays visible. A "Just ticked" strip offers a one-tap restore.
- **Add several** at once: the "Add several" button under the add box takes a pasted list, one task per line, and adds them at the top in the order given. It only adds; nothing already there is changed, and lines already in that activity are skipped.
- A task can carry optional **details**, for example a web address or a phone number. They stay folded away until you open them, and web addresses and phone numbers become tappable.
- Activities can be **archived**. The archive is searchable and sortable, and the search covers the tasks inside.
- Backups: download everything as one JSON file, or restore from one.
- Works offline, in light and dark mode, with large touch targets and British English throughout.

## Where your data lives

Everything is stored in your own browser (`localStorage`, key `tasks.v1`). By default nothing leaves your device. There are no accounts, no analytics and no server belonging to this project.

If you want your tasks to follow you between devices, the app has two optional kinds of sync, described below. Both use your own Google account. This project never receives or stores anyone's tasks. The full details are on the [privacy page](https://dmhmca.github.io/get-a-grip/privacy.html).

## Syncing (optional)

Open **Activities, then Sync**.

### Between my devices

Keeps the same activities, tasks, archive and order on every device you use, for example a phone and a computer. It saves one small file in the hidden "app data" area of **your own Google Drive**. Only this app can open that file, and it does not appear among your normal Drive files.

- Each device merges with the file when the app opens, shortly after you make a change, and on a timer while the app is open. A web page cannot sync while it is closed, so changes made on one device reach another when that device next opens the app.
- Merging works item by item. If two devices change the same task, the later change wins. Deleting a task on one device deletes it on the others, unless it was changed after the deletion. If two devices each create an activity with the same name, they become one.
- Order follows whichever device reordered last. Tasks added elsewhere appear at the top.
- Before a device first joins, the app saves a safety copy of its data in the browser.
- What is shared: activities, tasks and a note of deletions. What stays on each device: settings, sign-in state and the Google Tasks setup below.

### Google Tasks list (advanced)

This needs your own Google project (see "Using your own copy"), because Google treats permission to change Google Tasks as sensitive and asks apps to pass a formal review before the general public can use it. It lives under **Advanced** on the Sync page. Keeps Master tasks in step with one list in Google Tasks, so that ticking a task in Gmail's side panel or the Google Tasks app ticks it here, and the reverse.

- You choose which list. The activity name is written at the top of each Google task's notes ("Activity: Health"), followed by the task's details.
- Ticks, new tasks and edits pass both ways. Each can be switched off, and the direction can be limited to one way.
- Deleting is cautious by default: the app asks first, and a safety stop always asks if one sync would delete more than about a third of your tasks, or everything.
- Turn this on for **one device only** (usually the phone). If you also use the Drive sync, the other devices receive the results through Drive. Running it on two devices at once could create duplicate tasks in Google.
- The first sync shows a preview and waits for you to confirm.

### Why there is no hosted database

A shared database (Firebase, Supabase and similar) would mean that whoever runs this project holds everyone's task lists, pays for them, and carries the responsibility for that personal data. For a small open project that is the wrong trade. Using each person's own Google Drive means the data stays with its owner and the project has nothing to host, which is why this is built the way it is. If you prefer a different backend, the sync code is a self-contained section of `index.html` and is easy to replace.

## Using your own copy

The sync features need a Google "client ID", which identifies an app to Google. The live copy has one built in that carries only the Drive permission, so Drive sync needs nothing from you. If you run your own copy, or you want the Google Tasks list features, you need your own client ID. It costs nothing, and a client ID is not a secret.

To make Drive sync work for everyone who uses your copy without them setting anything up, put your client ID in the `DEFAULT_CID` line near the top of the script in `index.html`. For that shared project, enable only the Google Drive API, add only the `drive.appdata` scope, and publish the consent screen to production. That permission is classed as non-sensitive, so Google does not require a formal review for it. Keep the Google Tasks permission in a separate project, because it is sensitive and would trigger the review and the unverified-app warning.

1. Fork this repository. In **Settings, then Pages**, set the source to "Deploy from a branch", `main`, `/ (root)`. After a minute your copy is at `https://YOURNAME.github.io/REPOSITORYNAME/`.
2. In the Google Cloud console (https://console.cloud.google.com), create a project.
3. Under **APIs & Services, then Library**, enable the **Google Drive API** (for syncing between devices) and the **Google Tasks API** (for the Google Tasks list). Enable only what you need.
4. Under **Google Auth Platform**, set up the consent screen as **External**. In **Data Access**, add the scopes you need:
   - `https://www.googleapis.com/auth/drive.appdata` for syncing between devices;
   - `https://www.googleapis.com/auth/tasks` for the Google Tasks list.
5. Under **Audience**, add your own Google account as a **test user**. While the app is in Testing mode only the people listed there can sign in, and Google may ask you to approve again every seven days. Google also shows an "unverified app" warning, which is expected for your own project.
6. Under **Clients**, create an **OAuth client ID** of type **Web application**. Under "Authorised JavaScript origins" add the address of your copy, for example `https://YOURNAME.github.io`. No redirect address is needed.
7. Copy the client ID (it ends in `.apps.googleusercontent.com`). In the app, open **Activities, then Sync, then Advanced**, and paste it in. It is stored only in that browser.

The app works fully without any of this. Everything above is only for syncing.

## Limitations

- Syncing runs only while the app is open or comes back into view. Nothing can sync in the background.
- Google's sign-in gives the app a pass that lasts about an hour with no way to renew it silently. The app asks for a new one quietly, and shows a "Tap to keep syncing" banner on the occasions Google needs a tap.
- Dragging a task to a new position is shared between devices through Drive, but is not sent to Google Tasks. Only new tasks go to the top there.
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
