#import "template/template.typ": *

#profile("debug")

#show: tultemplate2.with(
  faculty: "fm",
  document: "dp",
  lang: "en",
  title: (
    cs: [Multiplatformní desktopová aplikace pro vizualizaci a analýzu telemetrických dat z testovacích jízd automobilů],
    en: [Multiplatform desktop application for visualization and analysis of telemetry data from car test drives],
  ),
  keywords: (
    cs: [DOPLŇTE, SEM, KLÍČOVÁ, SLOVA],
    en: [INSERT, KEYWORDS, HERE],
  ),
  acknowledgement: (
    en: [
      I would like to acknowledge everyone who contributed to the creation of this fine piece of work.
    ],
  ),
  abstract: (
    cs: [
      Sem vyplňte abstrakt své práce v češtině.
    ],
    en: [
      Insert the abstract of your theses in English here.
    ],
  ),
  title_pages: "title-pages.pdf",
  author: "Bc. Petr Boháč",
  supervisor: "Ing. Jan Kolaja, Ph.D.",
  citations: "citations.bib",
)

= Introduction

#include "chapters/introduction.typ"

= Problem analysis

#include "chapters/problem-analysis.typ"

= Designing the software architecture

#include "chapters/architecture.typ"

= Building the application

#include "chapters/implementation.typ"

= Deploying to production

#include "chapters/deployment.typ"

= Possibilities for improvement

rendering framework - figure management (we only do single figures rn)

= Conclusion

#include "chapters/conclusion.typ"

#attachments(
  attach_link("GitLab repository for the project", "https://gitlab.com/pycrs-epa/graph-insights"),
  attach_content("Instrumented engine bay", [
    #figure(
      image("assets/measuring-engine-bay.JPG", width: 120%),
      caption: [
        The engine bay of a test vehicle instrumented with additional sensors for data acquisition.
      ],
    ) <engine-bay>
  ]),
  attach_content("Instrumented cockpit", [
    #figure(
      image("assets/measuring-cockpit.JPG", width: 120%),
      caption: [
        State of the vehicle's cockpit during test drives.
      ],
    ) <cockpit>
  ]),
  attach_content("Installed ETAS hardware", [
    #figure(
      image("assets/measuring-etas-hardware.JPG", width: 120%),
      caption: [
        ETAS hardware installed in the backseat of a test vehicle for data aggregation.
      ],
    ) <etas-hardware-installed>
  ]),
  attach_content("Top-down view of ETAS hardware", [
    #figure(
      image("assets/measuring-etas-hardware-topview.JPG", width: 120%),
      caption: [
        Top-down view of the ETAS hardware installed in the backseat of a test vehicle for data aggregation.
      ],
    ) <etas-hardware-installed-topview>
  ]),
)
