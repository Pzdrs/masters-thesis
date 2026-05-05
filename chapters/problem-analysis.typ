#import "../template/template.typ": *

As previously mentioned, the development process of a car generates a large amount of telemetry data that needs to be analyzed by engineers and technicians. The current workflow at our department for analyzing this data is inefficient and time-consuming, which motivates the need for a software solution that can streamline the process.

== Motivation

To illustrate the practical motivation behind telemetry analysis, consider a situation in which a vehicle exhibits undesirable behavior only under specific operating conditions, for example insufficient cabin heating during winter driving, unexpectedly high coolant temperature during a sustained uphill climb, or unstable behavior of a controlled component such as a radiator fan. In such cases, the problem usually cannot be diagnosed reliably from a single subjective observation alone. What matters is not only that the undesired behavior occurred, but also *when* it occurred, under what load, at what speed, at what ambient temperature, and in relation to which other measured variables.

This is precisely why test drives and measurement campaigns are an essential part of vehicle development. By recording telemetry data during controlled or repeatable conditions, engineers gain access to the technical context surrounding a problem. They can reconstruct the sequence of events, compare multiple runs, observe interactions between signals, and verify whether a suspected cause is actually supported by the measured data. Telemetry therefore serves not merely as an archival by-product of testing, but as a primary source of evidence for technical reasoning, validation, and decision-making.

At the same time, the usefulness of telemetry data depends heavily on how easily it can be explored after acquisition. Even a well-designed test loses value if the resulting measurements are difficult to compare, slow to visualize, or cumbersome to interpret. The motivation for this thesis therefore lies not only in the existence of measurement data, but in the need to transform that data into a form that supports efficient day-to-day analytical work. For that reason, the following sections first describe how the relevant data is collected and then examine the current workflow used for its analysis.

== Data collection

Because different conditions reveal different aspects of a car's performance, a single standardized test is not sufficient. Instead, cars must be tested across a spectrum of environments. These environments include, but are not limited to, public roads, test tracks, and wind tunnels. By adapting each test to a specific area of investigation, engineers can gain deeper insights into how a car behaves under particular conditions, which is crucial for optimizing its design and performance. A small selection of tests used in production is illustrated in @img:tests, taken from the internal configuration system, also developed by the author.

#figure(
  image("../assets/tests.png", width: 100%),
  caption: [A snippet of the predefined tests with various parameters.],
) <img:tests>

In general, vehicle telemetry data can be collected in two primary ways: through the integrated #abbr("OBD-II", "On-Board Diagnostics II") port @sae_j1962_201607, or by equipping the vehicle with a large number of additional sensors while simultaneously aggregating data from the car's internal systems.

=== OBD-II-Based Data Acquisition

The former method is significantly more straightforward and is commonly used for basic diagnostics and performance monitoring. The setup typically involves connecting a data-logging device, most often a laptop computer, to the vehicle's #abbr("OBD-II") port using a standard interface cable @sae_j1962_201607. The computer then runs software capable of communicating with the vehicle's onboard systems, allowing it to read and record various parameters from the car's #abbr("ECU", "Electronic Control Unit") @iso_15031_5_2015.

Any software capable of reading data from the aforementioned port can be used for this purpose, and many options are available, both open-source and commercial. At Škoda Auto, part of the Volkswagen Group, the software commonly used for this task is #abbr("ODIS", "Offboard Diagnostic Information System"), a Volkswagen Group diagnostic system (see @img:odis). It is licensed to authorized users and provides a comprehensive set of diagnostic functions for vehicle development and service use @dne_odis_engineering.

#figure(
  image("../assets/odis.png", width: 100%),
  caption: [
    ODIS Factory Diagnostic OEM Pro Package used in Škoda Auto. \
    Source: https://diagnoex.com/products/vw-audi-odis-scan-tool
  ],
) <img:odis>

The output is typically exported in CSV format, which can be easily imported into spreadsheet software or other data analysis tools for further processing. This method is trivial to set up and can provide a wide range of information about the vehicle's operation, including engine speed, coolant temperature, throttle position, and other parameters. However, due to limitations in available signals and sampling rates, it may not capture all the data required for more detailed or high-fidelity analysis.

=== Instrumented Vehicle Data Acquisition

The second method of data collection involves equipping the vehicle with a large number of additional sensors and aggregating data from the vehicle's internal systems using dedicated supporting hardware (similar to @img:etas-hardware). In practice, this means putting the vehicle up on a lift, disassembling parts of the engine bay, and installing various sensors to measure parameters that are not available through the OBD-II port. This can include additional temperature sensors, pressure sensors, accelerometers, and other specialized equipment depending on the specific requirements of the test. An example of such a setup is shown in @img:engine-bay, where various sensors are installed in the engine bay of a test vehicle. The data from these sensors, along with signals from the car's internal systems, is then aggregated using dedicated hardware, such as the ETAS data acquisition system (as shown in @img:etas-hardware-installed and @img:etas-hardware-installed-topview), which can handle high sampling rates and large volumes of data.

Compared to the first approach, this method is significantly more complex and costly, and the installation process typically requires approximately two days. However, it enables the collection of far more comprehensive and detailed telemetry data, which is essential for in-depth analysis and optimization of vehicle performance.

#figure(
  image("../assets/etas-hardware.png", width: 100%),
  caption: [
    ETAS Hardware for Data Acquisition \
    Source: https://www.etas.com/ww/en/products-services/data-acquisition-processing-tools
  ],
) <img:etas-hardware>

For example, the #abbr("ECU") often regulates certain components through feedback control loops rather than providing direct measurements. A typical case is the main radiator fan, whose operation is controlled using #abbr("PWM", "Pulse-Width Modulation") to adjust the cooling power dynamically. As a result, the fan speed does not directly correspond to the engine speed, and the actual fan rotational speed is not always available as a measured signal. In such cases, the fan speed may need to be estimated indirectly from related variables such as voltage, current, and #abbr("PWM") duty cycle. By installing an additional sensor that directly measures the fan's rotational speed, the system can provide a precise and readily usable measurement, which significantly simplifies subsequent analysis.

In this configuration, the logging device is typically a laptop computer running specialized third-party software designed for high-fidelity data acquisition (as illustrated in @img:cockpit). At Škoda Auto, the software commonly used for this purpose is #abbr("INCA", "Integrated Calibration and Acquisition System"), a commercial tool developed by ETAS GmbH. This software provides advanced capabilities for data acquisition, calibration, and analysis, making it well suited for the complex requirements of high-resolution telemetry data collection @etas_inca_products.

Compared to the OBD-II-based method, this approach generates significantly larger datasets, often containing measurements from thousands of sensors at different high sampling rates. A simple text-based format would be impractical for storing such large volumes of data, so a more sophisticated standardized format is used. The most common format for this type of data is the #abbr("MDF", "Measurement Data Format"), which is a binary file format designed specifically for storing large volumes of measurement data efficiently. The MDF format allows for the storage of complex datasets with multiple channels, varying sampling rates, and metadata, making it ideal for high-fidelity telemetry data @asam_mdf. The majority of technicians and engineers at Škoda Auto working with version 3 of the MDF format, but slow adoption of version 4 is expected in the near future.

Because this method has had so much time to mature, the software and hardware ecosystem around it is well developed, and the process of collecting and analyzing data is relatively streamlined. This leaves the first method slightly neglected, thus motivating the development of a software solution that focuses on improving the workflow for OBD-II-based data acquisition and analysis.

== Current workflow

It is no secret that large corporations across all industries prefer to use commercial software solutions for their operations, and the automotive industry is no exception. Microsoft is the dominant provider of office software, and many companies rely on it for almost all of their day to day operations from email, meetings, and document editing to data analysis and visualization.

Microsoft Excel is an excellent tool for many tasks and can be more than sufficient for for even complex data analysis. That it why it is so widely used in the industry, including at Škoda Auto, where it is the primary tool for analyzing telemetry data collected through the OBD-II port. The current workflow is as follows:

=== Data acquisition

Data is collected using ODIS and exported in CSV format. The CSV data is then imported into Excel using its built-in import functionality, which allows users to specify data types and delimiters. Once imported, the Excel spreadsheet with a structure similar to that shown in @img:excel-structure is saved to a shared network drive, making it accessible to other team members for further analysis and collaboration.

#figure(
  image("../assets/excel-structure.png", width: 100%),
  caption: [
    Structure of the Excel spreadsheet after importing the CSV data.
  ],
) <img:excel-structure>

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
