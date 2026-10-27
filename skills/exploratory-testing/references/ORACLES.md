# Oracles: FEW HICCUPPS

An oracle is the specific reason you believe an observation is wrong, not just surprising. Oracles are heuristic and fallible: a violation suggests a problem, it doesn't prove one. Before recording a lead, name the letter.

| Letter | Heuristic | Ask |
| --- | --- | --- |
| **F** | Familiarity | Does this match a bug pattern you've seen before in similar systems? (The one heuristic that looks for a known-bad pattern rather than an inconsistency; useful for fast traction, but don't over-rely on it alone.) |
| **E** | Explainability | Can you articulate *why* it behaves this way? If neither you nor the project's own docs/code can explain it, that's itself worth flagging. |
| **W** | World | Is this consistent with general real-world knowledge (math, physics, plain facts), independent of the product itself? |
| **H** | History | Is this consistent with how the *same* system behaved before (a previous release, the CHANGELOG, an older recorded run)? A regression is a History violation by definition. |
| **I** | Image | Is this consistent with the image, brand, or reputation the project wants to project? |
| **C** | Comparable Products | Is this consistent with how comparable systems (same product line, competitors, or just systems that handle the same kind of data) behave? |
| **C** | Claims | Is this consistent with what the project's own docs, specs, comments, or stated promises say? A documented behavior the code doesn't match is a Claims violation, and the clearest kind of lead. |
| **U** | User's Desires | Would a reasonable user want this? |
| **P** | Product | Is this consistent with comparable elements *inside the same product* (two similar commands behaving differently from each other)? |
| **P** | Purpose | Is this consistent with what the thing is explicitly and implicitly for? |
| **S** | Statutes/Standards | Does this violate an external standard, spec, RFC, accessibility requirement, or law the project doesn't get to opt out of, regardless of whether it ever claimed to follow it? |

When recording a lead, write it as: "`<letter>` violation: <what you expected> vs. <what you observed>, because <the specific claim/standard/prior behavior>." If no letter applies, it's a curiosity worth a note, not a lead.
