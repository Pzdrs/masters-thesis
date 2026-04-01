#import "../template/template.typ": *

The topic of multiplatform desktop applications is a very deep one, and it is very easy to get caught up in the details of the various frameworks and technologies available for building such applications. That is why we need to establish some facts and the particular requirements of our application before we can start evaluating the options.

Pretty much all the computers used by non-IT professionals at Škoda Auto run Microsoft Windows, so we can safely assume that the target platform for our application is Windows. However, it is still desirable to have the option to run the application on other platforms such as Linux or macOS, which motivates the need for a cross-platform solution.

== Selecting the programming language

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

== Data ingestion

#todo("tohle je implementace ne architektura bruh")

When a user wants to add new data to the application, they can do so by selecting a file (or multiple files) from their file system using a file dialog. The application must then take these files and *asynchronously* load them in the background while keeping the user interface responsive. It must also inform the user about the progress of the loading process, so they are not left wondering if the application is frozen or if something went wrong. This is typically achieved by using a separate thread or process to handle the loading of data, while the main thread continues to run the user interface. The application can then use signals and slots (or other inter-thread communication mechanisms) to update the user interface with progress information and to notify the user when the loading process is complete.

I've chosen to go with a multithreaded pipeline approach for data ingestion. There are a number of distinct, ordered steps that need to be performed when loading a data file. Keeping all the logic for these steps in a single function would make it very difficult to read and maintin. It also makes it easier to unit test the individual steps of the loading process, as they can be tested in isolation from each other. The pipeline approach also allows for better error handling, as errors can be caught and handled at the appropriate stage of the loading process, rather than having to catch all errors in a single function. The complete list of stages in the data loading pipeline is shown in table @tab:data-loading-pipeline.

#figure(
  table(
    columns: 2,
    [*Stage*], [*Description*],
    [`read_from_excel`], [Uses `pandas.read_excel()` to read in an Excel file to memory as a `DataFrame`],
    [`extract_header_and_shift`], [Parses the metadata string from the first row and discards it],
    [`resolve_duplicate_columns`],
    [Looks for duplicate column names in the `DataFrame`, removing all potential occurrences and logging apppropriately],

    [`resolve_nameless_columns`],
    [Looks for columns without a name in the `DataFrame`, removing all potential occurrences and logging apppropriately],

    [`convert_dtypes`], [Tries to convert columns to a numeric type, dropping any columns that cannot be converted],
    [`reindex_to_timestamps`],
    [Reindexes the `DataFrame` from sequential integers to timestamps, using the `#Time` column as the source],

    [`drop_time_channel`], [Drops the time channel from the `DataFrame`, as it is no longer needed after reindexing],
    [`derive_channels`], [Uses a predefined set of rules to derive new channels from existing ones],
    [`normalize_column_names`], [Normalizes column names to a consistent format (case and whitespace)],
  ),
  caption: [Stages of the data loading pipeline (in order)],
) <tab:data-loading-pipeline>

When an Excel file is ran through the pipeline, the `pandas` package is used to load it into a `DataFrame` object, which is a powerful data structure for handling tabular data and is the primary data structure used in the application. The Excel files we are working with have a specific format, where the first row contains metadata while the actual data starts from the second row. As per the example in @misc:metadata-string, the metadata contains the exact date and time when the record button was pressed, the internal identifier of the particular vehicle, and then an arbitrary number of space separated strings.

#figure(
  ```
  #2025-02-17 12:38:35 TMBNH9NY0SF000226 trasa MB-LIB-MB
  ```,
  caption: [Example of the metadata string in the first row of the Excel files],
) <misc:metadata-string>

Following metadata extraction, the pipeline filters out possible duplicate and nameless columns, as these are not expected in the data and are likely to cause issues later on. The next stage is to try to convert all columns to a numeric type, as this is the expected format for the data and it allows for more efficient storage and processing. Any columns that cannot be converted to a numeric type are dropped from the `DataFrame`, as they are not useful for our purposes. The logic behind this stage is depicted in @diagram:convert-dtypes.

#figure(
  image(
    "../assets/diagram/dataframe-column-conversion.svg",
    width: 60%,
  ),
  caption: [Logic behing the `convert_dtypes` stage of the data loading pipeline],
) <diagram:convert-dtypes>

The next stage is to reindex the `DataFrame` from sequential integers to timestamps, using the `#Time` column as the source. This allows us to easily perform time-based operations on the data, such as resampling or rolling window calculations. After reindexing, the time channel is dropped from the `DataFrame`, as it is no longer needed. The next stage is to derive new channels from existing ones using a set of rules defined in `processing/derived_channels.py`. Most commonly these include power calculation from voltage and current channels. Finally, the column names are stripped of whitespace and normalized to a consistent case (lowercase) to avoid issues with inconsistent naming conventions in the source data#footnote("Change in column names is a frequent occurrence when switching between different versions of data recording software.").

== User workflow

The concept behind the application's main purpose is not complicated - it takes in data, the user decides what exactly and how they want to display it, and the application generates a visualization based on those choices. The main workflow should therefore be very simple and intuitive to actually perform its intended purpose - to save time for engineers and technicians. The general workflow is depicted in @img:user-workflow.

#figure(
  image(
    "../assets/diagram/user-workflow.svg",
  ),
  caption: [General visualization workflow],
) <img:user-workflow>

#todo("idk jestli tohole neposlat jinam")
