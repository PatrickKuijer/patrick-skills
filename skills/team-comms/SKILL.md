---
name: team-comms
description: "Write things for other people: meeting prep, meeting recap, mail drafts, team notes, a questionnaire for a colleague or their agent, management updates and decks. Applies the language rule (chat English, team artefacts per repo, default Dutch with English industry terms), the audience's vocabulary and a no-noise rule. Use for 'prep my meeting', 'had the meeting', 'draft a mail to X', 'maak het netjes', 'questions for X', 'status update for management'."
argument-hint: "prep | recap | mail | note | questionnaire | update  <topic>"
---

## Rules for every mode

- **Language**: talk to the user in English. Artefacts for others follow
  **Language** in `docs/agents/workflow.md`; if absent, ask once (default
  Dutch, English industry terms kept).
- **Audience**: name the audience first (management, IT, a colleague, a
  customer) and write in *their* vocabulary, using the `glossary` skill for
  machine terms. Never invent a product or brand name.
- **No noise**: every sentence must help the reader decide, act or
  understand; if deleting it would not stop them, delete it. No vanity numbers
  without meaning, no vision filler, no timeline commitments unless asked.
- **Facts**: numbers, dates and statuses come from the tracker, repo or a
  cited source, checked now. Flag anything stale.
- **User feedback with several points**: turn it into a numbered checklist and
  tick every item in the revision.
- **Never send.** Drafts only. Save to the repo's meetings/notes folder as
  `<YYYY-MM-DD>-<slug>.md`; when the user is remote, also send the file.

## Modes

- **prep** — from the tracker, ADRs, overview and open questions: agenda,
  what to decide, what to ask whom, risks; short enough to read aloud. Plus the
  work to finish before the meeting, split agent-ready / needs-you.
- **recap** — raw notes in, then: decisions (each goes through `decide record`),
  actions as tickets with owners (offer `to-tickets`), open questions with
  owners, what changed versus the prep.
- **mail** / **note** — one purpose stated in the first line, then the minimum
  the reader needs; personas or a steps table when they make it scannable.
- **questionnaire** — questions for someone else (or their agent) to answer
  without context: numbered, each with options and the reason it matters,
  grouped per decision. When the answers come back, ingest them and offer
  `decide record`.
- **update** — management update or deck: outline first, then script, then a
  preview (contact sheet, slide titles) for approval; render the expensive
  artefact (deck via `pptx`, video) only after the preview is approved.
  Verify any demo shown is the current deployed version.
