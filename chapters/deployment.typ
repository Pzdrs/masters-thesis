#import "../template/template.typ": *

A crucial aspect of software development is ensuring that your application can be easily and reliably deployed to your users. In this chapter, I will cover the various aspects of deployment, including user documentation, testing, and packaging.

== User documentation

For any software application, especially a highly technical one, user documentation is essential. It helps users understand how to use the application effectively on their own. In this section, I will focus on user documentation for application use, rather than the technical details of how it works, which are more relevant to developers.

I considered various documentation formats, including Markdown files, a static website, and a PDF manual. I ultimately decided to go with a static website. Over the years, I have used MkDocs to generate documentation websites, and I have found it to be a great tool for this purpose. It allows easy markdown writing and generates a clean, professional-looking website with many #abbr("QoL", "Quality of Life") features built in. Most of the time, I have used MkDocs with the Material for MkDocs theme, which provides a modern, responsive design. The maintainers behind Material for MkDocs have been working on a project called *Zensical*, a documentation generator that aims to provide an even better experience for both writers and readers. The configuration is very similar (almost backward compatible) to MkDocs, reducing the learning curve for people like me, @zensical. I have therefore decided to give Zensical a try for this project.

When it comes to hosting the documentation, there are really two options: hosting it locally or on the cloud (on someone else's computer). The latter is generally more convenient for users, as they can access the documentation from anywhere without downloading it. However, cloud hosting comes with high costs and maintenance. Even though it is simple static content that could just be hosted on S3 or GitHub Pages, I wanted to avoid the hassle of setting up and maintaining a hosting solution. I instead opted to host the documentation locally, specifically including it as part of the application itself. This way, users can access the documentation directly from the application without an internet connection or hosting costs.

The way this works is that the documentation website is generated as a static site bundle, which is then included in the application's resources. When the application starts, a local web server is started to serve these files on a random port assigned to us by the #abbr("OS", "Operating System"). Even better, no additional dependencies are required to serve the documentation, as Python's standard library includes the `http.server` module, which makes all of this possible.

The documentation includes a quick start guide that provides users with the essential information to get started with the application (illustrated by @img:docs-homepage). It also includes a more detailed user guide that covers the application's features in depth, focusing on the two main use cases: visualization and data analysis. The website offers both English and Czech versions, and users can easily switch between them using a language selector in the top-right corner of the page. 

#figure(
  rect(image("../assets/docs-homepage.png", width: 100%), stroke: rgb(238, 132, 62)),
  caption: [Home page of the documentation website],
) <img:docs-homepage>

== Testing

Virtually every piece of software contains bugs, and no software is perfect. However, by implementing a robust testing strategy, we can significantly reduce the number of bugs that make it into production and ensure that our application behaves mostly as expected across changes and updates. Testing can take many forms, including unit tests, integration tests, end-to-end tests, and user testing. 

In this project, I focused primarily on unit tests, which verify the behavior of individual components or functions in isolation. Unit tests are typically fast to run and can be easily automated. All unit tests are under the `tests` directory in regular Python modules as functions prefixed with `test_`. I used the pytest framework for writing and running tests, which provides a simple and powerful way to write tests in Python. To measure test coverage, I used the `coverage` package, which shows which lines of code are covered by tests and which are not. This helps me identify areas of the code that may need more testing. I was not aiming for abnormally high test coverage, because most of the results the application provides are visual and not easily testable with automated tests. Instead, I focused on testing the application's core logic and functionality, while relying on user testing to validate the visual design and overall user experience. 

As of version 1.11.0, test coverage is around 70%, a good balance between ensuring code quality and avoiding the burden of testing every line of code.

As mentioned, the user testing was also an important part of the testing strategy. I released versions of the application to users and, every week, I sat down with them to gather feedback and observe how they were using it. This provided valuable insights into how users were interacting with the application, which features they found useful, which areas needed improvement, and which features were missing.

== Versioning and release management

As described in @section:dev-env, the project started with version control in mind, using Git from the very beginning. This allowed me to keep track of all changes to the codebase and easily revert if things went wrong. As for commit messages, I stuck to the _Conventional Commits_ specification, which provides a standardized format for commit messages @conventional_commits. This makes it easier to understand the project's history and generate changelogs automatically.

As development progressed, I released the software to users for testing and feedback (more on release artifacts in @section:packaging). I versioned these releases using _Semantic Versioning_, which uses a three-part version number (major.minor.patch) to indicate the level of changes made in each release @semantic_versioning. During the early stages of ML analysis, I even used a release candidate (RC) versioning scheme, which allowed me to mark releases as still in testing and not yet ready for production use. This helped manage user expectations and encouraged them to provide feedback on the release. At the time of writing, the project is at version 1.11.0 and is still in active development. I have been using annotated Git tags to mark the specific commits corresponding to each release, which makes it easy to track release history and roll back to a previous version if necessary (see @code:git-tag). 

#figure(
  [
    ```bash
    git tag -a v1.11.0 -m "Release version 1.11.0"
    ```
  ],
  caption: [Tagging a release commit with Git (annotated tag)],
) <code:git-tag>

== Packaging <section:packaging>

Every time a release is made, the application needs to be packaged for distribution. The requirements for packaging the application were quite specific. I wanted to create a single executable file that users could run as-is. Installing any software on the company-provided machines is a bureaucratic nightmare, and I wanted to avoid asking users to go through that process just to use the application. That meant that I needed to bundle all the dependencies and resources into a single file that could be executed without any additional setup. Furthermore, I wanted the application to be cross-platform. Even though 99% of users are on Windows, I still wanted to support potential users on other operating systems, such as macOS and Linux. 

For packaging Python applications into standalone Windows executables (.exe files), several tools are commonly used, including PyInstaller and Nuitka. During the initial release process, both options were evaluated; however, due to technical difficulties encountered with Nuitka, PyInstaller was ultimately selected as the preferred solution. This decision was further influenced by time constraints, as a functional proof of concept was already available using PyInstaller and an initial release needed to be delivered within a limited timeframe.

PyInstaller uses the current platform as the target platform for the generated executable. This means that to create a Windows executable, I have to run PyInstaller on a Windows machine, which sadly cannot be easily automated in a CI/CD pipeline. However, using PowerShell scripts, I was able to streamline the packaging process into roughly a single command (the PyInstaller configuration used by those scripts is shown in @code:pyinstaller-config). The final executable is generated in the `dist` directory and manually moved to a shared drive accessible to users, where a versioned folder is created for each release. 

#figure(
  [
    ```python
    def install():
      PyInstaller.__main__.run([
          path_to_main,
          '--add-data', 'ui/*:ui',
          '--add-data', 'pyproject.toml:.',
          '--add-data', 'docs/cs/site:docs/cs/site',
          '--add-data', 'docs/en/site:docs/en/site',
          '--onefile',
          '--clean',
          '--distpath', os.path.join(BASE_DIR, 'dist', RELEASE_VERSION),
          '--collect-submodule', 'sklearn',
          '--name', f'graph-insights-{RELEASE_VERSION}',
      ])
    ```
  ],
  caption: [PyInstaller configuration for packaging the application into a single executable file],
) <code:pyinstaller-config>

One notable drawback of this approach is the resulting executable size. Because the packaging process bundles all dependencies with the Python interpreter, the final executable is relatively large (approximately 150 MB). This increase in size is an inherent consequence of consolidating all required resources into a single distributable file. Additionally, the application exhibits a longer cold start time (up to 30 seconds), as the bundled components must first be unpacked and the Python runtime initialized before the application code can execute. 

Despite my negative perspective on these issues, user feedback has been overwhelmingly positive, with no significant complaints about the executable size or startup time. This suggests that, for the target user base, the convenience of having a single executable file outweighs the drawbacks associated with its size and startup performance.