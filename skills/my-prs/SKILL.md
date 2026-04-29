---
name: ddclaw:my-prs
description: Fetch PRs assigned personally to me (not team), plus my open PRs with updates. Use when user says "my PRs", "review queue", "PRs to review", or "open PRs".
---

Fetch PRs using the GitHub GraphQL API to distinguish personal vs team review requests.

**Critical:** The REST search API (`review-requested:USER`) returns PRs where the user OR any team they belong to is a reviewer. You MUST use GraphQL with `reviewRequests` to filter down to personal-only requests.

## 0. Get GitHub username

```bash
gh api user --jq '.login'
```

Store as `GH_USER`.

## 1. PRs where I'm personally a requested reviewer

Use GraphQL to fetch candidates and filter by reviewer type. Substitute the actual username into both the search query string and the jq filter (do NOT leave literal `GH_USER` in the query):

```bash
gh api graphql -f query='
{
  search(query: "is:pr is:open draft:false review-requested:USERNAME_HERE", type: ISSUE, first: 30) {
    nodes {
      ... on PullRequest {
        number
        title
        url
        updatedAt
        author { login }
        repository { nameWithOwner }
        reviewRequests(first: 20) {
          nodes {
            requestedReviewer {
              ... on User { login __typename }
              ... on Team { name __typename }
            }
          }
        }
      }
    }
  }
}'
```

Then filter the results: only include PRs where `requestedReviewer` contains a `User` entry with `login == GH_USER`. Discard PRs that only have `Team` entries — those are team-level CODEOWNERS requests, not personal.

## 2. My open PRs

```bash
gh search prs --author=GH_USER --state=open --json number,title,url,repository,updatedAt
```

Filter out non-org repos (personal repos, old forks, etc.) if the user has a primary org they care about.

## Output format

```
## PRs awaiting my review (X)
- [title](url) — repo, author, updated X ago

## My open PRs (X)
- [title](url) — repo, updated X ago
```

If either section is empty, say so in one line.
