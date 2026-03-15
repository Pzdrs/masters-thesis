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

excel

== Exisiting solutions

Before proceeding with the development of a custom solution, an analysis of existing solutions should be conducted. This analysis should include both open-source and commercial products, as well as systems that may not be explicitly designed for the intended use case but could be adapted to fulfill the required objectives.



The telemetry collected during vehicle testing represents a significant source of information for engineers working on vehicle development. However, the usefulness of this data strongly depends on how efficiently it can be processed, analyzed, and interpreted. Based on preliminary observations of the current workflow, several challenges can be identified that make the analysis process time-consuming and inefficient.

One of the main issues is the large volume of collected data. Each test drive generates datasets containing measurements from dozens or even hundreds of sensors. These may include parameters such as temperature, pressure, airflow, engine load, and vehicle speed. Since tests are often repeated multiple times under slightly different conditions, the resulting datasets quickly grow to a size that is difficult to handle manually. Engineers are therefore required to spend a considerable amount of time filtering relevant information from raw telemetry.

Another challenge lies in the fragmentation of the tools used for analysis. In many cases, different parts of the analysis workflow rely on separate software tools. For example, raw data may first be exported from the vehicle's data logging system, then processed in spreadsheet software or specialized engineering tools, and finally visualized using another application. Switching between multiple tools introduces inefficiencies, increases the likelihood of human error, and complicates collaboration between team members.

The lack of automation in repetitive tasks is also a significant pain point. Many steps in the workflow, such as cleaning datasets, aligning measurements from different sensors, or generating standard graphs for reporting, are performed manually. While these tasks are relatively straightforward, performing them repeatedly for every test drive consumes valuable engineering time that could otherwise be spent interpreting results or improving vehicle design.

Another important issue is the difficulty of comparing multiple test runs. Engineers often need to evaluate how a vehicle behaves under slightly different environmental conditions or after modifications to specific components. However, comparing datasets from different tests can be cumbersome when data is stored in separate files or processed using inconsistent methods. Without a standardized analysis pipeline, drawing reliable conclusions becomes more challenging.

Additionally, data organization and accessibility can present problems. Test data may be stored across various folders, servers, or personal workstations, making it difficult for team members to locate the exact dataset they need. This lack of centralized storage can also lead to version control issues, where multiple copies of the same dataset exist with slight differences.

Finally, the current workflow may offer limited support for visualization and interactive analysis. While static graphs can provide useful insights, engineers often benefit from interactive tools that allow them to quickly explore telemetry data, zoom into specific sections of a test run, or overlay multiple parameters in real time. Without such capabilities, identifying patterns or anomalies in the data can be significantly slower.

Addressing these challenges will be essential in designing an effective software solution. By improving automation, integrating analysis tools, and providing better visualization and data management capabilities, it should be possible to significantly streamline the telemetry analysis workflow. The next step in the project will therefore be to identify the specific requirements that such a system must fulfill in order to support engineers and technicians in their daily work.

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
