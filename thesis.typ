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
    cs: [telemetrická data, testovací jízdy automobilů, desktopová aplikace, vizualizace dat, detekce anomálií, Python, PyQt],
    en: [telemetry data, automotive test drives, desktop application, data visualization, anomaly detection, Python, PyQt],
  ),
  acknowledgement: (
    en: [
      I would like to acknowledge everyone who contributed to the creation of this fine piece of work.
    ],
  ),
  abstract: (
    cs: [
      Tato diplomová práce se zabývá následným zpracováním telemetrických dat z testovacích jízd automobilů ve společnosti Škoda Auto. Cílem bylo analyzovat současný pracovní postup inženýrů a techniků, zhodnotit existující softwarová řešení a navrhnout a implementovat multiplatformní desktopovou aplikaci, která zjednoduší vizualizaci a analýzu exportovaných měřicích dat. Analytická část identifikuje hlavní slabiny stávajícího workflow, zejména opakované ruční zpracování CSV exportů, obtížné porovnávání více měření a absenci lehkého nástroje přizpůsobeného každodennímu inženýrskému použití. Na základě průzkumu existujících nástrojů byla navržena specializovaná aplikace využívající jazyk Python a UI framework PyQt. Implementované řešení podporuje načítání a předzpracování dat exportovaných z ODIS, normalizaci kanálů, práci s více datovými sadami, flexibilní vykreslování grafů, deskriptivní statistiku, vizualizaci rozdílových křivek, korelační analýzu, detekci anomálií založenou na směrodatné odchylce a rozšíření o metody strojového učení bez učitele. Práce se dále věnuje testování, dokumentaci, verzování a zabalení aplikace pro nasazení v restriktivním podnikovém prostředí. Výsledkem je funkční softwarový nástroj, který urychluje rutinní analýzu dat z testovacích jízd a vytváří základ pro další rozšiřování funkcionality.
    ],
    en: [
      This thesis deals with the post-processing of telemetry data from automotive test drives at Skoda Auto. The goal was to analyze the current workflow of engineers and technicians, evaluate existing software solutions, and design and implement a multiplatform desktop application that simplifies the visualization and analysis of exported measurement data. The analytical part identifies the main weaknesses of the existing workflow, especially repetitive manual processing of CSV exports, difficult comparison of multiple measurements, and the absence of a lightweight tool adapted to everyday engineering use. Based on the survey of existing tools, a dedicated application using Python and PyQt for UI was proposed. The implemented solution supports loading and preprocessing ODIS-exported data, normalization of channels, work with multiple datasets, flexible plotting, descriptive statistics, delta-curve visualization, correlation analysis, standard deviation-based anomaly detection, and an unsupervised machine-learning extension. The thesis also covers testing, documentation, versioning, and packaging of the application for deployment in a restrictive corporate environment. The result is a working software tool that accelerates the routine analysis of test-drive data and provides a foundation for future functional expansion.
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

#include "chapters/improvements.typ"

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
      ) <img:engine-bay>
    ]
  ]),
  attach_content("Instrumented cockpit", [
    #rotate(-90deg, reflow: true)[
      #figure(
        image("assets/measuring-cockpit.JPG", height: 105%),
        caption: [
          State of the vehicle's cockpit during test drives.
        ],
      ) <img:cockpit>
    ]
  ]),
  attach_content("Installed ETAS hardware", [
    #rotate(-90deg, reflow: true)[
      #figure(
        image("assets/measuring-etas-hardware.JPG", height: 105%),
        caption: [
          ETAS hardware installed in the backseat of a test vehicle for data aggregation.
        ],
      ) <img:etas-hardware-installed>
    ]
  ]),
  attach_content("Top-down view of ETAS hardware", [
    #rotate(-90deg, reflow: true)[
      #figure(
        image("assets/measuring-etas-hardware-topview.JPG", height: 105%),
        caption: [
          Top-down view of the ETAS hardware installed in the backseat of a test vehicle for data aggregation.
        ],
      ) <img:etas-hardware-installed-topview>
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
