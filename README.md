<p align="center">
    <img src="https://user-images.githubusercontent.com/1342803/36623515-7293b4ec-18d3-11e8-85ab-4e2f8fb38fbd.png" width="320" alt="Vapor Template">
    <br>
    <br>
    <a href="https://docs.vapor.codes/4.0/"><img src="https://design.vapor.codes/images/readthedocs.svg" alt="Documentation"></a>
    <a href="https://discord.gg/vapor"><img src="https://design.vapor.codes/images/discordchat.svg" alt="Team Chat"></a>
    <a href="LICENSE"><img src="https://design.vapor.codes/images/mitlicense.svg" alt="MIT License"></a>
    <a href="https://github.com/vapor/template/actions/workflows/test-template.yml"><img src="https://img.shields.io/github/actions/workflow/status/vapor/template/test-template.yml?event=push&style=plastic&logo=github&label=tests&logoColor=%23ccc" alt="Continuous Integration"></a>
    <a href="https://swift.org"><img src="https://design.vapor.codes/images/swift60up.svg" alt="Swift 6.0+"></a>
</p>

The official Vapor template, used by the [Vapor Toolbox](https://github.com/vapor/toolbox) to generate new projects.

## Overview

After having installed the [Vapor Toolbox](https://github.com/vapor/toolbox), you can use the following command in your terminal, replacing `<ProjectName>` with your desired project name, to create a new project using this template:

```sh
vapor new <ProjectName>
```

> [!TIP]
> Vapor and the template use `async/await` by default. If you cannot update to macOS 12 and/or need to continue to use `EventLoopFuture`s, add the `--branch macos10-15` flag.

This will create a new folder in the current directory containing the project.
You can then move into the project directory:

```sh
cd <ProjectName>
```

To build and run the project, see the [Getting Started](https://docs.vapor.codes/getting-started/hello-world/#build-run) guide.