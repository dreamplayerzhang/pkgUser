# pkgUser
**提供给Visual Studio使用的C++工程配置工具**
Inspired by [Vcpkg](https://github.com/Microsoft/vcpkg)

## 功能
- 提供面向Visual Studio解决方案的库依赖配置
- 一次配置，后续全部可用
- 自动处理库依赖，复制运行时依赖dll

注意：如果所使用库的debug和release版本混合在一起，仅仅是用**d**来区分，会导致无法链接到正确的库版本。

## Why?
C++的工程配置是非常麻烦的，需要兼顾win32/x64，debug/release，在每种情况下都需要指定头文件路径、对应库路径，还需要复制运行时依赖的dll。

一直有一些工具来试图简化这些复杂的配置步骤，譬如[Vcpkg](https://github.com/Microsoft/vcpkg)以及一些其它包管理工具，对其进行简单的了解就发现其实C++的包管理也可以非常简单，可以做到和别的语言一样，**install**后既可直接使用。

不幸的是这些工具在目前一些C++开发人员工作场景中并不能使用，[Vcpkg](https://github.com/Microsoft/vcpkg)只支持**Visual Studio 2015**及以上版本，而且只是比较适用于稳定的第三方库。

**pkgUser**就是根据**Vcpkg**实现原理制作的工程配置工具，通过在统一的配置文件中指定所依赖库的头文件路径、库路径和dll所在路径，达到类似**Vcpkg**安装后效果，可以直接**inclue**对应的头文件，而无须指定依赖的库，以及复制运行时依赖的dll。

## 使用方法(Visual Studio 2010)
1. 将**pkgUser**下载到特定目录，譬如`D:\pkgUser\`
2. 将**Custom.After.Microsoft.Common.targets**复制到`"\Program Files (x86)\MSBuild\v4.0"`路径下
3. 修改**pkgUser.targets**的内容：
    -  修改`<TLibrary>$(MSBuildThisFileDirectory)</TLibrary>`，将其调整为所使用库的根目录
    -  针对不同的配置修改`TLLIBPATH`和`TLDLLPATH`,保证其指定到所使用库的库路径和dll所在位置
    -  修改`TLINCPATH`使其指定到所使用库的头文件位置

4. 修改**template.sln.targets**中的**pkgUserRootPath**为**pkgUser**目录,譬如`D:\pkgUser\pkgUser`，保证`$(pkgUserRootPath).targets`指定到**pkgUser.targets**
4. 针对任何需要使用**pkgUser**的解决方案，将**template.sln.targets**复制到解决方案**.sln**所在文件夹,譬如针对`demo/demo.sln`，复制`template.sln.targets`,并将名称修改为`demo.sln.targets`
5. 在解决方案的工程中直接使用对应的库

## 出错如何验证
1. 验证`解决方案.sln.targets`是否正确配置

    只要**Custom.After.Microsoft.Common.targets**复制的位置正确，且`解决方案.sln.targets`放在对应的sln目录下,名称正好是解决方案名称+**.sln.targets**，那么解决方案中任何工程编译成功后都会输出如下消息:
    ```
    Generate By pkgUser:
      ********  liff.engineer@gmail.com  *********
              _         _   _               
             | |       | | | |              
        _ __ | | ____ _| | | |___  ___ _ __ 
       | '_ \| |/ / _` | | | / __|/ _ \ '__|
       | |_) |   ( (_| | |_| \__ \  __/ |   
       | .__/|_|\_\__, |\___/|___/\___|_|   
       | |         __/ |                    
       |_|        |___/    

    ```
2. 验证所使用库配置是否正确
    打开解决方案中任何一个工程的`属性`页签，定位到`C/C++`的`常规`，编辑`附加包含目录`，展开`宏`，输入`TL`,检查`TLibrary`、`TLLIBPATH`等宏的值，确认是否指定到正确的目录。

## 如何实现
1. Visual Studio 配置扩展点

    Visual Studio自身预留了扩展点，可以将外部MSBuild配置脚本导入到指定工程中，譬如针对`Visual Studio 2010`，扩展`targets`文件可以放置在`\Program Files (x86)\MSBuild\v4.0`下，名称必须为`Custom.After.Microsoft.Common.targets`，而`Visual Studio 2017`社区版对应路径在`\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\v15.0`下。

    查找对应`Visual Studio`扩展点位置的方法如下：
    1. 随便打开一个C++工程
    2. 切换到`属性`页签，定位到`C/C++`的`附加包含目录`
    3. 进入编辑状态，打开`宏`，输入`Custom`，找到`CustomAfterMicrosoftCommonTargets`,其对应值就是可以导入扩展`.targets`具体位置

2. 自动链接依赖库

    在指定所依赖的库时，除了配置库路径，然后设定依赖库，譬如`$(QtDir)\lib`与`QtWidgetd.lib`，也可以使用`$(libpath)\*.lib`，这种方式会根据链接符号去所有的`*.lib`查询，然后链接对应的**lib**

3. 自动复制所有依赖的dll

    VS的SDK附带了**dumpbin.exe**，以`/DEPENDENTS`为选项可以查询目标(`*.dll/*.exe`)所依赖的所有**dll**，**pkgUser.ps1**就是根据这个操作，从所有的dll路径中递归查询目标直接/间接依赖的所有**dll**。

## 如何扩展
1. 导入多个库依赖

    **pkgUser.targets**中的`TLibrary、TLLIBPATH、TLDLLPATH`等均是演示使用，实际使用中可以调整为对应库的名称,`<PropertyGroup>`节点下的项可以任意添加，在最终的`userBinaryPaths`、`userLibrarys`、`userIncludePath`中添加上去，然后以`;`分割开即可

2. 复制特定文件和目录

    该配置工具实现都是使用的`MSBuild`，只要符合`MSBuild`的操作方法都可以添加


