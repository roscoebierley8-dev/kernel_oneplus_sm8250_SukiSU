# SM8250 SukiSU-Ultra Kernel Builder

GitHub Actions 工作流,为 **OnePlus 8 / 8 Pro / 8T / 9R** (Snapdragon 865 / SM8250 / kona) 构建集成
**SukiSU-Ultra + SUSFS** 的内核,适配 **Evolution X 11.6.2 (Android 16)**。

支持的 codename: `instantnoodle` / `instantnoodlep` / `kebab` / `lemonadep`

## 工作流做了什么

1. 拉取 EvolutionX/LineageOS 22.2 的 SM8250 内核源码
2. 用官方脚本注入 SukiSU-Ultra (`susfs-main` 分支)
3. Clone `susfs4ksu` 的 `kernel-4.19` 分支,把 SUSFS 源文件 + patch 应用到内核
4. 合并 [configs/sukisu.config](configs/sukisu.config) 到 defconfig
5. 用 AOSP clang (LLVM=1) 编译 `Image` / `dtb.img` / `dtbo.img`
6. 用 AnyKernel3 打包成可在 TWRP / OrangeFox 刷入的 zip

## 使用

1. 在 GitHub 新建仓库,把这个目录里的内容全部 push 上去
2. 进入仓库 → **Actions** → **Build SM8250 SukiSU-Ultra Kernel** → **Run workflow**
3. 选择参数:
   - `device`: 你的机型 codename
   - `kernel_repo`: 默认是 `Evolution-X-Devices/kernel_oneplus_sm8250`,如果 EvoX 没有为你的机型维护这棵树,可以换成 LineageOS 22.2 的 SM8250 tree(例如 `LineageOS/android_kernel_oneplus_sm8250`)
   - `kernel_branch`: 默认 `lineage-22.2`(对应 Android 16)
   - `enable_susfs`: 默认开启,关闭则只有 root 没有隐藏
   - `enable_lto`: 默认关闭,开启编译更慢但内核稍快
4. 编译完成后到 Run 页面下载 artifact zip

## 刷入流程

1. 备份当前 boot.img!
2. 第一次刷:线刷或在 Recovery 刷本 zip(替换 `boot` 分区的 Image)
3. 重启进系统,装 **SukiSU Manager** APK: https://github.com/SukiSU-Ultra/SukiSU-Ultra/releases
4. 打开 Manager 确认显示 "Working" 和 SUSFS 版本号
5. 在 Manager 里安装 **ZygiskNext** 模块: https://github.com/Dr-TSNG/ZygiskNext/releases (使用 SukiSU 适配版)
6. 重启,在 Manager 的 SuperUser 列表给需要 root 的 app 授权
7. 配置 SUSFS 隐藏(可用 KernelSU Next 风格的 `susfs` 命令行,或装第三方 GUI 模块)

## 隐藏检测说明

- **SUSFS** 处理挂载点、文件、kstat、uname、cmdline 等内核级痕迹
- **ZygiskNext** 处理用户空间的 Zygisk hook (用于 Shamiko / TrickyStore 等模块)
- 想过 Play Integrity 的 STRONG 还需要装 **TrickyStore** 模块并配置 keybox

## 常见问题

**Q: 编译失败,提示找不到 defconfig**
A: 不同 ROM 维护者的 defconfig 命名不一样。看 Action 日志里列出的 `arch/arm64/configs/` 文件列表,然后编辑 [.github/workflows/build-kernel.yml](.github/workflows/build-kernel.yml) 第 119 行附近,把你机型对应的 defconfig 加进去。

**Q: 编译失败,SUSFS patch 报 rejected**
A: SUSFS 的 4.19 patch 是针对上游 4.19 写的,downstream 内核常会冲突。在 [patches/](patches/) 放修复 patch,或手动编辑被拒绝的 `.rej` 文件后重新打包源码上传。

**Q: 刷完不开机**
A: 几乎都是 dtb / dtbo 不匹配。把 `anykernel.sh` 里 `do.devicecheck` 改成 0 测试,或者只刷 `Image`(在 AnyKernel3 里删掉 `dtb.img` 和 `dtbo.img`)。

**Q: SukiSU Manager 显示 "Not installed"**
A: 检查 defconfig 里 `CONFIG_KSU=y` 是否真的进了 `out/.config`。可能是合并 defconfig 时被同名 `# CONFIG_KSU is not set` 覆盖了 — 用 `scripts/config --enable KSU` 强制开启。

## 目录结构

```
.
├── .github/workflows/build-kernel.yml   # GitHub Actions 工作流
├── configs/
│   ├── sukisu.config                    # KSU + SUSFS defconfig 片段
│   └── lto.config                       # 可选 LTO 片段
├── anykernel/anykernel.sh               # AnyKernel3 安装脚本
├── patches/                             # 额外 .patch 文件(自动应用)
└── README.md
```

## 重要免责声明

- 这个工作流是个**起点模板**,不是即插即用的成品。SM8250 是 non-GKI,每个 ROM 维护者的 kernel tree 都略有差异,首次编译几乎一定会有 patch 冲突,需要你看 Action 日志逐个解决。
- 刷第三方内核会让 OTA 失效并可能触发硬件级 attestation 失败,刷之前务必备份 boot 分区。
- SukiSU-Ultra 和 SUSFS 都在快速迭代,如果上游分支改名(例如 `susfs-main` 变成别的),需要更新工作流里的对应字段。
