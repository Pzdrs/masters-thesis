#import "../template/template.typ": *

TThe topic of multiplatform desktop applications is a very deep one, and it is very easy to get caught up in the details of the various frameworks and technologies available for building such applications. That is why we need to establish some facts and the particular requirements of our application before we can start evaluating the options.

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

== Development environment

Development environment refers to the tools and software used by developers to write, test, and debug their code. A good development environment can significantly improve productivity and make the development process more efficient. For this project, the development environment consisted of a combination of an #abbr("IDE", "Integrated Development Environment") and various tools for version control, testing, and documentation.

The primary IDE of choice for this project was PyCharm, a popular Python IDE developed by JetBrains. PyCharm offers a wide range of features that enhance the development experience, including intelligent code completion, code navigation, and integrated debugging tools. A heavier IDE like PyCharm was chosen over lighter code editors such as Visual Studio Code or Sublime Text because of its robust support for Python and its powerful features that can help manage a larger codebase more effectively.

For the environment itself, the Nix package manager was used to create a reproducible development environment. Nix allows developers to define their development environment in a declarative way, specifying the exact versions of tools and libraries needed for the project. This ensures that all developers working on the project have a consistent environment, which can help avoid issues related to dependency conflicts or differences in tool versions while keeping everything isolated from the system environment @how_nix_works. The specific configuration used for this project is shown in @nix-dev-env, which includes Python 3.11 and the necessary packages for development. Direnv was also used to automatically load the Nix environment when entering the project directory, further streamlining the development workflow @direnv.

#todo("reference the designer alias in the shell hook when we talk about the UI design process")
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

== Designing the user interface

#todo("popis jak fungujou widgety v qt")

The requirements for the user interface were to be simple, intuitive, and efficient for the target users, who are engineers and technicians at Škoda Auto. The application needed to provide a clear and organized way to visualize and analyze tabular data exported from ODIS, with a focus on usability and accessibility for users who may not have extensive programming experience.

There are two ways to design a user interface in Qt: using code or using a visual design tool, preferably the official Qt Designer. For very simple applications, setting up all the widgets and layouts in code can be straightforward and may even be quicker and easier than wiring up a design file. However, for more complex applications with multiple windows, dialogs, and a variety of widgets, using a visual design tool is a no-brainer, as it allows developers to quickly and easily create and modify the user interface without having to write a lot of code.

Each window or dialog in the application was designed as a separate .ui file using Qt Designer. A UI file is simply an XML file that describes the layout and properties of the widgets in a particular window or dialog. Because of its text-based nature, it can be easily version-controlled and merged using Git, which is a significant advantage over binary design files used by some other frameworks. The process of loading a UI file in Python is straightforward, as shown in @listing:load-ui. The ```uic.loadUi``` function takes the path to the .ui file and the instance of the widget to load it into, and it automatically creates the necessary widgets and layouts as defined in the design file. 

#figure(
  caption: [Loading the UI file in Python],
  [
    ```python
    uic.loadUi(path.join(BASE_DIR, 'ui/analysis_overview.ui'), self)
    ```
  ],
) <listing:load-ui>


== Application architecture

== Visualization

render framework selfbuilt
renderer - layout strategy - backend - matplotlib backend

== Analysis

classic statistical methods
machine learning methods
supervised vs unsupervised - unsupervised needs to be monitored - we do monitor it so its the way to go

ODIS vs INCA (excel vs dat)
