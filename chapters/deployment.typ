#import "../template/template.typ": *

A crucial aspect of software development is ensuring that your application can be easily and reliably deployed to your users. In this chapter, I will cover the various aspects of deployment, including user documentation, testing, and packaging.

== User documentation

For any software application, especially a highly technical one, user documentation is essential. It helps users understand how to use the application effectively on their own. In this section, I will focus on the user documentation pertaining to the usage of the application, rather than the technical details of how it works that would be more relevant for developers.

There were various options for the format of the documentation I considered, such as markdown files, a static website, or even a PDF manual. I ultimately decided to go with a static website. Over the years, I have used MkDocs for generating documentation websites, and I found it to be a great tool for this purpose. It allows for easy writing in markdown, and it generates a clean and professional-looking website with many #abbr("QoL", "Quality of Life") features built-in. Most of the time, I have used MkDocs in conjunction with the Material for MkDocs theme, which provides a modern and responsive design. The maintainers behind the Material for MkDocs have been working on a project called *Zensical*, which is a documentation generator that aims to provide an even better experience for both writers and readers of documentation. The configuration is very similar (almost backwards compatible) to MkDocs, reducing the learning curve for people like me @zensical. I have therefore decided to give Zensical a try for this project.

When it comes to hosting the documentation, there are pretty much two options: hosting it locally or  on the cloud (just someone else's computer). The latter is generally more convenient for users, as they can access the documentation from anywhere without needing to download it. However, hosting on the cloud brings significant baggage in terms of cost and maintenance. Even though it is simple static content that could just be hosted on S3 or GitHub Pages, I wanted to avoid the hassle of setting up and maintaining a hosting solution. I instead opted to host the documentation locally, or more specifically, to include the documentation as part of the application itself. This way, users can access the documentation directly from the application without needing an internet connection or worrying about hosting costs.

The way this works is that the documentation website is generated as a static site bundle, which is then included in the application's resources. When the application is started, a local web server is spun up to serve these files on a random port assigned to us by the #abbr("OS", "Operating System"). Even better, no additional dependencies are required to serve the documentation, as Python's standard library includes the `http.server` module, which makes all of this possible.

The documentation includes a quick start guide, which provides users with the essential information they need to get started with the application (illustrated by @img:docs-homepage). It also includes a more detailed user guide that covers all the features of the application in depth, focusing on the two main use cases: visualization and data analysis. The website has both an english and a czech version, and users can easily switch between the two languages using a language selector in the top right corner of the page. 

#figure(
  rect(image("../assets/docs-homepage.png", width: 100%), stroke: rgb(238, 132, 62)),
  caption: [Home page of the documentation website],
) <img:docs-homepage>

== Testing

unit tests
pytest, coverage
user testing - feedback from users, iterative development


== Packaging

pyinstaller, nuitka, brief comparison
package skripty
