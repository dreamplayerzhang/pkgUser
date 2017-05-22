- Visual Studio 2010
将"Custom.After.Microsoft.Common.targets"复制到路径"\Program Files (x86)\MSBuild\v4.0"下

- Visual Studio 2017社区版
将"Custom.After.Microsoft.Common.targets"复制到路径"\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\v15.0"下

其它Visual Studio版本对应方法:
随便打开一个C++工程，在工程"属性"页签，定位到"C/C++"的"附加包含目录",进入编辑状态,打开"宏",输入"Custom",找到"CustomAfterMicrosoftCommonTargets"对应的值,该值即为对应的Visual Studio版本"Custom.After.Microsoft.Common.targets"的具体路径.
