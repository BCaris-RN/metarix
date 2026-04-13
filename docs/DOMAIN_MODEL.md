# MetaRix Domain Model

## 1. Purpose

This document defines the first-pass canonical language for MetaRix.

Its purpose is to prevent ambiguity during design and implementation.

If a term is not defined here, it should not quietly gain product meaning through UI text alone.

## 2. Domain model rules

### Rule 1
A domain object is not just a screen label. It must represent stable meaning.

### Rule 2
The same term should not carry different meanings in planning, reporting, and execution.

### Rule 3
Workflow states must be explicit and enumerable.

### Rule 4
Execution concepts must remain distinguishable from recommendation concepts.

### Rule 5
Governance meaning belongs in Caris when it becomes policy or machine-enforced truth.

## 3. Core bounded domains

MetaRix is composed of the following domain families:

- strategy domain
- planning domain
- content domain
- workflow domain
- scheduling and execution domain
- listening and intelligence domain
- analytics and reporting domain
- optimization domain
- evidence and governance domain

## 4. Strategy domain

### Workspace
The top-level product container for an organization or operating context.

### Brand
A distinct brand or business identity managed inside a workspace.

### Business Goal
A business-level outcome such as awareness, demand, conversion, retention, or reputation.

### Social Goal
A social-media-specific goal aligned to a business goal.

Examples:
- awareness
- engagement
- conversions
- consumer sentiment

### Metric Target
A measurable goal threshold attached to a social goal.

Examples:
- follower growth
- reach
- impressions
- comments
- clicks
- sales
- sentiment score
- average response time

### Audience Persona
A structured representation of a target audience segment.

Fields may include:
- name
- job title
- demographics
- preferred networks
- brand affinities
- budget
- goals
- pain points
- how we help

### Competitor
A tracked external brand or account used for comparison, benchmarking, or opportunity analysis.

### SWOT Entry
A structured statement tied to strengths, weaknesses, opportunities, or threats.

### Audit Finding
A structured observation from a social audit.

### Benchmark Snapshot
A dated summary of key channel performance values used for comparison.

### Content Pillar
A recurring theme or message category that guides content creation.

Examples:
- educational / informative
- branded / promotional
- company culture / values

## 5. Planning domain

### Campaign
A bounded initiative with goals, date range, target channels, and reporting expectations.

### Editorial Calendar
A planning structure that maps campaigns, themes, launches, and content timing at a high level.

### Content Calendar
A post-level schedule view for planned individual social content.

### Evergreen Content Item
A reusable content unit that is not tied to a single short-term campaign.

### Content Library Entry
A stored reference to reusable content or asset material.

### Asset
A content resource such as image, video, link, copy block, template, or brand artifact.

### Resource Link
A pointer to an external plan, asset location, or dependency needed for execution.

## 6. Content domain

### Post Draft
A structured draft of a planned social post.

Suggested minimum fields:
- id
- title
- campaignId
- brandId
- targetNetwork
- contentPillarId
- copy
- callToAction
- assetRefs
- plannedPublishAt
- currentState

### Post Variant
An alternate version of a post adapted for a specific channel or test case.

### Top Performing Post
A post identified as high-performing relative to a reporting period or comparison set.

### Standout Result
A non-standard but meaningful outcome not fully represented by a charted metric.

Examples:
- influencer outreach success
- testimonial capture
- unusual community response
- reputation event

## 7. Workflow domain

### Review Assignment
A request for a named reviewer or role to evaluate a draft.

### Approval Record
A structured record that a reviewer approved, rejected, or requested revisions.

### Revision Request
A structured request to change a draft before approval.

### Denial Reason
A named reason that a workflow or execution step is blocked or refused.

### Content State
The lifecycle state of a post or content object.

Recommended first-pass states:
- draft
- in_review
- changes_requested
- approved
- scheduled
- publish_eligible
- publish_denied
- published
- archived

Important:
`schedule` is not the same thing as `publish_eligible`.
`publish_eligible` is not the same thing as `published`.

## 8. Scheduling and execution domain

### Schedule Record
A structured plan to publish or prepare a post for a specific date, time, and channel.

### Publish Eligibility
The current bounded posture of whether a scheduled item is allowed to proceed.

### Publish Job
A discrete execution unit that attempts a publish-related action.

### Dry Run
A no-side-effect execution or validation path used to inspect readiness.

### Schedule Conflict
A detected overlap, constraint failure, or bounded rule mismatch affecting planned timing.

### Channel Account
A managed account or destination on a specific social network.

### Connector Capability
A declared action or data capability supported for a given channel account or integration.

Examples:
- draft support
- schedule support
- publish support
- analytics ingest
- listening ingest
- comment reply support

## 9. Listening and intelligence domain

### Listening Query
A saved structured query used to monitor a brand, campaign, competitor, trend, or topic.

### Query Family
A grouping label for listening queries.

Examples:
- brand
- campaign
- competitor
- industry
- influencer
- crisis

### Mention
A captured reference to a brand, campaign, competitor, product, or related topic.

### Conversation
A grouped set of related social interactions.

### Sentiment Observation
A classified emotional or attitudinal signal attached to a mention or conversation.

### Spike Event
A sudden notable increase in mentions, sentiment movement, or topic velocity.

### Influencer Record
A tracked creator, thought leader, or account relevant to a monitored domain.

### Share of Voice Snapshot
A bounded comparison of discussion volume or attention across tracked competitors or topics.

### Escalation Candidate
A mention, conversation, or event that should be routed for human follow-up.

## 10. Analytics and reporting domain

### Report Period
A bounded time window for analysis.

### Channel Performance Record
A structured record of metrics for one channel over one report period.

### Comparative Range
A prior date range used for comparison.

### Success Snapshot
A summary of the most important results in a reporting period.

### Takeaway
A structured reporting conclusion.

Fields should answer:
- what happened
- why it happened
- how we know
- what we learned

### Overall Learning
A generalized strategic lesson derived from one or more takeaways.

### Future Strategy Action
A next-step adjustment derived from performance and learnings.

### Continue / Stop / Start Action
A specific recommendation for ongoing behavior change.

## 11. Optimization domain

### Recommendation
A structured suggestion for improving future performance.

Suggested minimum fields:
- recommendationType
- targetObject
- rationale
- evidenceRefs
- expectedBenefit
- confidenceLabel
- owner
- status

### Recommendation Type
Examples:
- posting cadence adjustment
- channel emphasis adjustment
- content pillar adjustment
- format adjustment
- benchmark correction
- audience response action

### Hypothesis
A testable explanation for observed outcomes.

### Experiment
A bounded attempt to validate a content or channel hypothesis.

## 12. Evidence and governance domain

### Evidence Record
A structured proof object that something happened or was approved.

### Evidence Bundle
A grouped set of evidence records related to a workflow or report period.

### Runtime Receipt
A bounded runtime emission describing an action, decision, or denial.

### Policy Version
The version of the governing policy bundle that applies to a workflow state or execution event.

### Approval Requirement
A named rule requiring review or approval before an action may proceed.

### Review Class
A named human review level used in governed workflows.

### Bounded Action
An action explicitly allowed within the current product and governance posture.

### Forbidden Action
An action explicitly blocked under current policy or scope posture.

## 13. Entity relationships

The most important first-pass relationships are:

- a Workspace contains one or more Brands
- a Brand contains Business Goals, Social Goals, Personas, Competitors, and Campaigns
- a Campaign references one or more Content Pillars and Channel Accounts
- a Campaign contains or references Post Drafts
- a Post Draft may reference Assets and one or more Post Variants
- a Post Draft moves through Content State changes
- a Review Assignment and Approval Record attach to a Post Draft
- a Schedule Record attaches to an approved Post Draft
- a Publish Job may attach to a Schedule Record
- a Listening Query may produce Mentions, Conversations, Spike Events, and Escalation Candidates
- a Report Period contains Channel Performance Records, Success Snapshots, Takeaways, and Future Strategy Actions
- Evidence Records and Runtime Receipts may attach to workflow and execution objects

## 14. First-pass canonical enums

### Social goal types
- awareness
- engagement
- conversions
- consumer_sentiment

### Content pillar types
- educational
- promotional
- culture
- community
- product
- campaign_specific
- experimental

### Report action types
- continue
- stop
- start
- investigate
- escalate

### Publish posture types
- not_ready
- ready_for_review
- approved
- scheduled
- publish_eligible
- publish_denied
- executed

## 15. Future machine-readable projection

This document is conceptual first.

Once stabilized, its authoritative machine-readable projections should move into Caris-owned artifacts such as:

- domain schemas
- state contracts
- capability registries
- approval policy mappings
- evidence requirement contracts

Phoenix may consume those artifacts, but Phoenix must not redefine them locally.

## 16. Open modeling questions

These remain intentionally unresolved until implementation planning sharpens them:

1. Which networks are first-class in v1?
2. Which metric definitions need versioned formulas?
3. Which report fields are editable narrative versus computed structure?
4. Which recommendation types are advisory only versus operator-assignable?
5. Which listening query operators are required in v1 versus later?
6. What minimum evidence threshold is required before a schedule becomes publish-eligible?

## 17. Final rule

MetaRix should not allow undefined vocabulary to become product truth.

If a term matters to planning, execution, reporting, or governance, it should be named here first and then projected into the proper owning layer.