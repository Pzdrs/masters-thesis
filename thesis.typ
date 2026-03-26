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

In general, vehicle telemetry data can be collected in two primary ways: through the integrated #abbr("OBD-II", "On-Board Diagnostics II") port @sae_j1962_201607, or by equipping the vehicle with a large number of additional sensors while simultaneously aggregating data from the car's internal systems.

=== OBD-II-Based Data Acquisition

The former method is significantly more straightforward and is commonly used for basic diagnostics and performance monitoring. The setup typically involves connecting a data-logging device, most often a laptop computer, to the vehicle's #abbr("OBD-II") port using a standard interface cable @sae_j1962_201607. The computer then runs software capable of communicating with the vehicle's onboard systems, allowing it to read and record various parameters from the car's #abbr("ECU", "Electronic Control Unit") @iso_15031_5_2015.

Any software capable of reading data from the aforementioned port can be used for this purpose, and many options are available, both open-source and commercial. At Škoda Auto, part of the Volkswagen Group, the software commonly used for this task is #abbr("ODIS", "Offboard Diagnostic Information System"), a Volkswagen Group diagnostic system (see @odis). It is licensed to authorized users and provides a comprehensive set of diagnostic functions for vehicle development and service use @dne_odis_engineering.

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

In this configuration, the logging device is typically a laptop computer running specialized third-party software designed for high-fidelity data acquisition. At Škoda Auto, the software commonly used for this purpose is #abbr("INCA", "Integrated Calibration and Acquisition System"), a commercial tool developed by ETAS GmbH. This software provides advanced capabilities for data acquisition, calibration, and analysis, making it well suited for the complex requirements of high-resolution telemetry data collection @etas_inca_products.

Compared to the OBD-II-based method, this approach generates significantly larger datasets, often containing measurements from thousands of sensors at different high sampling rates. A simple text-based format would be impractical for storing such large volumes of data, so a more sophisticated standardized format is used. The most common format for this type of data is the #abbr("MDF", "Measurement Data Format"), which is a binary file format designed specifically for storing large volumes of measurement data efficiently. The MDF format allows for the storage of complex datasets with multiple channels, varying sampling rates, and metadata, making it ideal for high-fidelity telemetry data @asam_mdf. The majority of technicians and engineers at Škoda Auto working with version 3 of the MDF format, but slow adoption of version 4 is expected in the near future.

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

== Existing Solutions

Before developing a custom tool, it is necessary to examine existing solutions for vehicle telemetry acquisition and analysis. These solutions range from professional automotive engineering tools used by manufacturers to more general-purpose diagnostic or telemetry platforms. While many of these tools provide powerful capabilities, they often target different use cases or impose limitations that make them unsuitable for the workflow described in this work.

=== Professional Automotive Engineering Tools

In the automotive industry, several specialized software platforms exist for high-fidelity data acquisition, calibration, and analysis. These tools are primarily designed for original equipment manufacturers (OEMs) and their suppliers.

One widely used solution is CANoe, developed by Vector Informatik. The software is used for the development, analysis, and testing of electronic control units and distributed networks @asam_canoe.

Another related tool from the same company is CANape, which focuses on measurement and calibration of ECU parameters during runtime. During measurement, engineers can adjust parameters while recording signals, with communication commonly handled via protocols such as XCP @asam_canape.

These tools provide extremely powerful capabilities but are typically expensive, require specialized hardware, and are primarily designed for ECU development rather than lightweight analysis of diagnostic telemetry data.

=== Diagnostic and OBD-Based Tools

Another category consists of tools designed for vehicle diagnostics using the OBD-II interface.

A well-known example is VCDS, developed by Ross-Tech. It is a diagnostic system for Volkswagen Group vehicles (VW, Audi, Škoda, and SEAT) @ross_tech_vcds_lite.

Although such tools allow access to a wide range of vehicle parameters, their primary purpose is vehicle diagnostics rather than large-scale telemetry analysis. Data export and advanced analytical capabilities are typically limited compared to dedicated analysis platforms.

Some modern solutions attempt to extend OBD-based data analysis into broader telemetry applications. For example, platforms such as OBDAssistant provide real-time monitoring with hundreds of live parameters and AI-assisted interpretation of diagnostic information @obdassistant. However, they are primarily targeted at consumer diagnostics and fleet monitoring rather than engineering analysis workflows.

=== Telemetry and Data Analysis Platforms

Several solutions exist that focus on telemetry visualization and analysis rather than diagnostics.

For instance, the AutoPi platform provides hardware and software solutions for collecting data from CAN, CAN-FD, and OBD-II networks and transmitting it to cloud infrastructure for fleet monitoring and analytics @autopi.

Similarly, specialized telemetry analysis portals are used in industrial contexts to store and evaluate machine data over long periods, allowing users to perform queries, generate reports, and define operational thresholds. These systems often integrate data from multiple hardware platforms and provide web-based dashboards for long-term analysis.

Another example is asammdf, an open-source tool and Python library designed for working with measurement data stored in the #abbr("MDF") format. It provides functionality for reading, writing, and processing MDF files and includes a graphical user interface for browsing signals, plotting telemetry data, and exporting measurements to other formats @asam_mdf_python. Because MDF is widely used in automotive testing environments, asammdf has become a popular tool for engineers and researchers working with recorded measurement datasets. In recent years, the tool has also started to see practical adoption within Škoda Auto, where it is gradually being used by engineers as an auxiliary tool for working with measurement data. However, it primarily focuses on processing MDF files rather than simplifying workflows built around CSV-based diagnostic data.

=== Conclusion on Existing Solutions

Although the tools described above provide powerful capabilities, several limitations remain with respect to the workflow discussed in this work. Many professional engineering solutions require expensive licenses and specialized hardware. Dispite the fact large corporations may have access to such resources, including Škoda Auto, scope of the user base the results of this thesis is intended for is limited to a single department, and the cost of deploying such tools across the entire user base would be prohibitive.

In addition, most existing tools are designed primarily for ECU development, fleet monitoring, or vehicle diagnostics rather than for the post-processing and comparative analysis of telemetry data exported from OBD-II systems. As a result, working with multiple test runs often requires manual processing across several files, typically using external tools such as spreadsheet software.

Furthermore, many professional platforms rely on proprietary data formats or tightly integrated ecosystems, which complicates the use of simple CSV-based datasets commonly produced during diagnostic measurements. These limitations motivate the development of a lightweight analysis tool specifically tailored to OBD-II telemetry data, with the goal of improving the efficiency and usability of the current workflow.

= Building the application

TThe topic of multiplatform desktop applications is a very deep one, and it is very easy to get caught up in the details of the various frameworks and technologies available for building such applications. That is why we need to establish some facts and the particular requirements of our application before we can start evaluating the options.

Pretty much all the computers used by non-IT professionals at Škoda Auto run Microsoft Windows, so we can safely assume that the target platform for our application is Windows. However, it is still desirable to have the option to run the application on other platforms such as Linux or macOS, which motivates the need for a cross-platform solution.

== Selecting the programming language

// tabulku na comparison of languages

As for the programming language and its ecosystem, making the right choice is crucial for the success of the project in the long term, as it decreases the risk of running into insurmountable technical issues during development and maintenance. There are realistically two main approaches: native development using platform-specific tools and languages, or using a cross-platform framework that abstracts away platform-specific details and allows us to write code once and run it on multiple platforms.

Native applications, often written in languages such as C++ or C\#, tend to have better performance and can take full advantage of platform-specific features. In particular, C++ is widely used for high-performance desktop applications and offers fine-grained control over system resources, which could make the application more efficient and snappier from a user perspective. However, native development typically requires separate codebases for each platform, which can be costly and time-consuming to develop and maintain.

On the other hand, cross-platform frameworks allow us to write a single codebase that can run on multiple platforms, which can significantly reduce development time and costs. One popular approach is using JavaScript-based frameworks such as Electron, which enables developers to build desktop applications using web technologies like HTML, CSS, and JavaScript @electron_docs. While Electron simplifies cross-platform development and has a large ecosystem, it is often associated with higher memory usage and performance overhead compared to native solutions.

The main technical requirements for this project were rapid prototyping, ease of development, and maintainability for the author and possibly other developers in the future. C\# with the .NET framework is a popular choice for Windows development, but its cross-platform capabilities, while improving, may still introduce limitations depending on the use case. Java is another option that is inherently cross-platform and has a large ecosystem, but it may be unnecessarily complex for a relatively simple desktop application.

Python, on the other hand, is a versatile language with a large ecosystem of libraries and frameworks for building desktop applications, and it has good support for cross-platform development. It is also widely used for data analysis and visualization, which makes it particularly suitable for applications that require such functionality @mckinney_python_2013 @noauthor_matplotlib_nodate.

There are a lot of factors that influenced the choice of Python for this project (as summarized in table @language-comparison), but the most important ones were the author's familiarity with the language and its ecosystem, as well as the fact that it is a great language for rapid prototyping and development. The ease of development and maintainability were also important considerations, as the application is intended to be used by engineers and technicians who may not have extensive programming experience. Python's simplicity and readability make it an excellent choice for this purpose, as it allows developers to quickly understand and modify the codebase as needed.

#figure(
  table(
    columns: 3,
    [*Language*], [*Pros*], [*Cons*],
    [C++],
    [
      - High performance
      - Fine-grained control over system resources
      - Widely used for high-performance desktop applications
    ],
    [
      - Requires separate codebases for each platform
      - Longer development time
      - Steeper learning curve for non-C++ developers
    ],

    [C\# with .NET],
    [
      - Good performance
      - Strong support for Windows development
      - Improving cross-platform capabilities
    ],
    [
      - May still have limitations on non-Windows platforms
      - Potential overhead from the .NET runtime
    ],

    [Java],
    [
      - Inherently cross-platform
      - Large ecosystem
      - Good performance
    ],
    [
      - May be unnecessarily complex for simple applications
      - Higher memory usage compared to native solutions
    ],

    [Python],
    [
      - Versatile language with a large ecosystem of libraries and frameworks for desktop applications and data analysis
      - Good support for cross-platform development
    ],
    [
      - Generally slower than compiled languages like C++ or Java
      - May require additional tools for packaging and distribution
    ],
  ),
  caption: [Comparison of programming languages for desktop application development],
) <language-comparison>

== Desktop application frameworks

Software frameworks provide a structured way to build applications by offering pre-built components and tools that handle common tasks, such as user interface design, event handling, and data management. For desktop applications, there are several popular frameworks available for Python, including PyQt, Tkinter and Kivy.

Python is quite often used for building tools with simple graphical user interfaces using lightweight frameworks such as Pygame or the aforementioned Tkinter. Frameworks like these are easy to learn and can be sufficient for basic applications, but they may not provide the level of polish and user experience expected in a professional setting. For a more modern and responsive user interface, frameworks like PyQt or Kivy are often preferred. PyQt is a set of Python bindings for the Qt application framework, which is widely used for developing cross-platform applications with native look and feel. Kivy, on the other hand, is an open-source Python library for developing multitouch applications, which can also be used for desktop applications. Both frameworks have their own strengths and weaknesses, so the choice between them came down to personal preference of the author.

PyQt has a slightly steeper learning curve and can be more complex to set up, but it offers a more traditional desktop application experience with a wide range of widgets and tools for building complex user interfaces. One particularly powerful feature of PyQt is its ```python QSettings``` system, which provides a convenient platform-independant way to store and retrieve application settings across sessions. For example, on Windows, settings are typically stored in the registry, while on Linux they are stored in configuration files. By using QSettings' simple API (as shown in @qsettings-example), developers can abstract away these platform-specific details and ensure that user preferences and application state are preserved seamlessly across different operating systems.

#figure(
  caption: [Example of the QSettings API],
  [
    ```python
      settings = QSettings()

      # Set a value
      settings.setValue("username", "JohnDoe")

      # Get a value
      username = settings.value("username", "defaultUser")
    ```
  ],
) <qsettings-example>

The Qt framework (and consequently the PyQt library) has more than 25 years of development and a large community, which means that it is well-documented and has a wide range of resources available for learning and troubleshooting. It has a robust layout system that allows developers to create complex and responsive user interfaces that adapt to different screen sizes and resolutions. Additionally, PyQt provides a wide range of widgets and tools for building modern desktop applications, which will be touched upon in the next section @qt_software. All of these factors contributed to the decision to use PyQt for this project, as it provides a powerful and flexible framework for building a professional-quality desktop application with a modern user interface.

== Development environment

Development environment refers to the tools and software used by developers to write, test, and debug their code. A good development environment can significantly improve productivity and make the development process more efficient. For this project, the development environment consisted of a combination of an #abbr("IDE", "Integrated Development Environment") and various tools for version control, testing, and documentation.

The primary IDE of choice for this project was PyCharm, a popular Python IDE developed by JetBrains. PyCharm offers a wide range of features that enhance the development experience, including intelligent code completion, code navigation, and integrated debugging tools. A heavier IDE like PyCharm was chosen over lighter code editors such as Visual Studio Code or Sublime Text because of its robust support for Python and its powerful features that can help manage a larger codebase more effectively.

For the environment itself, the Nix package manager was used to create a reproducible development environment. Nix allows developers to define their development environment in a declarative way, specifying the exact versions of tools and libraries needed for the project. This ensures that all developers working on the project have a consistent environment, which can help avoid issues related to dependency conflicts or differences in tool versions while keeping everything isolated from the system environment @how_nix_works. The specific configuration used for this project is shown in @nix-dev-env, which includes Python 3.11 and the necessary packages for development. Direnv was also used to automatically load the Nix environment when entering the project directory, further streamlining the development workflow @direnv.

// TODO: reference the designer alias in the shell hook when we talk about the UI design process
#figure(
  caption: [Nix development environment configuration],
  [
    ```nix
    {
      inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

      outputs =
        { nixpkgs, ... }:
        let
          system = "aarch64-darwin";
          pkgs = import nixpkgs { inherit system; };
        in
        {
          devShells.${system}.default = pkgs.mkShell {
            packages = with pkgs; [
              python311
              uv
            ];

            shellHook = ''
              if [ -f .venv/bin/activate ]; then
                source .venv/bin/activate
              else
                uv venv && uv sync && source .venv/bin/activate
              fi

              alias designer="pyqt6-tools designer &> /dev/null"
            '';
          };
        };
    }
    ```
  ],
) <nix-dev-env>

As the Nix configuration above shows, the package manager of choice for managing Python dependencies was uv, a modern Python package manager written in Rust that provides a fast and efficient way to manage Python packages and virtual environments @uv_docs. It was chosen over more traditional tools like pip and virtualenv because of its speed, ease of use, and built-in support for dependency resolution and virtual environment management. The pyproject.toml file used by the project is shown in @pyproject-toml, which specifies the project metadata and dependencies.

#figure(
  caption: [The pyproject.toml file used by the project],
  [
    ```toml
    [project]
    name = "graph-insights"
    version = "1.10.0"
    description = "Inspection tool for ODIS-exported Excel tabular data"
    readme = "README.md"
    requires-python = ">=3.11"
    dependencies = [
      ...
    ]
    ```
  ],
) <pyproject-toml>

Finally, Git was used for version control, more so for the sake of good practice and maintaining a history of changes rather than for collaboration, as the project was developed solely by the author. Git allows developers to track changes to their code, revert to previous versions if needed, and manage different branches of development. When working on a new feature or a large refactor, branching allows developers to isolate their changes from the main codebase until they are ready to be merged, which can help prevent conflicts, maintain a cleaner commit history, and allows the developer to work on multiple features or bug fixes simultaneously without interference @git. For this project, a simple branching strategy was used, with a main branch for stable code and feature branches for new development. Regular commits were made to the feature branches, and once a feature was complete and tested, it was merged back into the main branch using the rebase strategy to maintain a clean commit history. The source code for the project was put up on a self-hosted GitLab instance, which provided a private repository for the project and allowed for easy access and management of the codebase.


== Application architecture

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

unit tests
pytest, coverage
user testing - feedback from users, iterative development

== User documentation

zensical local docs
local web server - pros and cons

== Packaging

pyinstaller, nuitka, brief comparison
package skripty

= Possibilities for improvement

rendering framework - figure management (we only do single figures rn)

= Conclusion

#include "chapters/conclusion.typ"
