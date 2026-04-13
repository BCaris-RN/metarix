# MetaRix Repository Intent

## Purpose

This repository exists to define, design, and implement MetaRix as a governed social operations platform.

MetaRix is being developed as a product-facing engineering repository. It is intended to hold source-of-truth product documentation, architecture decisions, governance projections, runtime implementation, and bounded build plans.

## Public repository posture

This repository is public for visibility, credibility, and disciplined development.

Public visibility does **not** mean unrestricted reuse of all material in this repository.

Until an explicit open-source license is added, rights remain reserved by the repository owner except where platform terms or separate written permission apply.

## What this repository is for

This repository is for:

- product charter and scope definition
- domain modeling
- architecture and repository boundary definition
- MetaRix-specific governance contracts and schemas
- bounded runtime implementation
- validation notes and release-facing engineering material

## What this repository is not for

This repository must not be used to store:

- production secrets
- API keys or tokens
- customer data
- private client requirements
- live connector credentials
- raw internal exports from third-party systems
- environment-specific operational details that create unnecessary exposure

## Architecture boundary posture

MetaRix follows the 8gentiC | Caris | Phoenix operating model.

- 8gentiC owns governed SDLC orchestration.
- Caris owns machine-readable governance truth.
- Phoenix owns runtime execution and operator presentation.

This repository must preserve those boundaries in both documentation and implementation.

## Implementation posture

MetaRix should be built conservatively.

The preferred path is:

1. define bounded product intent
2. define domain language
3. define governing contracts
4. define runtime surfaces
5. implement the smallest correct vertical slices
6. validate before widening scope

## Public collaboration posture

Outside readers may inspect the repository and its history.

That does not mean every concept here is complete, stable, or approved for downstream use.

Unless explicitly marked otherwise, materials in this repo should be interpreted as one of the following:

- conceptual source material
- bounded implementation work
- staged product architecture
- incomplete or evolving platform surfaces

No file should imply finished platform behavior unless that behavior is implemented and validated.

## Repository hygiene rules

- Do not commit secrets.
- Do not commit customer or private partner data.
- Do not widen scope silently.
- Do not confuse scaffolding with completion.
- Do not place governance logic in runtime surfaces that do not own it.
- Do not commit generated bundles or raw exports casually.
- Do not publish security-sensitive detail for convenience.

## Commercial posture

MetaRix is being developed with commercial product intent.

Public visibility supports product credibility and disciplined engineering, but the repository should remain safe for future commercialization, enterprise review, and architectural due diligence.

## Final rule

Treat every public commit as permanent, inspectable product evidence.

If a file would be a problem in a screenshot, a diligence review, a cached mirror, or a cloned copy, it should not be committed here.