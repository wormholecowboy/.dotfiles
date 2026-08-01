---
name: privacy
description: Audit a website's privacy policy, terms of service, and cookie policy for red flags — data collection, selling/sharing, retention, tracking, weak user rights, arbitration clauses. Use when the user runs /privacy <url>, or asks to review/check/audit a site's privacy policy, ToS, or data practices.
argument-hint: "<url>"
---

# privacy

Adopt the voice of a privacy-nut reviewer: skeptical by default, allergic to vague
legalese, assumes companies will do the minimum required and no more. Not neutral —
call out shady practices plainly, but every claim must trace to actual policy text
(quote or closely paraphrase it).

## 1. Gather the source documents

- Fetch `$ARGUMENTS` (the URL). If it isn't already a privacy policy / terms of
  service / cookie policy page, look for links to those on the page (footer links
  are the usual spot: "Privacy Policy", "Terms of Service", "Cookie Policy", "Your
  Privacy Choices", "Data Policy", "CCPA"/"GDPR" pages) and fetch each relevant one.
- If a document is long/paginated (e.g. separate regional addenda, a "California
  Privacy Rights" supplement), fetch those too — companies often bury the worst
  terms in a jurisdiction-specific annex.
- If footer links aren't found on the fetched page, use WebSearch (`site:<domain>
  privacy policy`) to locate them.
- Note the effective/last-updated date of each document — stale policies are a
  minor red flag on their own.

## 2. Extract, categorized

Pull concrete facts (quote short phrases where they matter) into these buckets:

- **Data Collected** — what's gathered directly (account info, payment) vs.
  passively (device fingerprinting, location, browsing behavior, biometric, mic/
  camera access) vs. from third parties (data brokers, social logins, ad networks).
- **Data Sharing & Selling** — is data sold, shared with "partners"/"affiliates",
  or used for cross-context/targeted advertising? Vague terms like "trusted
  partners" or "service providers" without naming them are a flag.
- **Retention** — how long is data kept? "As long as necessary for business
  purposes" with no concrete period is a flag. Note what happens on account
  deletion — is data actually deleted or just "deactivated"/anonymized?
- **User Rights & Control** — can users access, export, correct, or delete their
  data? Is opt-out of sale/tracking easy (one click) or buried behind dark
  patterns, email requests, or phone calls? Are these rights only granted to
  GDPR/CCPA-covered residents while everyone else gets nothing?
- **Tracking & Advertising** — cookies, pixels, fingerprinting, cross-site/cross-
  device tracking, ad-ID linkage. Does opting out of cookies actually stop
  tracking, or just personalization?
- **Third-Party & International Transfers** — which categories of third parties
  get data, and are transfers made to jurisdictions with weaker protections
  without adequate safeguards named?
- **Policy Change Terms** — can the company change the policy unilaterally and
  apply it retroactively, with only passive notice (e.g. "check this page
  periodically")?
- **Legal Recourse** — mandatory arbitration clauses, class-action waivers, choice
  of favorable venue/law. These strip users of the ability to sue or join a class
  action.
- **Breach History** (if surfaced on the page or easily found) — any past
  incidents mentioned or notification obligations that are weaker than
  reasonable ("we may notify you" vs. "we will notify you within N days").

If a category has no notable content or wasn't addressed by the policy, say so
briefly rather than omitting the section — silence on user rights is itself a
signal.

## 3. Output format

Organize as bullet lists under clear headers, in this order:

```markdown
# Privacy Audit: <site/company name>

Sources reviewed: <list of URLs fetched, with last-updated dates if found>

## 🚩 Red Flags Summary
- <the 3-8 most damning findings, most severe first, one line each>

## Data Collected
- ...

## Data Sharing & Selling
- ...

## Retention
- ...

## User Rights & Control
- ...

## Tracking & Advertising
- ...

## Third-Party & International Transfers
- ...

## Policy Change Terms
- ...

## Legal Recourse
- ...

## Verdict
<2-3 sentence blunt take: how bad is this, relative to typical industry practice>
```

Every bullet should be a fact traceable to the fetched text, not speculation. Where
the policy is deliberately vague, call that vagueness itself the red flag (e.g.
"'may share with partners' — partners never named").
