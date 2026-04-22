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

= Possibilities for improvement <chapter:the-future>

rendering framework - figure management (we only do single figures rn)
#todo("do future expansion dat korelacni matici jako alternativu k tomu basic ahh seznamu")
#todo("stats anomalies - vic metod")

= Conclusion

#include "chapters/conclusion.typ"

#attachments(
  attach_link("GitLab repository for the project", "https://gitlab.com/pycrs-epa/graph-insights"),
  attach_content("Instrumented engine bay", [
    #rotate(-90deg, reflow: true)[
      #figure(
        image("assets/measuring-engine-bay.JPG", height: 105%),
        caption: [
          The engine bay of a test vehicle instrumented with additional sensors for data acquisition.
        ],
      ) <engine-bay>
    ]
  ]),
  attach_content("Instrumented cockpit", [
    #rotate(-90deg, reflow: true)[
      #figure(
        image("assets/measuring-cockpit.JPG", height: 105%),
        caption: [
          State of the vehicle's cockpit during test drives.
        ],
      ) <cockpit>
    ]
  ]),
  attach_content("Installed ETAS hardware", [
    #rotate(-90deg, reflow: true)[
      #figure(
        image("assets/measuring-etas-hardware.JPG", height: 105%),
        caption: [
          ETAS hardware installed in the backseat of a test vehicle for data aggregation.
        ],
      ) <etas-hardware-installed>
    ]
  ]),
  attach_content("Top-down view of ETAS hardware", [
    #rotate(-90deg, reflow: true)[
      #figure(
        image("assets/measuring-etas-hardware-topview.JPG", height: 105%),
        caption: [
          Top-down view of the ETAS hardware installed in the backseat of a test vehicle for data aggregation.
        ],
      ) <etas-hardware-installed-topview>
    ]
  ]),
  attach_content("Rendering system architecture", [
    #rotate(-90deg, reflow: true)[
      #figure(
        caption: [Architecture of the rendering system, showing the core components and their interactions.],
        image("assets/diagram/render-system/rendering-system.svg", width: 94%),
      ) <diagram:rendering-system-architecture>
    ]
  ]),
  attach_content("Miscellaneous", [
    For linguistic and research purposes, the use of #abbr("AI", "Artificial Intelligence") was leveraged throughout some parts of the thesis, more specifically the _GPT-5_.
  ]),
)
