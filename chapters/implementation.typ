#import "../template/template.typ": *

== Development environment

Development environment refers to the tools and software used by developers to write, test, and debug their code. A good development environment can significantly improve productivity and make the development process more efficient. For this project, the development environment consisted of a combination of an #abbr("IDE", "Integrated Development Environment") and various tools for version control, testing, and documentation.

The primary IDE of choice for this project was PyCharm, a popular Python IDE developed by JetBrains. PyCharm offers a wide range of features that enhance the development experience, including intelligent code completion, code navigation, and integrated debugging tools. A heavier IDE like PyCharm was chosen over lighter code editors such as Visual Studio Code or Sublime Text because of its robust support for Python and its powerful features that can help manage a larger codebase more effectively.

For the environment itself, the Nix package manager was used to create a reproducible development environment. Nix allows developers to define their development environment in a declarative way, specifying the exact versions of tools and libraries needed for the project. This ensures that all developers working on the project have a consistent environment, which can help avoid issues related to dependency conflicts or differences in tool versions while keeping everything isolated from the system environment @how_nix_works. The specific configuration used for this project is shown in @nix-dev-env, which includes Python 3.11 and the necessary packages for development. Direnv was also used to automatically load the Nix environment when entering the project directory, further streamlining the development workflow @direnv.

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

== Project structure

The project is structured as a single Python package named `graph_insights` containing all the source code for the application accompanied by the main entrypoint script `main.py`. Supporting files such as the UI design files, static assets, and documentation are organized into separate directories within the project.

Within the `graph_insights` package, the code is organized into several subpackages and modules based on functionality. For example, there are separate packages for data processing, visualization, and analysis, as well as a package for the user interface components (as shown in @misc:working_dir).

#figure(
  caption: [Structure of the main package],
  ```
  -- graph_insights
    |--app/
    |--core/
    |--processing/
    |--qt/
    |--render/
    |--ui/
    |
    |---__init__.py
    |---__main__.py
  ```,
) <misc:working_dir>

This modular structure allows for better organization of the code and makes it easier to maintain and extend the application in the future. Each module contains related functions and classes that encapsulate specific functionality, following the principles of separation of concerns and single responsibility. This organization also facilitates testing, as each module can be tested independently, and it allows for easier collaboration if other developers were to join the project in the future. The context of the various subpackages is outlined in @tab:dir-structure, which provides a brief description of the purpose of each directory within the `graph_insights` package.

#figure(
  table(
    columns: 2,
    [*Directory*], [*Description*],
    [`app/`], [Contains the main application logic and entry point.],
    [`core/`], [Contains core functionality and utilities used across the application.],
    [`processing/`], [Contains modules for data processing and analysis.],
    [`qt/`], [Contains modules related to the Qt framework and user interface components.],
    [`render/`], [Contains modules for rendering visualizations.],
    [`ui/`], [Contains the .ui files created with Qt Designer for the user interface design.],
  ),
  caption: [Description of the `graph_insights` subpackages],
) <tab:dir-structure>

== Data ingestion <section:data-ingestion>

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
    width: 50%,
  ),
  caption: [Logic behing the `convert_dtypes` stage of the data loading pipeline],
) <diagram:convert-dtypes>

The next stage is to reindex the `DataFrame` from sequential integers to timestamps, using the `#Time` column as the source. This allows us to easily perform time-based operations on the data, such as resampling or rolling window calculations. After reindexing, the time channel is dropped from the `DataFrame`, as it is no longer needed. The next stage is to derive new channels from existing ones using a set of rules defined in `processing/derived_channels.py`. Most commonly these include power calculation from voltage and current channels. Finally, the column names are stripped of whitespace and normalized to a consistent case (lowercase) to avoid issues with inconsistent naming conventions in the source data#footnote("Change in column names is a frequent occurrence when switching between different versions of data recording software.").

== Designing the user interface

The requirements for the user interface were to be simple, intuitive, and efficient for the target users, who are engineers and technicians at Škoda Auto. The application needed to provide a clear and organized way to visualize and analyze tabular data exported from ODIS, with a focus on usability and accessibility for users who may not have extensive programming experience.

There are two ways to design a user interface in Qt: using code or using a visual design tool, preferably the official Qt Designer. For very simple applications, setting up all the widgets and layouts in code can be straightforward and may even be quicker and easier than wiring up a design file. However, for more complex applications with multiple windows, dialogs, and a variety of widgets, using a visual design tool is a no-brainer, as it allows developers to quickly and easily create and modify the user interface without having to write a lot of code. Qt Designer is bundled with the PyQt6 package, so no need to install it separately. Recall @nix-dev-env, where I setup an alias for the bundled Qt Designer, which allows me to simply type ```bash designer``` in the terminal to launch the Qt Designer application.

Each window or dialog in the application was designed as a separate .ui file using Qt Designer. A UI file is simply an XML file that describes the layout and properties of the widgets in a particular window or dialog. Because of its text-based nature, it can be easily version-controlled and merged using Git, which is a significant advantage over binary design files used by some other frameworks. The process of loading a UI file in Python is straightforward, as shown in @listing:load-ui. The ```uic.loadUi``` function takes the path to the .ui file and the instance of the widget to load it into, and it automatically creates the necessary widgets and layouts as defined in the design file.

#figure(
  caption: [Loading the UI file in Python],
  [
    ```python
    uic.loadUi(path.join(BASE_DIR, 'ui/analysis_overview.ui'), self)
    ```
  ],
) <listing:load-ui>

=== The main window

The main window of the application is also the most important one, as it serves as the central hub for all the functionality of the application and is the first thing that users see when they launch the application. It must provide the following key features:

- List of loaded datasets with the ability to add, remove, and switch between them
- A unionized list of all channels across all loaded datasets, with the ability to select which channels to visualize and analyze

#figure(
  image("../assets/ui/main-window.png", width: 110%),
  caption: [The main window of the application, designed using Qt Designer],
) <image:main-window-ui>

== Visualization

Showing users a visual representation of their data is the core functionality of the application, so designing the visual part of the user interface was a crucial aspect of the project, both from the #abbr("UI", "User Interface") and #abbr("UX", "User Experience") perspective.

=== Graphing library

Before diving into the specifics of the visualization system, a technology for the actual rendering of the visualizations had to be chosen. There are a number of options available for rendering visualizations in Python, each with its own advantages and disadvantages. A comparison of the most popular options available in the Python ecosystem is shown in @tab:graphing-library-comparison.

#figure(
  table(
    columns: 3,
    [*Technology*], [*Advantages*], [*Disadvantages*],
    [Matplotlib],
    [
      - Mature and widely used library with a large community and extensive documentation
      - Highly customizable and flexible, allowing for a wide range of visualization types and styles
      - Good performance for static visualizations
    ],
    [
      - Can be complex and difficult to learn for beginners
      - Not ideal for interactive visualizations or real-time data updates
    ],

    [Plotly],
    [
      - Easy to create interactive visualizations with built-in support for zooming, panning, and tooltips
      - Can be used in both web applications and desktop applications using frameworks like Dash
      - Good performance for interactive visualizations
    ],
    [
      - Can be overkill for simple static visualizations
      - May have a steeper learning curve for advanced features
    ],

    [Bokeh],
    [
      - Designed for creating interactive visualizations in web browsers
      - Can handle large datasets efficiently
      - Good performance for interactive visualizations
    ],
    [
      - Not ideal for static visualizations
      - May require additional setup for use in desktop applications
    ],
  ),
  caption: [Comparison of visualization technologies in Python],
) <tab:graphing-library-comparison>

The table above is not an exhaustive comparison of all the visualization technologies available in Python, but it covers some of the most popular and widely used options. All of these are solid choices that provide all the necessary features for our use case, so the decision ultimately came down to personal preference and familiarity with the library. I drafted up possible UI designs for both Matplotlib and Plotly and the results from the informal user testing sessions with potential users leaned towards *Matplotlib*, as it provided a more traditional and familiar visualization experience that was preferred by the target users. It also helped that I've had a few years of experience working with Matplotlib, namely for university assignments and personal projects.

With the rendering technology chosen, the next step was to design a flexible and extensible system for creating and managing visualizations within the application. The main goal was to create a system that would allow users to easily create and customize their visualizations, while also providing a solid foundation for future development and expansion of the application's visualization capabilities.

=== System architecture

At the heart of the system is the `Renderer` class. It works by instantiating a `Renderer` object with a certain specification, and then calling the `render()` method to generate the visualization. The `Renderer` class is designed to be flexible and extensible, allowing for different rendering backends to be used (e.g., Matplotlib, Plotly, etc.) and for different layout strategies to be implemented (e.g., grid layout, stacked layout, etc.). The architecture of the core and data components is depicted in @diagram:rendering-system-core.

#figure(
  image("../assets/diagram/render-system/core.svg", width: 100%),
  caption: [Architecture of the rendering system, showing the core components and their interactions],
) <diagram:rendering-system-core>

A `RenderBackend` is the unified API for a specific rendering technology that provides a consistent interface for the rest of the application to interact with, regardless of the underlying rendering technology being used. This allows for greater flexibility and modularity in the design of the application, as different rendering technologies can be easily swapped out or added without requiring significant changes to the rest of the codebase. It has a state-machine-like design with the functions being a little biased towards Matplotlib's way of doing things, as it is the primary rendering technology used in the application, but it is designed to be flexible enough to accommodate other rendering technologies in the future if needed.

`LayoutStrategy` is responsible for determining how the visualizations are arranged and displayed within the application. There are basically two main layout strategies implemented in the application: *#abbr("PFP", "Per-File Plot")* and *#abbr("PCP", "Per-Channel Plot")*. The PFP strategy creates a separate plot for each selected dataset containing all selected channels, while the PCP strategy creates a separate plot for each selected channel containing all selected datasets. Both strategies have their own advantages and disadvantages, and the choice between them ultimately comes down to user preference and the specific use case. The architecture of the backend and layout components is depicted in @diagram:rendering-system-backend.

#figure(
  image("../assets/diagram/render-system/backend.svg"),
  caption: [Architecture of the rendering system, showing the backend components and their interactions],
) <diagram:rendering-system-backend>

=== Mixins

A _mixin_ is by definition a class that provides methods to other classes through inheritance, but is not intended to be instantiated on its own @mixin. In the rendering system, mixins are used to extend the functionality of a `RenderBackend` by exposing additional methods that are specific to the mixin's functionality and also having the backend implement the necessary logic to support those methods - mainly rendering.

During the development, user feedback was collected and contributed to key features being added to the application, such as the ability to display the difference between two curves on a plot - a delta curve. This feature was implemented as a mixin (`DeltaMixin`) which exposes a `calculate_delta()` method that takes in two curves, performs the necessary calculations to compute the delta curve and returns it. It also defines an abstract method `plot_delta()` that must be implemented by any backend that uses the mixin, which takes care of rendering the delta curve on the plot. This design allows for a clear separation of concerns, as the mixin is responsible for the logic of calculating the delta curve, while the backend is responsible for rendering it. The architecture of the `DeltaMixin` is depicted in @diagram:delta-mixin.

#figure(
  image("../assets/diagram/render-system/delta-mixin.svg", width: 100%),
  caption: [`DeltaMixin` architecture],
) <diagram:delta-mixin>

In practice, when a user selects the option to display the delta curve on a plot, the application does a few preliminary checks, namely whether the current context #footnote("A user selection involves zero or more files and channels. Depending on the layout, plots may contain a different number of curves. A delta curve is only calculated between exactly two curves.") and backend support it and if so, it calls the `calculate_delta()` method with the appropriate curves. The backend then performs the necessary calculations and calls the `plot_delta()` method to render the delta curve on the plot. The particular implementation of the `plot_delta()` method also adds a baseline to the plot at y=0 and dedicates the right y-axis to the delta curve, which allows for better visualization and interpretation of the delta curve in relation to the original curves. A concrete example of a plot with the delta curve rendered is shown in @img:delta-plot.

#figure(
  image("../assets/delta-plot.png", width: 110%),
  caption: [Delta curve for two vehicles' speed channel],
) <img:delta-plot>

A need for in-plot statistical analysis features was also identified during user testing sessions, which led to the implementation of a `DescriptiveStatisticsMixin` that provides methods for calculating and displaying descriptive statistics such as mean, median, standard deviation, etc. for the selected curves on a plot. Similar to the `DeltaMixin`, it defines abstract methods (`plot_extrema()` and `plot_statistics()`) that must be implemented by any backend that uses the mixin, which take care of rendering. The architecture of the `DescriptiveStatisticsMixin` is depicted in @diagram:stats-mixin.

#figure(
  image("../assets/diagram/render-system/stats-mixin.svg", width: 100%),
  caption: [`DescriptiveStatisticsMixin` architecture],
) <diagram:stats-mixin>

As an example of how the `DescriptiveStatisticsMixin` works in practice, when a user selects the option to display descriptive statistics on a plot, the application first checks if the current backend supports it and if so, it calls the appropriate methods to calculate the statistics for the selected curves. The backend then performs the necessary calculations and depending on the number of curves #footnote("If a plot contains a single curve, global extrema are annotated and descriptive statistics are displayed. In case of multiple curves, only the extrema are annotated for each curve.") in the plot, it may call the `plot_extrema()` method to render markers for the extrema points of each curve, and/or the `plot_statistics()` method to render a table with the calculated statistics on the plot. A concrete example of a plot with descriptive statistics rendered is shown in @img:stats-plot.

#figure(
  image("../assets/stats-plot.png", width: 110%),
  caption: [Descriptive statistics for the speed channel of a single vehicle],
) <img:stats-plot>

=== Plugins

After the core rendering system was implemented and in use by the users, the need for additional features and customizations arose. To accommodate these needs without cluttering the core rendering system with too many features that may not always be relevant, a plugin architecture was implemented. It allows us to inject additional functionality into the rendering system at different stages of the rendering process without modifying the core codebase. This design promotes modularity and separation of concerns, as plugins can be developed and maintained independently from the core rendering system, while still being able to interact with it in a well-defined way.

The concept as well as the implementation itself is straightforward. A plugin is simply a callable object such as a function or a lambda, that takes in an instance of a `RenderBackend` and performs some operations on it. Different stages of the rendering process (e.g., figure creation, plot creation, etc.) get a `pre` and `post` plugin hooks assigned to them by annotating the functions themselves with the `@lifecycle` decorator #footnote("The 'pre' hook is called before the stage is executed, and the 'post' hook is called after the stage is executed automatically, the decorator only requires the hook name."), as shown in @listing:hooks.

#figure(
  ```python
  @lifecycle("begin_figure")
  def begin_figure(self, ...):
    ...

  @lifecycle("begin_plot")
  def begin_plot(self, ...):
    ...
  ```,
  caption: [Plugin hooks for the rendering stages],
) <listing:hooks>

A plugin can then be registered to any of these hooks, and it will be called at the appropriate time during the rendering process. The architecture of the plugin system is depicted in @diagram:plugins.

#figure(
  image("../assets/diagram/render-system/plugins.svg", width: 100%),
  caption: [Backend plugin architecture],
) <diagram:plugins>

To give a more tangible example, consider a discrete flag channel (as opposed to a normal continuous channel) that indicates the status of a certain system in the vehicle, in this case the state of the heat pump. First, the channel itself is derived in the data processing stage (recall @section:data-ingestion) from a combination of multiple valves' position channels. Then, a plugin is registered to the `post_begin_plot` hook, as shown in @listing:plugin-registration, that checks if the heat pump channel is present in the plot's context and if so, it translates the discrete values of the channel to human-readable status labels and renders them as the y-axis ticks on the right y-axis of the plot.

#figure(
  ```python
  renderer.backend.register_plugin('post_begin_plot', wp_status_ytics)
  ```,
  caption: [Plugin registration (assuming `renderer` is an instance of `Renderer`)],
) <listing:plugin-registration>

== Analysis

The application with just the visualization features implemented already provided a lot of value to the users, as it allowed them to easily visualize and explore their data in a way that was not possible before. However, the ability to automatically extract insights and information from the data is what really takes the workflow to the next level. The goal is the following: as a user adds and removes files from the application during its lifetime, the application should be able to automatically analyze the data in the background and extract insights from it, which are then presented to the user in a clear and organized way. This takes the necessary time consuming process of inital screening of the data off the users' shoulders and allows them to focus on the actual analysis and interpretation of the data, which is where their expertise lies.

I have split the process of analysis into two categories: *individual* and *comparative* #footnote("The term comparative in this context denotes a strictly pairwise framework, wherein analysis is conducted exclusively between two distinct files at a time."). This means that files are analyzed both individually and in comparison to each other, which targets different use cases and allows for a more comprehensive analysis of the data.

Because the threaded pipeline pattern described and used in @section:data-ingestion worked so well for the data loading process, I decided to use a similar approach for the analysis features as well. Whenever a new file is added to the application, it goes through the processing pipeline, and once it is loaded and processed, the `on_processing_pipeline_batch_finished()` callback is triggered, which submits the file into the `IndividualAnalysisPipeline` for individual analysis. As a result, `submit_file_pairs_for_analysis()` is also called, which generates the file combinations and submits them into the `FilePairAnalysisPipeline` for comparative analysis. Both pipelines work in a separate thread and have their own set of stages that are executed in order, similar to the data loading pipeline. The results of the analysis are then stored in a cache for quick access and are also emitted as signals to update the user interface with the new insights.

=== Channel data correlation

In some scenarios, it may be useful to check whether certain channels are roughly (or exactly) the same across multiple files, maybe from a test drive conducted on multiple vehicles driven at the same time. Hypothetically, a technician may want to confirm that both vehicles' radiator shutters (or a blind-like alternative like the AAB @rochling_aab that are more common nowadays in Škoda vehicles) behaved the same during the test drive, which could be an indication of a potential issue with the shutters if they did not. This is where correlation analysis comes in handy. By calculating the correlation coefficient between the channel `01/roleta chladiče, skutečná poloha/---` across the corresponding files, the application can provide a quick and easy way for the user to verify whether the shutters behaved correctly or not.

There are a number of different correlation coefficients that can be used to measure the correlation between two channels, such as Pearson's correlation coefficient, Spearman's rank correlation coefficient, and Kendall's tau coefficient. Each of these coefficients has its own advantages and disadvantages, and the choice of which one to use depends on the specific characteristics of the data and the analysis being performed. For this application, I chose the *Pearson's correlation *coefficient as it is a widely used measure of linear correlation between two variables and is appropriate for the type of data being analyzed.

As far as the implementation goes, this feature falls under the category of comparative analysis, as it involves comparing channels across multiple files. Whenever a new file is added to the application, a set of distinct file combinations is generated using the `itertools.combinations()` function from the Python standard library. If the set of currently loaded files is denoted by #"F", then the number of combinations grows according to the following formula:

$ binom(abs(F), 2) = frac(abs(F)!, 2! * (abs(F) - 2)!) $

This might seem like a lot of combinations, but in practice the number of files loaded at the same time is usually quite small (2-5), so it is not a problem.

The set of files is then submited into the `FilePairAnalysisPipeline`. The pipeline holds a cache of previously calculated correlation coefficients for each pair of files, so if a combination has already been analyzed before, the cached result is returned immediately without having to recalculate it. If the combination is new, the pipeline calculates the correlation coefficient for each pair of channels between the two files and stores the results in the cache for future reference.

For visualization purposes, the results are presented to the user as a table containing the list of correlated channels across multiple files, showing the correlation coefficient (color coded from red to blue, with red indicating strong negative correlation and blue indicating strong positive correlation) and a button to quickly view the two channels in question on a plot beside each other for a more detailed comparison, as shown in @img:correlations. The table columns are sortable, giving the user the ability to quickly find the most correlated channels across their files, which can be a useful starting point for further analysis and investigation. Additional forms of visualization for the correlation results are discussed in @chapter:the-future.

#figure(
  image("../assets/analysis-correlations.png", width: 110%),
  caption: [List of correlated channels across multiple files],
) <img:correlations>

=== Statistical methods for anomaly detection

Comparative analysis can be very useful for extracting insights from the data, but it cannot determine whether a particular file contains any *anomalies* or not. Be it invalid readings, unexpected behavior of a certain system in the vehicle, or just a generally weird file that doesn't really fit in with the rest of the data, it is important to be able to automatically flag these files for the user so they can take a closer look at them or even exclude them from the analysis if they are deemed to be of low quality. This is where the need for anomaly detection stems from.

Anomaly detection is a technique used to identify unusual patterns or behaviors in data that do not conform to expected norms. In the context of this application, anomaly detection is used to identify parts of channel data that deviate significantly from the expected behavior, which could indicate potential issues or areas of interest for further analysis. This section focuses on purely statistical methods for anomaly detection, while the next one explores machine learning applications.

There are numerous tools and techniques statistics provides for inconsistency detection, such as outlier detection methods (e.g., Z-score, IQR), time series analysis techniques (e.g., ARIMA, STL decomposition), and change point detection algorithms (e.g., PELT, Binary Segmentation). Each of these methods has its own advantages and disadvantages, and the choice of which one to use depends on the specific characteristics of the data and the type of anomalies being targeted. For this application, I implemented a simple standard deviation-based outlier detection method, which identifies data points that are a certain number of standard deviations, away from the mean as anomalies (the exact implementation is shown in @listing:std-thresholding).This method is computationally efficient and works well for normally distributed data, which our data roughly is after the processing stage. It tells us which data points are anomalous for a particular channel in a particular file.

#todo("matematickej klikihak na vysvetlenie toho vzorecka")

#figure(
  [
    ```python
    for channel in file.get_numeric_channels():
      channel_data = file.get_channel_data(channel)
      mean = channel_data.mean()
      std_dev = channel_data.std()
      threshold = mean + 3 * std_dev
      anomaly_points = np.where(channel_data > threshold)[0].tolist()
    ```
  ],
  caption: [Standard deviation thresholding logic used in the application],
) <listing:std-thresholding>

The results are again presented to the user in a tabular fashion, showing the list of channels in a file that contain anomalies (and the amount) along with a button to quickly view the channel on a plot with the anomalous points highlighted for a more detailed analysis. Because this method falls under the category of individual analysis, the results are shown on a per-file basis by utilizing Qt's tab widget, which allows for a clear and organized presentation of the results while also providing an easy way for users to navigate between different files and their corresponding analysis results, as shown in @img:std-thresholding.

#figure(
  image("../assets/analysis-std-thresholding.png", width: 110%),
  caption: [Visualization of the found anomalies using the standard deviation thresholding method],
) <img:std-thresholding>

As mentioned, a button is provided for each channel with anomalies that allows users to quickly view the channel on a plot with the anomalous points highlighted. The results from the analysis pipeline are in the form of a list of indices corresponding to the anomalous data points in the channel. To make this data more interpretable and actionable for the users, the application constructs intervals from data points directly adjacent to each other, as these are likely to be part of the same anomaly, and highlights these intervals on the plot using a shaded area. A concrete example of such a plot is shown in @img:std-thresholding-plot, where the anomalous intervals are highlighted in red.

#figure(
  image("../assets/analysis-std-thresholding-plot.png", width: 120%),
  caption: [Highlighted anomalous intervals on a plot using STD thresholding],
) <img:std-thresholding-plot>

=== Machine learning for anomaly detection

The statistical methods described in the previous section are a good starting point for anomaly detection, and can reliably identify certain types of anomalies in the data. However, their entire data context is just the files loaded into the application, so any inconsistencies that may be found are only relative to the other data in the application, and not necessarily in an absolute sense. For example, it cannot reveal illogical values in a channel that are not necessarily outliers in the context of the other loaded files. This is where #abbr("ML", "Machine Learning") can lend a helping hand. We keep pretty much all the data from previous test drives on a shared drive, so we have a large amount of historical data that can be used to train ML models to identify anomalies in the data based on patterns and relationships that may not be immediately apparent through statistical methods alone. By leveraging ML techniques, the application can provide a more robust and comprehensive anomaly detection system that can help users identify potential issues and areas of interest in their data more effectively.

ML algorithms can be broadly categorized into supervised and unsupervised learning methods. Supervised learning methods require labeled data for training, which means that the anomalies in the historical data would need to be identified and labeled by experts, which can be a time-consuming and labor-intensive process. Unsupervised learning methods, on the other hand, do not require labeled data and can identify anomalies based on patterns and relationships in the data itself. Given that we want to dump a bunch of historical data into the model and have it train itself without the need for manual labeling, *unsupervised* learning methods are the way to go for our use case. A couple of popular unsupervised ML algorithms for anomaly detection are compared in @tab:anomaly-detection-algorithms.

#figure(
  table(
    columns: 4,
    align: center,
    stroke: 0.5pt,
    [*Algorithm*], [*Core Idea*], [*Pros*], [*Cons*],

    [Isolation Forest],
    [Random partitioning isolates anomalies with fewer splits],
    [
      - Excellent scalability
      - Handles high-dimensional data well
      - Minimal assumptions
      - Robust in practice
    ],
    [
      - Less intuitive than simple distance-based methods
    ],

    [Local Outlier Factor (LOF)],
    [Detects anomalies via local density deviation],
    [
      - Good for local structure
    ],
    [
      - Struggles in high dimensions
      - Parameter sensitive
      - Slower than tree-based methods
    ],

    [K-Means (distance-based)],
    [Distance from centroid determines anomaly score],
    [
      - Simple and fast
    ],
    [
      - Assumes simple cluster shapes
      - Less robust than isolation-based methods
    ],

    [PCA-based Detection],
    [Projection and reconstruction error],
    [
      - Efficient baseline method
    ],
    [
      - Limited to linear relationships
      - Less robust than isolation-based approaches
    ],
  ),
  caption: [Comparison of a few unsupervised machine learning algorithms for anomaly detection]
) <tab:anomaly-detection-algorithms>

I ultimately decided to go with the Isolation Forest algorithm, as it is a powerful and widely used method for anomaly detection that is particularly effective for high-dimensional data, which is the case with our datasets. It works by randomly partitioning the data and isolating anomalies with fewer splits, which allows it to effectively identify anomalies even in complex datasets. The implementation of the Isolation Forest algorithm is provided by the `scikit-learn` library, which makes it ridiculously easy to use and integrate into the application. 

I implemented the training and validation of the model in a separare script that is run independently from the main application, as the training process can be quite time-consuming and resource-intensive, and also as not to convolute the main application codebase with ML-specific logic. The script simply takes in a location on disk where the individual files are stored and a combination of channels, which defines the model's dimensionality, and trains the model on the data from these channels across all the files. 

I used `scikit`'s `Pipeline` class to create a pipeline that includes data preprocessing steps (e.g., scaling, dimensionality reduction) and the Isolation Forest algorithm itself. The trained model is then saved to disk using `joblib` which users just point the application at in the settings and the application takes care of loading it and using it for anomaly detection (the whole pipeline is extracted from the `.joblib`, so the implementation on the application side stays very lean). This also allows for the possibility of training multiple models on different combinations of channels or different subsets of the data (e.g., winter vs. summer data), and easily switching between them in the application settings without having to modify the codebase.

This allows the application to point out anomalies in the sense of "Is this combination of channel values something out of the ordinary given what we have measured in the past?" which can be a very powerful tool for identifying potential issues and areas of interest in the data that may not be immediately apparent through statistical methods alone. 

#todo("concrete example please")
A concrete example blah blah. The results are again presented to the user in a tabular fashion, showing the list of files that contain anomalies based on the model's predictions along with a button to quickly view the relevant channels on a plot with the anomalous points highlighted the same way as with the statistical method (illustrated in @img:ml-anomalies-plot) for a more detailed analysis, as shown in @img:ml-anomalies.

#figure(
  image("../assets/analysis-ml-plot.png", width: 120%),
  caption: [Highlighted anomalous points on a plot using ML (dual-channel model)],
) <img:ml-anomalies-plot>

#figure(
  image("../assets/analysis-ml.png", width: 110%),
  caption: [Visualization of anomalies detected using a machine learning method],
) <img:ml-anomalies>

