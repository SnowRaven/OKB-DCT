# Dynamic Campaign Tools (DCT)

Mission scripting framework for persistent Digital Combat Simulator (DCS)
missions.

Provide a set of tools to allow mission designers to easily create scenarios
for persistent dynamic campaigns within the DCS game world.

**D**ynamic **C**ampaign **T**ools relies on content that can be built
directly in the mission editor, these individuals need little to no
programming skills to provide content to a DCT enabled mission.

Scenarios are created through a theater definition consisting of templates,
created in the Mission Editor and configuration files. There is an initial
learning curve but it is no more difficult than initially learning the DCS
Mission Editor.

## Getting Started

See our documentation [here](https://jtoppins.github.io/dct/quick-start).

## Features

* **Mission Creation**
  - uses static templates for reusable asset creation
  - no large .miz to manage just place player slots
  - theater and region organization to control spawning
    and placement
  - settings to customize how you want your campaign to
    play

* **Game Play**
  - Focus on more goal based gameplay vs. "air quake"
  - mission system used by AI and players
  - ticket system to track win/loss critera
  - Integrated Air Defense per faction
  - Weapon point buy system for players to limit kinds and
    types of payloads
  - Bomb blast effects enhancement and weapon impact system

* **Technical**
  - Built for large scale scenarios
  - **Persistent campaign progress across server restarts**

## Contribution Guide

See our [documentation](https://jtoppins.github.io/dct/), in sort contributions
can be made with a github pull request but features and/or changes need to be
discussed first. Code is licensed under LGPLv3 and contributions must be
licensed under the same. For any issues or feature requests please use the
issue tracker and file a new issue. Please make sure to provide as much detail
about the problem or feature as possible. New development is done in feature
branches which are eventually merged into `master`, base your features and
fixes off `master`.

## Contact Us

You can join the VMFA-169 discord (https://discord.gg/6z8uERVW5Y) if you
would like to discuss DCT topics. The channel is
`#dynamic-campaign-tools-discussion`.

This branch is maintained by kukiric#5535 on Discord for the LK Flashpoint Levant
sever.
