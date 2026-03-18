---
name: ddclaw:manager-evaluation
description: Write a manager evaluation for a direct report, grounded in career path expectations, peer feedback, PR/Jira evidence, and previous cycle data
user_invocable: true
argument-hint: <person-name>
---

**Task**
You are helping me write a manager evaluation for a direct report. This is a structured, multi-step process.

## Step 1: Gather inputs

Ask me for:
- $NAME: the person being evaluated
- $ROLE: their role (e.g. Software Engineer 2, Senior Software Engineer)

Derive or confirm:
- $REVIEW_FOLDER: check `context/config.md` for the review folder path, or ask if not set
- $PERSON_FOLDER: `$REVIEW_FOLDER/{name-slug}` (e.g. `matthew-hibbs`)

## Step 2: Read existing context

Read all of these. Flag anything missing rather than proceeding silently.

**Career path expectations:**
- Read the Career Path Guidelines CSV from `.claude/skills/ddclaw:peer-feedback/` for $ROLE. Pick the right CSV:
  - "Software Engineering Career Path Guidelines - Technical Path.csv" for IC engineering roles
  - "Software Engineering Career Path Guidelines - Managerial Path.csv" for engineering management roles
  - "Product Design Career Paths - IC Path.csv" for product design IC roles
  - "Product Design Career Paths - MGR Path.csv" for design management roles
- The CSV has very long lines. Use python csv reader or similar to parse it rather than reading raw.
- Extract the column matching $ROLE. Present the SE competency grid as a table to me.

**Review framework:**
- `$REVIEW_FOLDER/feedback-framework.md` — SBI framework, quality principles
- `$REVIEW_FOLDER/manager-evaluation-guide.md` — evaluation process, performance indicators
- `$REVIEW_FOLDER/performance-feedback-template.md` — output format template

**Person context:**
- `context/people/{name-slug}/README.md` — working style, strengths, growth areas, 1:1 notes
- `context/self/feedback.md` — my own management patterns and observations

**Previous evaluation:**
- Check `$PERSON_FOLDER/previous-evaluation.md`. If missing, ask me to provide it (PDF or text).
- Extract previous: rating, strengths, growth areas, next steps, self-eval.

## Step 3: Collect this cycle's inputs

Check `$PERSON_FOLDER/` for these files. If any are missing, ask me to provide them:
- `self-evaluation.md` — this cycle's self-eval
- `peer-feedback.md` — this cycle's peer feedback
- `pr-jira-report.md` — PR and Jira evidence

If `pr-jira-report.md` is missing, offer to kick off a background agent to generate it. The agent should:
- Find the person's GitHub username from their person file or by checking a known PR
- Pull all merged PRs from the relevant repos for the review period (last 6 months)
- Look up Jira tickets assigned to them (use Atlassian MCP if available)
- Check PR review activity
- Save to `$PERSON_FOLDER/pr-jira-report.md`

## Step 4: Analyze — present before drafting

Before writing anything, present your analysis to me:

**4a. Progress from previous cycle:**
For each growth area from the previous evaluation, assess: Clear progress / Some progress / Limited progress / No evidence. Cite specific examples.

**4b. Peer feedback themes:**
Synthesize strengths and growth areas across all peer reviewers. Note convergent signals (multiple people saying the same thing).

**4c. Self-eval alignment check:**
Where does the self-eval align with peer feedback and your observations? Where does it diverge? Flag any blind spots.

**4d. Career path mapping:**
Map the person against each competency area for $ROLE. For each: Meeting / Exceeding / Below. Cite evidence.

**4e. Performance indicator recommendation:**
Recommend one of: Needs Development / On Track / Sets a New Standard. Justify with career path expectations.

Wait for my feedback on this analysis before drafting.

## Step 5: Draft the evaluation

Use the template format from `$REVIEW_FOLDER/performance-feedback-template.md`. The output has these sections:

### Performance Indicator
- Rating (one of three)
- Comment: 2-5 sentence summary covering: great, improvement areas, look forward

### Manager Evaluation
- 1-2 strengths with ➕ prefix, each with:
  - Short memorable label (one or two words)
  - Details with links/examples mapped to career ladder
- Aggregated peer feedback quotes (anonymized, italicized) supporting the strengths
- 1-2 growth areas with ➖ prefix, each with:
  - Short memorable label
  - Details with links/examples mapped to career ladder
- Aggregated peer feedback quotes (anonymized, italicized) supporting the growth areas

### Next Step
- 2-line summary
- Specific actions mapped to career path competency areas:
  - Scope & Impact
  - Technical Leadership
  - Culture & Drive for Improvement
  - General Expertise
  - Design
  - Coding
  - Performance & Efficiency
  - Operations
- Only include competency areas where there's a concrete action. Skip areas where performance is solid.

### Self Evaluation
- Copy the employee's self-eval strengths and development areas (for reference during the conversation)

Save to `$PERSON_FOLDER/evaluation-draft.md`

## Step 6: Review and iterate

Present the draft to me. Iterate based on my feedback. When finalized, save to `$PERSON_FOLDER/evaluation-final.md` and update the project README status for this person.

## Style rules
- No em dashes. Use periods or commas.
- No hedging or disclaimers.
- Direct statements. Say what's missing, not why it's understandable that it's missing.
- Tight paragraphs. Cut examples that don't add new information.
- Don't over-explain the positive. The strengths section should be concise with evidence.
- Watch for contradictions. If rating "On Track," don't describe performance that sounds like "Sets a New Standard" in the strengths section, or vice versa.
- Factual and measured. State what happened, cite the PR/Jira/peer quote, let it speak for itself.
- No fluffy or superlative words (e.g. "exceptional", "raises the bar", "invaluable").
- Peer feedback quotes must be anonymized (no names, just italicized quotes).
- When referencing career path expectations, quote the specific competency text.
- Link to PRs, Jira tickets, project plans, and Confluence pages where possible.
