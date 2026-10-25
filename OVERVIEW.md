# Get a grip: an overview

This is the plain-English map of the app: what it is for, the ideas behind it, how the parts fit together, and what exists today. It is meant to be read by its owner when the number of moving parts gets hard to hold in one head, and as the start of the documentation for anyone else who picks the app up. It changes as the app does. See "Keeping this up to date" at the end.

For the technical detail (files, data format, sync internals) see `CLAUDE.md`. For setting up your own copy see `README.md`.

## What it is

Get a grip is a to-do list for people who plan their own time and find diaries, deadlines and project-management tools more of a burden than a help. It has no due dates and no priorities, ever. Instead it helps you decide, as the day goes, what is worth doing now, and it never shows you a growing pile of things you failed to do.

It is a web app that installs on a phone like any other app. There is no server and no account with us. Your tasks live on your own device, and if you want them on more than one device they travel through your own Google Drive.

## The ideas behind it

**Freeform, not scheduled.** Nothing in the app belongs to a time of day. You never say "do this at 11:45". A day plan is a menu of what you might do today, not a timetable. Nothing is overdue or late.

**One list order is your priority.** Where a task sits in your list is the only statement of importance. There are no priority labels.

**No pile of failure.** What you did not get to simply stays where it was. The record of past days shows what you did, in neutral words, with no scores, streaks or red.

**Small bites make big things startable.** A big piece of work becomes a series of small subtasks, so that today you do one bite, not the whole elephant.

**Your data is yours.** Everything is stored on your device. Syncing, if you want it, uses your own Google account and a hidden file only this app can read. Nobody running the app can see your tasks.

**Colour-blind safe.** No red and no green anywhere. Blue and amber carry meaning, and nothing relies on colour alone.

## The building blocks

**Activities** are broad areas of work or life that never finish: Finance, AI SEO, Health, Travel. You do not tick off an activity. You archive it when it goes dormant. Activities are a flat list, with no activities inside activities.

**Tasks** are the things you do. Every task can belong to one activity or to none. A task can be ticked, edited, moved and reordered by dragging. New tasks go at the top. A task can carry optional details (a web address, a phone number, anything useful), which are shown only when you ask.

**Small tasks** are the default: usually an hour or less.

**Big tasks** are bounded pieces of work that you can finish but that take days or weeks: the UK tax return, remediating two websites, the Uzbekistan trip notes. A big task is marked with a large blue house, and a small task with a small amber house. The data stores the words "big" or "small", never the icon.

**Subtasks** are ordinary tasks that sit under another task, one level deep. Any task can have them, but big tasks nearly always do. You add a subtask exactly as you add any task, you can attach an existing task to a big task from a dropdown, and you can drag subtasks into the order you want to do them. Newly added subtasks go at the bottom.

**Thinking** is a roomy writing box on every big task, for working out what its parts might be. You can write loosely, and later tap "Turn lines into subtasks" to turn the lines you choose into real subtasks.

## The pages

**Today.** The heart of the app. Each day starts blank, with two buttons: Automatic and Custom. Automatic builds a standard day for you: the next subtask of the big task you touched most recently, plus up to five small tasks from the top of your list. Custom asks a few questions (what sort of day is it, which big piece, which small ones) and builds the day from your answers. The plan is shown as a block for the big piece, with the big task as its heading and today's subtasks inside, and a grid of small tiles for the small ones. Tap anything to open the original task and change it. Any item can be swapped, taken out or added to at any time, so the day is something you keep rejigging, not a contract. "Finish the day" adds an optional note, and "Past days" keeps a quiet record of what was done. You can also plan tomorrow, never further ahead.

**Master tasks.** Everything you could do next, in one list. A task that has subtasks never appears as itself here: only its next unfinished subtask does, labelled with its parent, so a big task feeds the list one step at a time instead of flooding it. A big task with no subtasks yet is just itself. Tasks can be kept out of Master tasks when you do not want them in the way.

**Big.** Where you structure your big tasks. Each is a card showing its activity, progress ("3 of 7 subtasks done"), its next subtask and the first lines of your thinking. Open a card to write in the Thinking box, add or attach subtasks, reorder them, or turn lines of your thinking into subtasks.

**Activities.** Your list of broad areas, in the order you choose. Open an activity to see all its tasks, big and small, with subtasks tucked under their parents.

**Archive** (from the three-dot menu). Activities you have put away, searchable by name, date and the text of the tasks inside them. Restore brings one back.

**Settings** (from the three-dot menu). Appearance (follow the phone, always light, always dark), the Today layout (blocks or list), Sync, backup and restore, privacy and version.

**Sync.** Optional. Keeps the same data on several devices through a hidden file in your own Google Drive. An advanced option keeps one Google Tasks list in step with Master tasks, for people who also use Google Tasks elsewhere.

## Picking something for a spare slot (proposed, not built)

Sometimes the day plan is not the question. You simply have half an hour and a phone and want something useful to do. The idea: each task can optionally carry two tags, roughly how long it takes and the least equipment it needs (phone, tablet or laptop). A button on Today, "I've got a slot", asks how long you have and what you have with you, and shows only the tasks that fit, with a one-tap way to add one to your day. Untagged tasks would be listed separately and could be tagged on the spot. This is a filter, not a schedule, and it needs the owner's go-ahead because it relaxes the earlier rule of "no time estimates".

## What exists today

| Capability | Live app | Preview (`/next/`) |
|---|---|---|
| Activities, tasks, drag to reorder, details, archive | Yes | Yes |
| Add several, keep tasks out of Master | Yes | Yes |
| Sync between devices through Google Drive | Yes | Yes (its own separate file) |
| Two-way Google Tasks list sync | Yes | No |
| Backup and restore | Yes | Yes |
| Three-dot menu, Settings page, appearance choice | No | Yes |
| Big and small tasks, subtasks, attach existing task | No | Yes |
| Big page, Thinking box, lines into subtasks | No | Yes |
| Master tasks fed one subtask at a time | No | Yes |
| Today page: Automatic, Custom, blocks and list, Tomorrow | No | Yes |
| Finish the day, notes, Past days | No | Yes |
| "I've got a slot" | No | Not yet |

The preview lives at `/get-a-grip/next/` with its own data, so it can be tried without risking the live app. When it is ready the live app is replaced by it.

## Is it new?

Honestly, no single feature is. Nested tasks, big and small tasks, day planning, filtering by time or device, and notes on a project all exist in other apps, usually spread across menus, settings, plug-ins or paid tiers, and generally built around due dates, priorities or calendar time-blocking. (This comes from general knowledge, not a survey, so treat the comparison as a fair impression and not a checked claim.)

What is unusual here is the combination and the stance. The app deliberately has no dates, no priorities and no timetable. It treats the day as a small menu that you rebuild whenever you like. It feeds big work in one bite at a time so lists stay short. It records what you did without ever counting what you did not. It gives you a place to think a big task through before it becomes subtasks. And it does all this as a free static web app whose data stays in your own Google account. I do not know of another app that puts those together, but that is a statement of my knowledge, not proof that none exists.

## For someone picking this up

You can use the live app at `https://dmhmca.github.io/get-a-grip/` straight away: install it from Chrome and start adding tasks. It works offline and needs no account. If you want your tasks on a second device, turn on Sync in Settings and sign in with Google.

To run your own copy, fork the repository on GitHub, switch on GitHub Pages for it, and follow `README.md` if you want Google sync under your own Google project. The whole app is a few static files (`index.html`, `sw.js`, a manifest and icons) with no build step.

## Keeping this up to date

Update this file whenever a feature is added, changed or dropped, and whenever the preview becomes the live app. Keep the "What exists today" table honest, mark anything unbuilt as proposed, and keep it in step with `README.md` and `CLAUDE.md`.
