## 上传编译后的项目文件

## 该工具仅支持mac，linux，和带有bash功能的windows终端

```
mgtv install -g mb
#在项目目录下
mb version -m 'message'
```

mb 会运行 `pacakge.json`里面的`scripts`的`build`命令。请务必将编译好的项目文件输出到`build`文件夹下。

mb 会自动创建一个 `mb_xxx`到tag，并且`push`到远程服务器

