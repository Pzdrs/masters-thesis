#import "../template/template.typ": *

I'd like to dedicate this chapter to my thoughts on how the current state of the project could be improved or how I would do things differently if I were to start from scratch. This is not meant to be a critique of the current implementation, but rather a reflection on potential areas for enhancement and future development.

== Data processing

In the never ending process of optimization and trying to make things faster, there are a few areas that I would focus on. One being able to recognize and skip already processed files. This would be particularly useful when dealing with large datasets, as it would save time and computational resources by avoiding redundant processing. Implementing a caching mechanism that stores the results of previously processed files could be an effective way to achieve this. By hashing the contents of the files and storing the processing pipeline results, we could quickly determine if a file has already been processed and retrieve the cached results instead of reprocessing it. User feedback on this particular feature was pretty much a green light, so I will definitely prioritize it in the next iterations of the project.

Another possible improvement in the core processing pipeline would be to leverage distributed computing frameworks like Apache Spark. The company issued laptops are not exactly powerhouses (at least the ones not dedicated for heavy workloads such as CAD) and as the datasets grow larger, processing times can become a bottleneck. By integrating distributed computing capabilities, we could offload some of the processing tasks to a cluster of machines, allowing for faster data processing and analysis. It also helps that Škoda Auto already has a well-established infrastructure for big data processing, so integrating Spark into the project would be a natural fit. This would not only improve performance but also enable us to handle larger datasets more efficiently, ultimately leading to more insightful analyses and better decision-making based on the data.

== Visualization

Even though the rendering framework is a fairly recent redesign, there are still some aspects that could be improved. For instance, the figure management system is currently quite basic, and for a simple reason - we only handle single figures at the moment. This limits our ability to create more complex visualizations that could span across multiple figures or subplots. In the future, I would consider implementing a more robust figure management system that allows for greater flexibility and scalability in our visualizations.

As mentioned in @section:correlation, the visualization portion of the correlation-based analysis (and also the other types) is currently quite basic. We simply create a list of the most correlated features and display them in a table. While this provides some insight, it lacks depth and interactivity. Personally, I would like to see a more dynamic and interactive visualization that allows users to explore the correlations in more detail. This could include features such as basic correlation matrices (as shown in @img:correlation-matrix), interactive scatter plots, or even heatmaps that visually represent the strength of correlations between features. 

#figure(
  image("../assets/correlation-matrix.png", width: 100%),
  caption: [
    Example of a correlation matrix using Matplotlib. \
    Source: https://codesignal.com/learn/courses/feature-engineering-and-correlation-analysis-in-pandas/lessons/heatmap-of-correlation-matrix
  ],
) <img:correlation-matrix>

Such enhancements would not only make the analysis more engaging but also provide deeper insights into the relationships between features. These proposed changes also have the additional benefit of being relatively straightforward to implement, making them a practical next step in the development of the project.

== Miscellaneous

Lastly I have some thoughts on the technologies and tools used in the project. Python is a great choice for data processing and analysis. The development speed and the rich ecosystem of libraries made prototyping and iterating on the project much faster than it would have been with a lower-level language. However, were I to start from scratch, I might consider using a more performant language like C++. The user interface is currently built using PyQt, which is just a set of Python bindings for the Qt framework written in C++. By using C++ directly, we could potentially achieve better performance while using the same underlying framework for the UI. This would allow us to maintain the same level of functionality while improving the overall responsiveness and efficiency of the application. 

Additionally, using C++ could open up opportunities for further optimizations in the data processing pipeline, as we would have more control over memory management and low-level operations. However, it's important to weigh these potential benefits against the increased development time and complexity that comes with using a lower-level language, especially considering the current success and functionality of the project as it stands.