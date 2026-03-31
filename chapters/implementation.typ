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

== Designing the user interface

#todo("popis jak fungujou widgety v qt")

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

render framework selfbuilt
renderer - layout strategy - backend - matplotlib backend

== Analysis

classic statistical methods
machine learning methods
supervised vs unsupervised - unsupervised needs to be monitored - we do monitor it so its the way to go

ODIS vs INCA (excel vs dat)
