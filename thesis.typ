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

As previously mentioned, the development process of a car generates a large amount of telemetry data that needs to be analyzed by engineers and technicians. The current workflow for analyzing this data is inefficient and time-consuming, which motivates the need for a software solution that can streamline the process.

== Motivation

// vytahni si z prdele nejakej scenario - the WHY DATA portion
Let's consider the following hypothetical scenario: blah blah tohle nefunguje tak udelame test, ten nam nameri tyhle senzory a znich pozname co zpusobuje ten problem, mrd there u go proto delame testy

== Data collection

// HOW data portion
Because different conditions reveal different aspects of a car's performance, a single standardized test is not sufficient. Instead, cars must be tested across a spectrum of environments. These environments include, but are not limited to, public roads, test tracks, and wind tunnels. By adapting each test to a specific area of investigation, engineers can gain deeper insights into how a car behaves under particular conditions, which is crucial for optimizing its design and performance. A small selection of tests used in production is illustrated in @tests, taken from the internal configuration system, also developed by the author.

#figure(
  image("assets/tests.png", width: 100%),
  caption: [A snippet of the predefined tests with various parameters.],
) <tests>

In general, vehicle telemetry data can be collected in two primary ways: through the integrated #abbr("OBD-II", "On-Board Diagnostics II") port, or by equipping the vehicle with a large number of additional sensors while simultaneously aggregating data from the car's internal systems.

=== OBD-II-Based Data Acquisition

The former method is significantly more straightforward and is commonly used for basic diagnostics and performance monitoring. The setup typically involves connecting a data-logging device, most often a laptop computer, to the vehicle's #abbr("OBD-II") port using a standard interface cable. The computer then runs software capable of communicating with the vehicle's onboard systems, allowing it to read and record various parameters from the car's #abbr("ECU", "Electronic Control Unit").

Any software capable of reading data from the aforementioned port can be used for this purpose, and many options are available, both open-source and commercial. At Škoda Auto, part of the Volkswagen Group, the software commonly used for this task is #abbr("ODIS", "Offboard Diagnostic Information System"), a proprietary diagnostic tool developed internally (see @odis). It is licensed to authorized users and provides a comprehensive set of features for diagnosing and analyzing vehicle performance.

#figure(
  image("assets/odis.png", width: 100%),
  caption: [
    ODIS Factory Diagnostic OEM Pro Package used in Škoda Auto. \
    Source: https://diagnoex.com/products/vw-audi-odis-scan-tool
  ],
) <odis>

The output is typically exported in CSV format, which can be easily imported into spreadsheet software or other data analysis tools for further processing. This method is trivial to set up and can provide a wide range of information about the vehicle's operation, including engine speed, coolant temperature, throttle position, and other parameters. However, due to limitations in available signals and sampling rates, it may not capture all the data required for more detailed or high-fidelity analysis.

=== Instrumented Vehicle Data Acquisition

The second method of data collection involves equipping the vehicle with a large number of additional sensors and aggregating data from the vehicle's internal systems using dedicated supporting hardware (similar to @etas-hardware). Compared to the first approach, this method is significantly more complex and costly, and the installation process typically requires approximately two days. However, it enables the collection of far more comprehensive and detailed telemetry data, which is essential for in-depth analysis and optimization of vehicle performance.

#figure(
  image("assets/etas-hardware.png", width: 100%),
  caption: [
    ETAS Hardware for Data Acquisition \
    Source: https://www.etas.com/ww/en/products-services/data-acquisition-processing-tools
  ],
) <etas-hardware>

For example, the #abbr("ECU") often regulates certain components through feedback control loops rather than providing direct measurements. A typical case is the main radiator fan, whose operation is controlled using #abbr("PWM", "Pulse-Width Modulation") to adjust the cooling power dynamically. As a result, the fan speed does not directly correspond to the engine speed, and the actual fan rotational speed is not always available as a measured signal. In such cases, the fan speed may need to be estimated indirectly from related variables such as voltage, current, and #abbr("PWM") duty cycle. By installing an additional sensor that directly measures the fan's rotational speed, the system can provide a precise and readily usable measurement, which significantly simplifies subsequent analysis #footnote[A photograph of the instrumented engine bay cannot be published due to confidentiality restrictions. During measurements, vehicles are equipped with numerous additional sensors and data acquisition cables, producing a dense instrumentation layout that differs substantially from the standard vehicle configuration.
].

In this configuration, the logging device is typically a laptop computer running specialized third-party software designed for high-fidelity data acquisition. At Škoda Auto, the software commonly used for this purpose is #abbr("INCA", "Integrated Calibration and Acquisition System"), a commercial tool developed by ETAS GmbH. This software provides advanced capabilities for data acquisition, calibration, and analysis, making it well suited for the complex requirements of high-resolution telemetry data collection.

Compared to the OBD-II-based method, this approach generates significantly larger datasets, often containing measurements from thousands of sensors at different high sampling rates. A simple text-based format would be impractical for storing such large volumes of data, so a more sophisticated standardized format is used. The most common format for this type of data is the #abbr("MDF", "Measurement Data Format"), which is a binary file format designed specifically for storing large volumes of measurement data efficiently. The MDF format allows for the storage of complex datasets with multiple channels, varying sampling rates, and metadata, making it ideal for high-fidelity telemetry data. The majority of technicians and engineers at Škoda Auto working with version 3 of the MDF format, but slow adoption of version 4 is expected in the near future.

Because this method has had so much time to mature, the software and hardware ecosystem around it is well developed, and the process of collecting and analyzing data is relatively streamlined. This leaves the first method slightly neglected, thus motivating the development of a software solution that focuses on improving the workflow for OBD-II-based data acquisition and analysis.

== Current workflow

It is no secret that large corporations across all industries prefer to use commercial software solutions for their operations, and the automotive industry is no exception. Microsoft is the dominant provider of office software, and many companies rely on it for almost all of their day to day operations from email, meetings, and document editing to data analysis and visualization. 

Microsoft Excel is an excellent tool for many tasks and can be more than sufficient for for even complex data analysis. That it why it is so widely used in the industry, including at Škoda Auto, where it is the primary tool for analyzing telemetry data collected through the OBD-II port. The current workflow is as follows:

=== Data acquisition

Data is collected using ODIS and exported in CSV format. The CSV data is then imported into Excel using its built-in import functionality, which allows users to specify data types and delimiters. Once imported, the Excel spreadsheet with a structure similar to that shown in @excel-structure is saved to a shared network drive, making it accessible to other team members for further analysis and collaboration.

#figure(
  image("assets/excel-structure.png", width: 100%),
  caption: [
    Structure of the Excel spreadsheet after importing the CSV data. 
  ],
) <excel-structure>

=== Data analysis

Engineers and technicians use Excel's functions, formulas, and pivot tables to analyze the data. This analysis may include calculating summary statistics, creating charts and graphs, and performing basic data manipulation on a single file. When multiple test runs need to be compared, engineers must manually open several spreadsheets and compare the data side by side. This process can become cumbersome and error-prone as the number of files increases, especially on the corporate-issued laptops, which often have limited processing power, memory and a small screen size.

It is this second part of the workflow that is particularly inefficient and time-consuming, which motivates the effort to find a better solution.

== Exisiting solutions

Before proceeding with the development of a custom solution, an analysis of existing solutions should be conducted. This analysis should include both open-source and commercial products, as well as systems that may not be explicitly designed for the intended use case but could be adapted to fulfill the required objectives.

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
