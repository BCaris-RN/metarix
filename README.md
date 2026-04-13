# MetaRix

MetaRix is a governed social media operations platform built to help teams plan strategy, manage content, schedule and control publishing, monitor social environments, analyze performance, and continuously optimize execution.

This repository is not a generic “social dashboard” and it is not a loose collection of marketing screens. MetaRix is being built as an enterprise-grade operating surface for governed social execution.

## Product category

MetaRix is a governed social operations platform.

It combines:

- strategy definition
- editorial planning
- controlled scheduling and publish execution
- social listening and competitor intelligence
- analytics and structured reporting
- optimization recommendations
- evidence-backed operator workflows

## Core thesis

Most social tools help teams post.

MetaRix is being designed to help teams operate social media with discipline.

That means the system must make planning explicit, execution bounded, analytics explainable, and publish posture auditable.

## Architecture posture

MetaRix follows the 8gentiC | Caris | Phoenix framework.

- **8gentiC** owns governed SDLC orchestration, handoffs, review classes, integrity logic, and build routing.
- **Caris** owns constitutional governance, schemas, policy manifests, permissions, hard gates, and machine-readable truth.
- **Phoenix** owns the bounded runtime, operator workbench, evidence presentation, denial visibility, and controlled execution behavior.

MetaRix must preserve these boundaries at all times.

## What MetaRix is expected to do

MetaRix is expected to support the following operating domains:

1. Strategy workspace  
   Define business goals, social goals, audience personas, competitor context, audit findings, benchmarks, and content pillars.

2. Planning workspace  
   Organize campaign calendars, weekly schedules, evergreen content, assets, and post drafts.

3. Governed publishing workspace  
   Move content through draft, review, approval, scheduling, publish-eligibility checks, execution, and evidence capture.

4. Listening and intelligence workspace  
   Track brand terms, campaign terms, competitor terms, industry terms, influencers, sentiment, and spikes.

5. Reporting and analytics workspace  
   Show what happened, why it happened, what was learned, and what should change next.

6. Optimization workspace  
   Recommend better timing, better formats, stronger channels, better-performing themes, and corrective actions.

## Release posture

MetaRix will be built conservatively.

The first release focuses on a bounded, credible operator path rather than full platform breadth.

Initial emphasis:

- strategy workspace
- content planning
- draft and approval workflow
- limited scheduling
- bounded publish posture
- baseline reporting
- evidence and audit surface

## Repository intent

This repository should become the local source of truth for the MetaRix product program.

It should contain:

- product-facing documentation
- MetaRix-specific governance contracts and schemas
- runtime implementation surfaces
- bounded build plans
- release evidence and validation notes

## Working principles

- Preserve architecture boundaries.
- Prefer deterministic behavior over cleverness.
- Keep execution bounded and reviewable.
- Treat publish actions as governed operations, not casual UI events.
- Do not fabricate completion.
- Do not widen scope silently.
- Treat every major surface as a contract-backed system, not a mockup.

## Current document map

- `docs/PRODUCT_CHARTER.md`
- `docs/V1_SCOPE.md`
- `docs/DOMAIN_MODEL.md`

Additional folders and contracts will be added as MetaRix moves from charter to implementation.
