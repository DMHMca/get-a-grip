# Get a grip: an overview

This is the plain-English map of the app: the idea at its heart, how the parts fit around it, and what exists today. It is meant to be read by its owner when the number of moving parts gets hard to hold in one head, and as the start of the documentation for anyone else who picks the app up. It changes as the app does. See "Keeping this up to date" at the end.

For the technical detail (files, data format, sync internals) see `CLAUDE.md`. For setting up your own copy see `README.md`.

## The idea at the heart of it

**Every day, make progress on one big task, and fit in as many small tasks as you can.**

Big tasks are the things that actually move you forward. They are the pieces of work you can look back on at the end of the year and say, "I really achieved that": the tax return, the website overhaul, the trip notes. Small tasks are what keeps life going, and you need a mixture of both. A day of only small tasks leaves nothing to show for the year. A day of only big work lets everything else slide.

So the heart of the app is a daily mix. When you get up, the app builds a menu for the day: one bite of a big task, with as many small tasks around it as you can reasonably fit. It can build that menu for you (Automatic) or you can build it yourself (Custom), and you can rejig it all day.

The second idea is the **Slot**. Whenever you find yourself with fifteen minutes to spare and only a phone in your hand, the app finds the most useful and effective thing you could do with that time and that equipment.

Everything else in the app is built around those two ideas.

## Why there are no dates, times or deadlines

Nobody ever manages to get every task they assign themselves done on the date it was supposed to be done. What you end up with is a mass of missed dates, and a list that makes you feel you have failed before the day has started.

So the app removes dates, schedules, project deadlines and project-management methods altogether. Instead, each day you build a menu of tasks that fit the time you actually have. Nothing is overdue. Nothing is late. What you did not get to simply stays where it was. A real deadline, such as the UK tax return, can be written into the task's text or details, but the app never nags you about it.

Where a task sits in your own list is the only statement of importance, so there are no priority labels either.

## The other principles

**No pile of failure.** The record of past days shows what you did, in neutral words, with no scores, streaks or red.

**Small bites make big things startable.** A big task becomes a series of subtasks, so today you do one bite, not the whole elephant.

**Your data is yours.** Everything is stored on your device. Syncing, if you want it, uses your own Google account and a hidden file only this app can read. Nobody running the app can see your tasks. It is a web app that installs on a phone like any other app, with no server and no account with us.

**Colour-blind safe.** No red and no green anywhere. Blue and amber carry meaning, and nothing relies on colour alone.

## The building blocks

**Big tasks** are bounded pieces of work that you can finish but that take days or weeks. A big task is marked with a large blue house, and you put your big tasks in your own order by dragging. The data stores the word "big", never the icon.

**Small tasks** are the default: usually an hour or less, marked with a small amber house. You put them in your own order too.

**Subtasks** are ordinary tasks that sit under another task, one level deep. They are listed in their main task's edit screen, and tapping one opens it in the same screen, with a link back to the main task. Big tasks nearly always have them, because a big task is made startable by its subtasks. You add a subtask exactly as you add any task, you can attach an existing task from a dropdown, and you can drag subtasks into the order you want to do them. New subtasks go at the bottom.

**Thinking** is a roomy writing box on every big task, for working out what its parts might be. Write loosely, then use "Turn lines into subtasks" to turn the lines you choose into real subtasks. Those lines are taken out of the details so nothing is held twice, and any line you leave unticked, such as a phone number or web address, stays where it was. That option works on any task, big or small: write a list in a task's details, then turn it into subtasks in one tap.

**Wait** puts a task off for a day, a week or a month, for any number of days (up to six), weeks (up to three) or months, or until a date you pick, such as early November. It stays in every list, marked "Waiting until" a date, but it is left out of the day and the Slot finder until the time is up, then it comes back by itself. It is for things like a part that is out of stock. When the task is a subtask, you can also hold the subtasks after it, so a stuck step does not keep offering the next ones. It is a snooze, not a deadline, so nothing is ever overdue.

**Tags** are two optional labels on any task: roughly how long it takes (15 minutes, 30 minutes, 1 hour or all day) and the least equipment it needs (none needed, phone, tablet or laptop). They exist for the Slot finder. They are never shown on ordinary rows.

**Activities** are broad areas of work or life that never finish: Finance, AI SEO, Health, Travel. You do not tick off an activity, you archive it when it goes dormant. Activities are a flat list, with no activities inside activities. A task can belong to one activity or to none.

**Details** are optional free text on any task (a web address, a phone number, anything useful). Web addresses become links and phone numbers become tap-to-call.

## The pages

**Today.** Where the idea lives. Each day starts blank, with two buttons: Automatic and Custom.

When you start the day you choose how many big tasks (one to three) and how many subtasks of each, because sometimes you want to nudge several big tasks forward a little each rather than wait for the first to finish. With two or more big tasks it starts at one subtask each. Automatic builds the standard day for you. It takes the first big tasks in your own order (as many as you chose), each with its next subtasks, each big task in its own block. It then takes the first six small tiles from the top of your Small list. A small task with subtasks is represented by its subtasks, each tile headed by the parent's name.

Custom asks a few questions (what sort of day it is, which big piece, which small ones) and builds the day from your answers.

The plan is shown as a block for the big piece, with the big task as its heading and today's subtasks inside, and a grid of small tiles for the small ones. Tap anything to open the original task and change it. Any item can be swapped, taken out or added to at any time, so the day is something you keep rejigging, not a contract. "Finish" adds an optional note, "Redo" clears the plan so you can start again, "Slot" finds something for a spare gap, and "Past days" keeps a quiet record of what was done. Planning is for today only.

**Big.** Your big tasks as cards, in your own order. Each card opens to show its Thinking box and its subtasks, with a progress bar once there is more than one subtask. The first big task in this list is the one Automatic chooses.

**Small.** Your small tasks, in the order you choose by dragging. Most are single items. A bigger small task can have subtasks: it is one row that opens to show them, and you tick the parent off yourself.

**Master.** A reference list of everything you could do next: the small tasks that have no subtasks, plus the next unfinished subtask of every parent task, each with a "Part of:" tag naming its parent. A parent task is never listed itself. The day is built from Big and Small, not from here, so Master is only a place to look.

**Activities.** Your broad areas, in the order you choose. Open an activity to see all its tasks, big and small, with subtasks tucked under their parents.

**The three-dot menu** (top right of every page) is the one home for housekeeping, one line per item: Tag tasks (with a count of what is waiting), Archive, Sync, Download a backup, Restore from backup, Appearance (follow the phone, always light, always dark), Today layout (blocks or list), Copy my live tasks (preview only), Privacy and About this app. The preview's version number is a plain line at the bottom. There is no separate Settings page.

**Archive** holds activities you have put away, searchable by name, date and the text of the tasks inside them. Restore brings one back.

**Sync** is optional. It keeps the same data on several devices through a hidden file in your own Google Drive. In the live app, an advanced option also keeps one Google Tasks list in step with Master tasks, for people who use Google Tasks elsewhere.

## The Slot finder in detail

On Today, the "Slot" button asks how long you have and what you have with you, then lists the first three tasks that fit, with a button to show the rest. A task fits if it takes no longer than your slot and needs no more than what you have, so a phone task fits anywhere and a laptop task only fits a laptop. It looks through your Small list in your own order. A box, "Include big tasks", is unticked by default and adds the unfinished subtasks of big tasks after the small ones, because a scrap of time suits small work and big work needs more context.

Tasks missing either tag are listed separately as "Not tagged yet", with two small dropdowns so you can tag them on the spot. "Tag tasks" in the three-dot menu steps through every untagged task in one go. One tap adds a task to your day. The Slot finder is a filter, not a schedule: nothing is ever assigned a time.

## What exists today

| Capability | Live app | Preview (`/next/`) |
|---|---|---|
| Activities, tasks, drag to reorder, details, archive | Yes | Yes |
| Add several, keep tasks out of Master | Yes | Yes |
| Sync between devices through Google Drive | Yes | Yes (its own separate file) |
| Two-way Google Tasks list sync | Yes | No |
| Backup and restore | Yes | Yes |
| Big and small tasks, subtasks, attach existing task | No | Yes |
| Big page, Thinking box, lines into subtasks | No | Yes |
| Master tasks fed one subtask at a time | No | Yes |
| Today page: Automatic, Custom, blocks and list | No | Yes |
| Finish the day, notes, Past days | No | Yes |
| Slot finder, time and equipment tags, Tag tasks | No | Yes |
| Three-dot menu for all housekeeping, appearance choice | No | Yes |

The preview lives at `/get-a-grip/next/` with its own data, so it can be tried without risking the live app. When it is ready the live app is replaced by it, but only when the owner says so.

## Is it new?

Honestly, no single feature is. Nested tasks, big and small tasks, day planning, filtering by time or device, and notes on a project all exist in other apps, usually spread across menus, settings, plug-ins or paid tiers, and generally built around due dates, priorities or calendar time-blocking. (This comes from general knowledge, not a survey, so treat the comparison as a fair impression and not a checked claim.)

What is unusual is the idea at the heart of it and the stance that follows. The app is built around a daily mix of one bite of a big task and as many small tasks as fit, made automatically or by hand each morning. It has a Slot finder for the spare quarter of an hour. And it deliberately has no dates, no priorities and no timetable, so there is never a mass of missed dates. It records what you did without ever counting what you did not, and it is a free static web app whose data stays in your own Google account. I do not know of another app that puts those together, but that is a statement of my knowledge, not proof that none exists.

## For someone picking this up

You can use the live app at `https://dmhmca.github.io/get-a-grip/` straight away: install it from Chrome and start adding tasks. It works offline and needs no account. If you want your tasks on a second device, turn on Sync from the Activities page and sign in with Google.

To run your own copy, fork the repository on GitHub, switch on GitHub Pages for it, and follow `README.md` if you want Google sync under your own Google project. The whole app is a few static files (`index.html`, `sw.js`, a manifest and icons) with no build step.

## Keeping this up to date

Update this file whenever a feature is added, changed or dropped, and whenever the preview becomes the live app. Keep the "What exists today" table honest, mark anything unbuilt as proposed, and keep it in step with `README.md` and `CLAUDE.md`.
