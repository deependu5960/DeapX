DeapX Technical Specification v1.0
Status: DRAFT
Version: 1.0
Classification: Internal Engineering Document
Owner: Chief Architect, DeapX Operating System
Last Updated: 2026-07-09

1. Project Vision
DeapX is a modern Debian-based Linux distribution engineered to deliver a cohesive, brand-centric computing experience without compromising the stability, security, and package ecosystem that define Debian GNU/Linux. The project unites original visual and functional branding with the rigorous quality assurance and community-driven development model of its upstream foundation.

The vision encompasses a complete operating system that feels intentionally designed, visually coherent, and technically robust for both desktop and server deployments. DeapX positions itself as a distribution that respects user freedom, provides predictable release cycles, and maintains a clean separation between the base system and the custom branding layer to facilitate long-term maintainability.

2. Design Philosophy
The DeapX design philosophy is guided by four core principles:

Simplicity Through Cohesion
Every component, from the boot splash to the application launcher, should present a unified visual language and interaction model. Complexity is hidden from the user unless explicitly requested.

Stability Without Stagnation
The distribution tracks Debian Stable for the core operating system while selectively incorporating newer user-facing components where they provide clear value. Updates are delivered with minimal disruption.

Transparency in Engineering
All modifications to upstream packages are documented, patch-driven, and reversible. Build processes are reproducible and auditable. Configuration is declarative where possible.

Originality in Branding
The DeapX identity is unique and consistent across all touchpoints, including the boot screen, login manager, desktop environment, system dialogs, and documentation. Brand assets are treated as first-class project artifacts.

3. System Goals
Maintain 100% binary compatibility with Debian Stable repositories to ensure access to the full Debian package ecosystem without modification.

Deliver a reproducible build process capable of generating identical ISO images from source in a deterministic manner.

Provide a complete desktop experience from boot to shutdown that feels polished and integrated.

Support x86_64 architecture as the primary target with optional ARM64 evaluation.

Keep base system modifications to a minimum to facilitate easy rebasing on new Debian Stable releases.

Reduce post-installation configuration burden by shipping sensible, opinionated defaults.

Ensure the system passes Debian Policy compliance for any packages distributed under the DeapX name.

4. Target Users
Primary Audience:

Desktop users seeking a polished, Debian-based alternative to mainstream operating systems

Developers and system administrators who require a stable, predictable environment

Privacy-conscious users who prefer a distribution free from corporate telemetry and tracking

Open-source enthusiasts who value transparency and community governance

Secondary Audience:

Enterprise deployments requiring long-term stability and predictable upgrade cycles

Educational institutions seeking a free and open-source platform for computer science curriculum

DevOps engineers building CI/CD pipelines on a stable Linux foundation

Non-Target Users (Out of Scope):

Users requiring rolling-release updates or unstable software

Minimal-install or server-only deployments (supported but not optimized)

Real-time or embedded systems with specialized kernel requirements

5. Base Operating System
5.1 Debian Stable
DeapX is built on the latest Debian Stable release at the time of each major version freeze. The distribution does not include packages from Debian Testing, Unstable, or Experimental unless explicitly and temporarily backported with documented justification.

5.2 APT (Advanced Package Tool)
The APT package management system is preserved in its entirety, including all standard tools (apt, apt-get, aptitude), repository management (sources.list), and package resolution algorithms. DeapX adds custom repository metadata but does not modify APT's core behavior.

5.3 systemd
The systemd init system serves as the primary system and service manager. DeapX leverages systemd's unit architecture for service management, logging (journald), and system orchestration. Unit files for custom services are provided where necessary.

5.4 Linux Kernel
DeapX ships with the standard Linux kernel provided by Debian Stable. The kernel is not patched nor rebuilt unless specific hardware enablement or security fixes require it. Any kernel modifications are submitted upstream to Debian when appropriate.

6. The DeapX Layer
The DeapX Layer is the architectural innovation that distinguishes this distribution from standard Debian while preserving complete Linux compatibility. It sits above the Debian foundation and transforms the base operating system into a cohesive, branded user experience.

Architectural Stack:

text
Linux Kernel
        ↓
Debian Stable
        ↓
APT
        ↓
────────────────────────
        DeapX Layer
────────────────────────
Components of the DeapX Layer:

Branding – The complete visual and auditory identity system

Boot Experience – GRUB theme, Plymouth splash, and kernel parameters

Login Experience – Display manager theme and authentication flow

Desktop Experience – The customized desktop environment and window management

Themes – System-wide theming engine and asset libraries

Applications – DeapX-specific applications (Welcome, Settings, Updater, Control Center)

Welcome Application – First-run orientation and configuration assistant

Settings – Unified system configuration interface

Future Lobby – The planned 3D immersive environment

ISO Build System – Image generation and distribution tooling

Update System – Repository management and update orchestration

Architectural Principles of the DeapX Layer:

Independence – The DeapX Layer is maintained as a separate artifact from the Debian base, allowing independent evolution and easy rebasing.

Integration – All components within the layer communicate through well-defined interfaces, ensuring consistent behavior across the user experience.

Non-Destructive – The DeapX Layer does not modify Debian system files; it overlays and configures through drop-in directories, alternatives, and symlinks.

Complete Experience – The layer is not a collection of disjointed customizations but a cohesive, engineered system that transforms Debian into DeapX.

The DeapX Layer is the primary focus of development and innovation for the distribution, while the Debian foundation provides the stability, security, and vast package ecosystem.

7. Desktop Strategy
6.1 Current Desktop (Release 1.0 - 2.0)
The initial desktop environment is built on an existing Linux desktop environment but is extensively customized to deliver the complete DeapX user experience while preserving Linux compatibility and allowing future evolution. This approach ensures users receive a polished, integrated environment from first boot.

Key customizations include:

Complete visual rebranding including window decorations, icon themes, and system colors

Modified default panel layout and application menu organization

DeapX wallpapers, cursor themes, and sound schemes

Integrated welcome application for first-run setup and introduction

Customized system settings panels presenting DeapX configurations

Default application suite configured with DeapX bookmarks, themes, and preferences

The desktop is not merely a collection of themes or a superficial skin; it represents a comprehensive re-engineering of the user interface to align with the DeapX design philosophy while maintaining full compatibility with Linux applications and the Debian ecosystem.

6.2 Future 3D Lobby (Roadmap 3.0+)
The 3D Lobby is the planned long-term evolution of the DeapX desktop architecture. It will eventually become the primary graphical environment while maintaining compatibility with Linux applications.

Design Objectives:

Function as a spatial application launcher and workspace organizer

Support VR/XR headset integration as an optional enhancement

Maintain compatibility with traditional desktop applications via embedded windows or XWayland

Provide a novel and immersive user experience without sacrificing productivity or accessibility

Integrate with existing Linux graphics stacks (OpenGL, Vulkan, Wayland)

Development Pathway:

Prototype development begins in the DeapX research branch

Integration with the DeapX Layer occurs during the development cycle

Migration from experimental to primary desktop occurs in a planned major release

Users retain the option to use the traditional desktop environment indefinitely

The 3D Lobby is a planned and funded development initiative that represents the future direction of the DeapX user experience.

8. Boot Sequence
The DeapX boot sequence follows this chronological order:

UEFI/BIOS POST – Hardware initialization (unchanged from Debian)

Bootloader – GRUB2 with DeapX branding (wallpaper, theme) from the boot/ directory

Kernel Loading – Standard Debian kernel with DeapX boot parameters

Initramfs – Unmodified Debian initramfs tools

systemd Initialization – Standard Debian systemd units

Display Manager – Customized login screen with DeapX branding from login/

Session Initialization – Desktop environment with DeapX defaults from desktop/

The boot process is fully visible and can be modified via /etc/default/grub for advanced users. Boot messages are not suppressed to maintain transparency.

9. Login Flow
Display Manager Startup – A DeapX-branded display manager (LightDM or GDM-derived) presents the login interface, drawing assets from login/.

User Selection – The display manager lists available users with their associated avatars (placeholder avatar for new users).

Authentication – Standard Unix/PAM authentication is performed. Two-factor authentication is not enabled by default but can be configured.

Session Selection – Users may select between the DeapX default desktop, other installed environments, or a plain X session.

Post-Login Initialization – The display manager executes the user's .xsession or .xinitrc, which invokes the DeapX desktop environment from desktop/.

Automatic Application Launch – Configured auto-start applications (network manager, volume control, system tray) are launched via the desktop environment's startup mechanism.

All login screens feature DeapX branding including the project logo, custom color palette, and background imagery consistent with the overall visual identity.

10. Desktop Flow
Upon successful login, the user encounters the DeapX desktop environment:

Desktop Environment Loading – The customized desktop session starts with DeapX themes, icons, and window decorations applied from desktop/ and themes/.

Panel/Taskbar – A panel contains:

Main application menu (DeapX-branded)

Quick launch icons for essential applications

System tray (network, sound, power, notifications)

Clock and calendar

Workspace switcher

Desktop Background – The default DeapX wallpaper is displayed from assets/wallpapers/.

File Manager – The file manager is themed with DeapX branding and configured with DeapX bookmarks.

System Settings – The DeapX control center presents DeapX configurations alongside standard system settings.

Welcome Application – On first boot, a welcome wizard guides the user through system configuration, introduction to DeapX features, and orientation.

The desktop environment is designed to feel intuitive to both Linux veterans and users transitioning from proprietary operating systems.

11. Branding Philosophy
DeapX branding is a primary module of the operating system, not merely a decorative layer or an installable package. It is an integral component of the DeapX Layer and represents a fundamental aspect of the user experience.

Core Principles:

Consistency – Every visible element, from the GRUB menu to the software center, uses the same typography, color palette, and design language.

Subtlety – Branding enhances rather than distracts from the user experience. Animations and gradients are used sparingly.

Distinctiveness – The DeapX visual identity is not derivative of other distributions. Logos, icons, and fonts are original works.

Respect for Upstream – Branding is applied as a separate layer, leaving Debian's original artwork accessible but not displayed by default.

Branding Modules:

Module	Location	Purpose
Branding Core	branding/	Central branding configuration, metadata, and orchestration
Assets	assets/	Original logos, wallpapers, icons, fonts, cursors, and sounds
Boot Experience	boot/	GRUB theme, Plymouth splash, and boot-time assets
Login Experience	login/	Display manager theme, authentication screens, and user selection
Desktop Themes	desktop/	Window decorations, panel layouts, and desktop environment theming
Themes	themes/	System-wide GTK, Qt, and application themes
Branding Architecture:

Branding is part of the DeapX Layer and is always present in the system

Applications consume branding assets through defined APIs and theme engines

Branding is not installed as a standalone package; it is embedded in the system

Updates to branding are delivered as part of the DeapX Layer updates

Users may customize branding through system settings, but the default is the DeapX experience

Brand Assets (External):

Primary logo (SVG and PNG, multiple resolutions)

Icon theme (full set with DeapX aesthetic)

Wallpaper collection (curated and original)

Boot splash theme (GRUB and Plymouth)

Sound scheme (system and notification sounds)

All brand assets are maintained in the assets/ directory and released under an open-source license compatible with the MIT license.

12. Application Architecture
DeapX distinguishes between system applications and user applications:

System Applications (Pre-installed)

File Manager (custom themed)

Web Browser (Firefox ESR with DeapX bookmarks and theme)

Office Suite (LibreOffice with DeapX color scheme)

Email Client (Thunderbird with DeapX customization)

Media Player (VLC or equivalent)

Image Viewer (custom themed)

System Settings (DeapX control center from applications/settings/)

Terminal Emulator (with DeapX color profile)

Package Manager Frontend (software center with DeapX branding from applications/updater/)

DeapX-Specific Applications

Welcome Application (applications/welcome/)

System Configuration Utility (applications/settings/)

Software Updater (applications/updater/)

Control Center (applications/control-center/)

User Applications
All other applications are installed through APT from Debian repositories or DeapX repositories. No application store or snap installation mechanisms are imposed.

Application Integration

Default applications are registered via xdg-mime and update-alternatives

Application launchers include DeapX iconography from assets/icons/

Newly installed applications appear in the main menu automatically

13. Package Strategy
Base Repository Source
DeapX packages come primarily from Debian Stable repositories. No packages are removed from Debian; instead, DeapX adds packages and customizes existing ones.

Customization Method
Modifications to Debian packages are performed by:

Downloading the Debian source package

Applying patches (with proper DEP-3 headers)

Rebuilding with custom configuration flags

Hosting the built package in the DeapX repository

Repository Types

deapx-main – Fully open-source, complies with Debian Free Software Guidelines (DFSG)

deapx-contrib – Free software that depends on non-free components

deapx-nonfree – Proprietary or restricted packages (distributed separately)

Local Repository Management

Packages built from source are added to a local APT repository in packages/

The local repository is signed with a DeapX GPG key

The repository is used during ISO build and available for post-installation updates

14. Update Strategy
Release Cadence

Major Releases – Every 2 years, synchronized with Debian Stable releases

Point Releases – Quarterly, containing security updates and bug fixes

Security Patches – Released as soon as Debian issues corresponding updates

Update Mechanism

Standard apt update and apt upgrade workflow

DeapX custom packages are updated via the DeapX repository

Debian base packages are updated via Debian repositories

The DeapX Layer is updated through the applications/updater/ system

Update Policy

All updates are optional unless they address critical security vulnerabilities

Updates are tested on a staging environment before release

Major version upgrades require manual intervention (backup and restore)

Kernel updates follow Debian Stable's kernel ABI guarantee

15. Directory Structure
The DeapX repository is organized as follows:

text
DeapX/
├── README.md
├── LICENSE
├── .gitignore
├── docs/
│   ├── architecture/
│   ├── roadmap/
│   ├── specifications/
│   └── tasks/
├── assets/
│   ├── logos/
│   ├── wallpapers/
│   ├── icons/
│   ├── fonts/
│   ├── cursors/
│   └── sounds/
├── branding/
├── boot/
├── login/
├── desktop/
├── applications/
│   ├── welcome/
│   ├── settings/
│   ├── updater/
│   └── control-center/
├── themes/
├── packages/
├── scripts/
├── build/
├── iso/
├── testing/
├── future/
│   └── lobby3d/
└── releases/
Directory Descriptions:

Directory	Purpose
docs/architecture/	System architecture, design decisions, and technical documentation
docs/roadmap/	Project roadmap, milestone planning, and strategic direction
docs/specifications/	Feature specifications and technical requirements
docs/tasks/	Task tracking, work breakdown, and development assignments
assets/	All original brand assets (logos, wallpapers, icons, fonts, cursors, sounds)
branding/	Central branding configuration, metadata, and orchestration
boot/	GRUB theme, Plymouth splash, and boot-time assets
login/	Display manager theme, authentication screens, and user selection
desktop/	Desktop environment customization, panels, and window management
applications/	DeapX-specific applications source code and definitions
themes/	System-wide GTK, Qt, and application themes
packages/	Package definitions, build rules, and local repository
scripts/	Automation scripts for building, testing, and deployment
build/	Build system configurations, ISO profiles, and live-build scripts
iso/	Generated ISO images and checksums (artifacts)
testing/	Test suites, test automation, and quality assurance tools
future/lobby3d/	3D Lobby development, prototyping, and integration
releases/	Release metadata, release notes, and version archives
No additional top-level directories are permitted without Chief Architect approval.

16. Module Architecture
DeapX modules are organized by their layer of influence on the operating system:

Layer 1: Core System (Minimal Modification)

Linux kernel (unchanged from Debian)

systemd (unchanged)

APT (unchanged)

GNU coreutils (unchanged)

Bootloader (custom theme only from boot/)

Layer 2: System Services (Customized Configuration)

Display manager (custom theme from login/)

NetworkManager (DeapX defaults)

PulseAudio/PipeWire (optimized defaults)

Printing (CUPS with DeapX presets)

Security policies (AppArmor with DeapX profiles)

Layer 3: Desktop Environment (Complete Customization)

Window manager (DeapX theme and keybindings from desktop/)

Panel and desktop (DeapX layout and widgets from desktop/)

System settings (DeapX control panel from applications/control-center/)

File manager (DeapX bookmarks and custom actions)

Terminal emulator (DeapX color scheme from themes/)

Layer 4: Branding Assets (Original Artwork)

Boot themes (boot/)

Login screen themes (login/)

Desktop wallpapers (assets/wallpapers/)

Icon themes (assets/icons/)

Cursor themes (assets/cursors/)

Sound schemes (assets/sounds/)

Fonts (assets/fonts/)

Core branding (branding/)

Layer 5: DeapX-Specific Applications (Original Development)

Welcome wizard (applications/welcome/)

System configuration utility (applications/settings/)

Software updater (applications/updater/)

Control center (applications/control-center/)

Future 3D Lobby (future/lobby3d/)

This modular architecture ensures clean separation of concerns and simplifies rebasing on new Debian releases.

17. Security Philosophy
Security Principles

Defense in Depth – Multiple layers of security (AppArmor, firewalls, secure defaults)

Least Privilege – Services run with minimal required permissions

Transparency – All security patches are documented and verifiable

Debian First – Security fixes are first applied to Debian packages; DeapX only adds additional hardening where Debian is not opinionated

Out-of-the-Box Security

Uncomplicated Firewall (UFW) is enabled by default

AppArmor is in enforce mode for critical services

SSH server is not installed by default on desktop images

System updates are performed over HTTPS

GPG signatures are verified for all repository packages

Security Auditing

Regular vulnerability scanning (CVE tracking)

Compliance with Debian Security Tracker

Community reporting and responsible disclosure

Test builds run in sandboxed environments

18. Performance Goals
Measurable Targets (on Reference Hardware: Intel Core i5, 8GB RAM, SSD)

Boot time: ≤ 20 seconds from power-on to login screen

Login-to-desktop: ≤ 5 seconds after password entry

Application launch: ≤ 2 seconds for common apps (first launch, cold start)

Memory usage: ≤ 1.5 GB at idle (after fresh boot, no applications running)

CPU usage: ≤ 2% at idle (no background tasks)

Disk usage: ≤ 8 GB for minimal installation; ≤ 15 GB for full desktop

Optimization Strategy

Minimal systemd services enabled by default

Preload and readahead configured for SSD/HDD respectively

ZRAM or ZSWAP enabled for improved memory management

Kernel parameters optimized for desktop workloads

No background telemetry or data collection

Non-Functional Performance Requirements

The system must feel responsive during interactive use

No single task should block the user interface for more than 100ms

Package installation should not degrade system responsiveness

Memory consumption should scale gracefully with active applications

19. Development Workflow
Version Control

Git is the primary version control system

Repository is hosted on a public platform (self-hosted or trusted provider)

Branches: main (stable), develop (integration), feature/* (development)

Signed commits are encouraged for integrity

Development Stages

Feature Design – Specifications are drafted in docs/specifications/

Implementation – Code is developed in feature branches

Integration – Merged into develop for preliminary testing

Stabilization – Testing and bug fixing in release candidate branch

Release – Merged into main and tagged

Code Review Policy

All changes must be reviewed by at least one maintainer

Changes to packaging require review by a Debian policy expert

Security-sensitive changes require two approvals

Automatic checks (linting, build validation) run on all pull requests

Build Infrastructure

Continuous Integration (CI) builds every commit

Build artifacts are archived and available for testing

Separate build hosts for amd64 (primary) and arm64 (secondary)

20. Testing Workflow
Test Hierarchy

Unit Testing

Individual components tested in isolation

Automated tests run by CI on every commit

Tests are written in Python or Bash (depending on component)

Integration Testing

Full package installations in chroot or container environments

Validation of package dependencies and conflicts

System service tests (systemd unit files)

System Testing

Installation on physical and virtual hardware

Boot sequence validation (GRUB, kernel, init, display manager)

Desktop functionality testing (application launch, network, sound, printing)

Automated user flow tests (via X11 automation tools)

Acceptance Testing

Manual testing by quality assurance (QA) team

Performance benchmarking against performance goals

Security scanning (OpenSCAP, Lynis)

Upgrade testing (from previous releases)

Test Environments

QEMU virtual machines (various memory and CPU configurations)

Bare metal hardware (reference systems)

Cloud instances (Amazon EC2, DigitalOcean)

Bug Reporting

Issues tracked in Git issue tracker

Severity levels: Critical (blocker), Major, Minor, Enhancement

All issues triaged within 48 hours

21. Release Workflow
Release Preparation (T-4 weeks)

Feature freeze for new functionality

Development branch locked for changes

Release notes drafted in docs/releases/

Installation media (ISO) built and staged for testing from build/ and iso/

Release Candidates (T-3 weeks to T-1 week)

Candidate builds labelled deapx-X.Y-rcN

Public testing period (QA team and community testers)

Issues triaged for fix/delay

All critical issues resolved before final release

Final Release (T-0)

Git tag created (vX.Y.Z)

ISO images signed and checksums published from iso/

Release notes published on project website

Packages uploaded to stable repository

Announcement sent to mailing list and community channels

Post-Release (T+1 week)

Monitoring for critical issues

Point release planning for minor fixes

Feature planning for next release cycle begins

22. Version Naming Strategy
Version Format
MAJOR.MINOR.PATCH[-PRERELEASE]

MAJOR – Increments for significant updates, possible compatibility breaks, or desktop environment changes

MINOR – Increments for feature additions, component upgrades, or new hardware support

PATCH – Increments for bug fixes, security patches, and minor refinements

PRERELEASE – alpha, beta, rcN (e.g., 2.0.0-beta1)

Release Name
Each major release receives a code name matching the Debian release it is based on, preceded by "DeapX". For example:

DeapX Bookworm (based on Debian 12)

DeapX Trixie (based on Debian 13)

Versioning Policy

DeapX version numbers are independent of Debian version numbers

Version numbers are human-readable and increment predictably

All releases are tagged in Git with the version number

End-of-life (EOL) dates follow Debian's EOL schedule

23. Future Roadmap
Phase 1: Foundation (Release 1.0 - Q1 2027)

Complete repository initialization with official directory structure

Initial build system and CI pipeline

Basic Debian rebranding (boot, login, desktop)

Minimal desktop environment customizations

ISO build process validated

Phase 2: Branding & User Experience (Release 2.0 - Q1 2028)

Full visual identity (logo, color palette, typography) in branding/ and assets/

Comprehensive desktop environment theming in desktop/ and themes/

DeapX welcome application (applications/welcome/)

Default application suite (themed Firefox, Thunderbird, LibreOffice)

Sound scheme implementation (assets/sounds/)

Phase 3: Ecosystem (Release 3.0 - Q1 2030)

DeapX-specific applications (software center, system manager) in applications/

Community package repository contribution

Expanded documentation and tutorials

Localization and internationalization

Phase 4: 3D Lobby (Release 4.0 - 2032+)

3D Lobby integrated as the primary desktop environment (future/lobby3d/)

Wayland transition (if Debian adopts Wayland by default)

Alternative architecture support (RISC-V evaluation)

Full user migration path from traditional desktop

24. Project Rules
The following rules govern the DeapX development process and are binding on all team members:

Architecture Integrity

No top-level directories may be added beyond those specified in Section 15 without Chief Architect approval.

The directory structure must remain scalable and documented at all times.

Modifications to the base operating system must be minimal, patch-based, and re-verifiable.

Code and Content Quality

All commits must include a clear message explaining the "what" and "why" of the change.

Brand assets (logos, icons, wallpapers) must be original works or properly licensed.

No proprietary code may be included in the DeapX base repository.

Process Adherence

All features must have a corresponding specification document before implementation.

All releases must follow the release workflow defined in Section 21.

All security issues must be disclosed responsibly through the designated channel.

Community and Collaboration

The project maintains a code of conduct that all contributors must follow.

Decision-making is transparent and documented through public discussions.

Contributions are acknowledged and credited appropriately.

Compatibility

Binary compatibility with Debian Stable must be maintained at all times.

Packages should not replace or conflict with Debian-provided packages unless absolutely necessary.

Debian Policy and DFSG are the default compliance standards.

Long-Term Maintainability

Documentation must be updated alongside code changes.

Deprecated features are announced two releases in advance before removal.

All external dependencies must be documented with version requirements.