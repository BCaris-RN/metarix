# MetaRix Product Charter

## 1. Purpose

MetaRix exists to provide an enterprise-grade, governed operating system for social media planning, publishing, intelligence, reporting, and optimization.

The goal is not simply to make posting easier.

The goal is to give operators and organizations a system that can:

- plan with intent
- execute with control
- observe with context
- analyze with discipline
- improve with evidence

## 2. Product problem

Most social media teams work across fragmented tools and manual processes.

Common failure modes include:

- strategy living in slides while execution lives elsewhere
- content calendars detached from actual post objects
- weak approval and audit discipline
- posting without a clear evidence trail
- listening outputs that remain passive instead of actionable
- reports that count metrics without explaining performance
- optimization that depends on opinion instead of structured observation

MetaRix is intended to solve this by turning strategy, execution, intelligence, and reporting into one governed operating surface.

## 3. Product vision

MetaRix will become the central operating layer for social teams that need more than scheduling.

It will unify:

- strategy definition
- planning and editorial structure
- governed execution
- monitoring and listening
- analytics and structured reporting
- optimization recommendations
- operator evidence and accountability

## 4. Category claim

MetaRix is a governed social operations platform.

It is not only:

- a content calendar
- a scheduler
- a listening dashboard
- an analytics report builder

It is the control system that binds those functions into one bounded enterprise workflow.

## 5. Primary users

### Primary operator personas

1. Social Media Manager  
   Owns calendars, publishing workflow, reporting rhythm, and channel execution.

2. Content Strategist  
   Owns content pillars, campaign planning, editorial sequencing, and messaging structure.

3. Brand / Marketing Lead  
   Owns goals, channel posture, budget decisions, and performance expectations.

4. Community / Engagement Operator  
   Owns conversations, response actions, sentiment observation, escalation, and follow-up.

5. Analyst / Performance Manager  
   Owns benchmarking, reporting, insights, and optimization recommendations.

### Secondary buyer / oversight personas

1. Marketing Director or VP Marketing  
2. Brand Director  
3. Agency Lead  
4. Compliance-sensitive enterprise marketing or communications lead  
5. Operations or platform owner responsible for governed execution

## 6. Product outcomes

MetaRix should help organizations produce the following outcomes:

- align social goals to business goals
- make editorial planning operational instead of presentation-only
- reduce execution ambiguity
- improve scheduling discipline
- surface competitive and audience intelligence faster
- move from vanity metrics to causal analysis
- improve campaign iteration quality
- make publish posture reviewable and auditable
- increase confidence in what should continue, stop, or start

## 7. Scope boundaries

MetaRix is in scope for:

- social strategy structure
- campaign planning
- content organization
- post drafting
- post review and approval
- scheduling
- bounded publish execution
- listening queries and observation workflows
- comparative benchmarks
- report generation
- optimization recommendations
- evidence and audit posture

MetaRix is out of scope for the following unless explicitly added later:

- generalized ad buying
- full creative production suite replacement
- uncontrolled autonomous posting
- broad CRM replacement
- generalized customer support platform replacement
- doctrine or governance authorship inside Phoenix runtime surfaces

## 8. Product principles

### Principle 1: Strategy must become structured data
Strategy cannot remain trapped in decks, notes, or one-off meetings.

### Principle 2: Publishing is a governed action
A scheduled post is not automatically a publish-eligible post.

### Principle 3: Listening must create action
Listening findings must be routable, interpretable, and useful.

### Principle 4: Reporting must explain, not just count
The system must support “what happened,” “why it happened,” “what we learned,” and “what changes next.”

### Principle 5: Optimization must be evidence-backed
Recommendations should tie to observed performance, benchmarks, or listening signals.

### Principle 6: Architecture boundaries are law
8gentiC, Caris, and Phoenix must remain separate in authority and responsibility.

## 9. Architecture alignment

### 8gentiC responsibility
8gentiC owns:

- SDLC orchestration
- workflow definitions
- handoff contracts
- review classes
- integrity logic
- build routing
- release sequencing

### Caris responsibility
Caris owns:

- machine-readable governance truth
- schemas
- policy manifests
- permission contracts
- connector capability rules
- publish boundedness rules
- hard gates
- evidence requirements

### Phoenix responsibility
Phoenix owns:

- operator shell behavior
- runtime state presentation
- evidence visibility
- approval posture presentation
- denial visibility
- bounded execution flows

MetaRix must preserve this separation.

## 10. Initial product thesis for v1

The first release should prove a complete, bounded path from:

strategy -> planning -> draft -> approval -> schedule -> report -> evidence

The first release does not need to prove every possible connector, channel, or intelligence feature.

It needs to prove disciplined workflow and product credibility.

## 11. Success criteria

MetaRix v1 will be considered successful if a real operator can:

- define strategy inputs
- create a campaign structure
- organize content against pillars and schedule
- move content through review and approval
- prepare or execute bounded scheduling flows
- view basic performance and benchmark outputs
- produce a structured report
- understand what should continue, stop, or start next
- inspect the evidence posture of key actions

## 12. Delivery doctrine

The product should be built using these implementation rules:

- smallest correct change
- no silent scope widening
- no governance/runtime conflation
- no placeholder prose pretending to be implementation
- no uncontrolled autonomous behavior
- no architecture drift for convenience
- no declaring completion without validation

## 13. Immediate next documents

The following documents are required to operationalize this charter:

- `docs/V1_SCOPE.md`
- `docs/DOMAIN_MODEL.md`

Additional Caris and Phoenix surfaces should be created only after these bounded product documents are stable.