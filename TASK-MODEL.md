# The shared task model (Get a grip and Get a Grip Household)

This file is kept WORD FOR WORD the same in both repositories, `DMHMca/get-a-grip` and `DMHMca/get-a-grip-household`. Change it in both or not at all. The two apps may look and behave differently on screen (the phone app uses drop-downs, the household planning board uses drag and drop on a laptop); what must not differ is what a task is and the rules below, because household tasks will be passed into each person's Get a grip.

## What a task is

A task is a JSON object with these fields (all but `id` and `text` optional):

- `id`: a unique text id, never reused.
- `text`: the task as a person would say it.
- `size`: `'big'` for a big task; absent means small. Store the word, never an icon.
- `parent`: the id of the task this is a subtask of. Absent for a task on its own.
- `notes`: free-text details (web addresses and phone numbers stay as plain text; the apps make them tappable).
- `done`: ISO time it was ticked, or absent/null.
- `wait`: a plain date `YYYY-MM-DD`; until then the task is left out of the day. A snooze, never a deadline.
- `wf`: the id of a big task this one waits for; it comes back by itself when that task is finished.
- `wh`: true on a waiting subtask that also holds the subtasks after it.
- `dur`: time it takes: `'quick'` (15 minutes), `'30'`, `'60'`, `'day'`.
- `dev`: least equipment needed: `'none'`, `'phone'`, `'tablet'`, `'laptop'`.
- `activityId` (Get a grip) or `area` (Household): which part of life it belongs to.
- `created`, `updated`: ISO times; `updated` is stamped on every change and settles clashes between devices (the later one wins).
- Household only, kept when passed across: `to` (who owns it: 0, 1 or 2 for both), `by` (who added it), `tag` (room or month it came from).

Deleted tasks are remembered as `{id, at}` in a `gone` list for 90 days so a deletion travels to other devices.

## The rules

1. There are no due dates and no priorities. Order is expressed only by the order of the list.
2. Big or small is a person's choice about the task, not worked out by the app.
3. One level only: a subtask cannot have subtasks of its own, and a task that has subtasks cannot itself become a subtask.
4. Putting a task under another: it becomes the LAST subtask, in the order added, and takes on the parent's activity or area.
5. Taking a subtask out: it becomes a task on its own again, keeping its text, details and ticks.
6. Moving a task that has subtasks into a big task: its subtasks move across (in order, ticks kept), the emptied task is removed, and its details are added to the big task's details. No name is put in front of the moved subtasks.
7. A small task finishes itself when its last subtask is ticked (and reopens if one is unticked). A big task is only ever finished by a person.
8. Neutral wording everywhere: no streaks, scores, "overdue" or blame; no red or green.

## Where each app stands (update when either changes)

- Get a grip (phone): rules 1 to 8 built. Edit screen: "Part of a big task" (rule 4/5), "Move its subtasks into a big task" (rule 6), version 35.
- Household (laptop board): dropping a note onto another makes it a step (rule 4). NOT YET: dropping a note that has steps onto another is refused; it should follow rule 6. Waits, time and equipment are not yet set on the board.
