---
name: ddclaw:peer-feedback
description: Generate structured, actionable peer feedback grounded in career path expectations and concrete examples
user_invocable: true
---

**Task**
You are helping me write peer feedback. Ask me for the following before starting:
- $NAME: the person I'm writing feedback for
- $ROLE: their role (e.g. Senior Software Engineer, Engineering Manager 1, Senior Product Designer)
- $FOLDER_PATH: the path to my feedback folder (contains all reference files). Default: `context/projects/q1-2026-performance-reviews`

**Research**
- Read the Career Path Guidelines CSV from the skill directory (`.claude/skills/ddclaw:peer-feedback/`), specifically for $ROLE. There are four CSVs:
  - "Software Engineering Career Path Guidelines - Technical Path.csv" for IC engineering roles (SE through Principal Engineer)
  - "Software Engineering Career Path Guidelines - Managerial Path.csv" for engineering management roles (Engineering Manager I through Engineering VP)
  - "Product Design Career Paths - IC Path.csv" for product design IC roles (PD I through Sr Staff PD)
  - "Product Design Career Paths - MGR Path.csv" for design management roles
  Pick the right one based on $ROLE.
- The CSV has very long lines. Use python csv reader or similar to parse it rather than reading raw.
- Find a file corresponding to $NAME in $FOLDER_PATH for the feedback thoughts that I have on the person.
- Also check `context/people/` for any existing person file on $NAME.
- Read $FOLDER_PATH/good_peer_feedback_references.md if it exists, to get an idea of how to write the feedback and the voice to use.
- Read $FOLDER_PATH/feedback-framework.md for the Datadog feedback framework (SBI, quality principles).

**Structure reference (from internal guide)**
- 1-2 pages max
- 3 points max (positive) + impact
- 3 points max (constructive) + impact
- Cover the last 6-12 months
- Clear amplitude: be specific about how strong/frequent the behavior is
- Propose solutions for constructive feedback
- Need more than 3 instances of something happening to reflect it in feedback
- Connect feedback to the level (tie it to career path expectations)
- Avoid lists/bullets in the final output, write in prose

**Voice reference (fallback if good_peer_feedback_references.md is hard to parse)**
- Personal and specific: reference concrete situations, not abstract qualities
- Frame growth areas around potential, not criticism ("could increase his impact by..." not "fails to...")
- Use "could do" language for improvement areas
- Tie observations to impact on the team or project

**Plan**
- Plan feedback for $NAME based on the reading materials above. The feedback needs to answer two questions:
	- 1. What is one thing this employee should continue doing well?
	- 2. What is one thing this employee should start doing differently?
	The feedback should be tied to the skills mentioned in the Career Path Guidelines and should use examples (with links) that I have provided in the person's $NAME doc. Only use examples and links I have provided. Never fabricate examples.
- Clarify your assumptions with me about the first question. If there are multiple strong themes, propose a primary and secondary and ask if both should be included.
- Clarify your assumptions with me about the second question.

**Execute**
- After my feedback, write a document with answers to both the questions.
- Write the output to $FOLDER_PATH/$NAME_feedback.md

**Style rules**
- No fluffy or superlative words (e.g. "exceptional", "raises the bar", "invaluable")
- Never use em dashes
- Avoid "He doesn't just X, he Y" sentence patterns and similar constructions that read as AI-generated
- Keep tone direct, specific, and grounded
- Lead with concrete examples and links rather than abstract praise
- Use the person's actual actions and decisions as evidence, don't editorialize
- Factual and measured — state what happened, let it speak for itself
- Say "meaningfully contributed" not "drove forward"; "driving conversations around" not "pitching on her own"
- Don't comment on whether something is "the right approach for their level" — the writer is a peer/collaborator, not their manager or career coach
- Don't inflate the impact of something — if it was a minor inconvenience, say so, don't dramatize it
- Short paragraphs, concise sentences, no filler phrases like "what stands out is" or "what I appreciate most"
- Read $FOLDER_PATH/Khushboo_feedback.md as a tone reference if it exists
