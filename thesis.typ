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

= Existing solutions

= Problem analysis

= Building the application

frameworks - tkinter vs pyqt (notable mentions for pygame)

== Visualization

render framework selfbuilt
renderer - layout strategy - backend - matplotlib backend

== Analysis

classic statistical methods
machine learning methods
supervised vs unsupervised - unsupervised needs to be monitored - we do monitor it so its the way to go

ODIS vs INCA (excel vs dat)

= Deploying to production

== Testing

== User documentation

probably mkdocs on local server running under the desktop app

== Packaging

pyinstaller, nuitka, brief comparison

= Possibilities for improvement

rendering framework - figure management (we only do single figures rn)

= Conclusion

#include "chapters/conclusion.typ"