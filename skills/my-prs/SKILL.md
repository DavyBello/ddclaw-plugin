---
name: ddclaw:my-prs
description: Fetch PRs assigned personally to me (not team), plus my open PRs with updates. Use when user says "my PRs", "review queue", "PRs to review", or "open PRs".
---

Fetch PRs using the GitHub GraphQL API to distinguish personal vs team review requests.

## 0. Get GitHub username

```bash
gh api user --jq '.login'
```

Store the result as `$GH_USER`.

## 1. PRs where I'm personally a requested reviewer

```bash
gh api graphql -f query='
{
  search(query: "is:pr is:open draft:false review-requested:$GH_USER", type: ISSUE, first: 30) {
    nodes {
      ... on PullRequest {
        number
        title
        url
        createdAt
        author { login }
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
}' --jq '.data.search.nodes[] | select(.reviewRequests.nodes[]?.requestedReviewer.login? == "$GH_USER") | {number, title, url, author: .author.login, createdAt}'
```

Replace `$GH_USER` with the actual username from step 0 in both the search query and the jq filter.

This filters out PRs that are only assigned to a team (e.g., via CODEOWNERS) and returns only ones where the user is explicitly listed as a `User` reviewer.

## 2. My open PRs

```bash
gh search prs --author=$GH_USER --state=open --json number,title,url,repository,createdAt
```

## Output format

```
## PRs awaiting my review (X)
- [title](url) — author, age

## My open PRs (X)
- [title](url) — review status
```

If either section is empty, say so in one line.
