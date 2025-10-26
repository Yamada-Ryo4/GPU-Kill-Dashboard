# gpu-kill 实时 Web 仪表板
> 为 `[kagehq/gpu-kill](https://github.com/kagehq/gpu-kill)` 打造的独立「Glass UI」风格实时网页仪表板。通过连接到 `gpukill --server`（默认 `ws://127.0.0.1:9998/ws`）获取 GPU 快照并以动态图表与卡片形式呈现。

---

## 主要特性 ✨

* **Glass UI（毛玻璃）界面**：现代、半透明的卡片与控件，轻盈优雅。
* **实时滚动图表**：使用 Chart.js + `chartjs-plugin-streaming` 呈现 GPU 利用率、显存、功耗、温度的历史曲线。
* **多节点支持（Multi-Node）**：同时展示多台主机的 GPU 数据，按主机名分组显示。
* **动态 UI**：自动检测并在页面上为新节点 / 新 GPU 动态创建卡片与图表数据集。
* **进程列表**：可展开查看占用该 GPU 的进程（PID、名称、显存占用）。
* **深色 / 浅色模式**：一键切换主题。

---

## 核心工作原理（重要）⚠️

`gpukill --server` 在启动时只会**打印一次当前 GPU 的快照**然后退出 —— 它并不是一个持续提供 WebSocket 流的长期服务。

为了解决这一点，本项目通过 `restart_gpukill.ps1`（配合 `1.bat`）实现“**强制重启循环**”：

1. 脚本启动 `gpukill --server`（监听 `:9998`）。
2. 前端 `index.html` 连接到该实例并拿到一次快照数据。
3. 脚本在短时间后强制终止 `gpukill`（释放端口）。
4. 前端 WS 连接断开并触发自动重连逻辑。
5. 脚本等待端口释放后再次启动 `gpukill`，前端重连并获取新的快照。
6. 周而复始 — 仪表板因此“模拟”出实时监控效果。

> 注意：这种方式会导致短暂断开（属于设计所致），并依赖脚本在后台不断循环重启 `gpukill`。

---

## 要求（Prerequisites）

* 已安装并可在命令行中全局调用的 `gpukill`（参见 `[kagehq/gpu-kill](https://github.com/kagehq/gpu-kill)` README）。
* Windows（推荐，脚本为 `.ps1` 与 `.bat`），或自行改写为适合你系统的重启脚本。
* 浏览器（支持 WebSocket 与 Canvas 的现代浏览器）。
* 端口默认：**TCP 9998**（确保防火墙允许访问，或按需修改脚本与页面中的 `WS_URL`）。

---

## 快速开始（本机监控）

1. 安装 `gpu-kill` 并确保 `gpukill` 在 PATH 中。
2. 双击或运行 `1.bat` —— 它会打开 PowerShell 执行 `restart_gpukill.ps1`，开始后台循环（不断启动/停止 `gpukill`）。
3. 用浏览器打开项目中的 `index (2).html`（网页会尝试连接 `ws://127.0.0.1:9998/ws` 并开始显示数据）。

页面成功加载后会出现短暂断开并重连的情况（这是预期行为，因为后端在重启）。

---

## 远程监控：在 A 电脑上查看 B 电脑的 GPU

**在被监控端（B 电脑）**：

* 在 B 电脑上放置并运行 `1.bat`（或直接运行 `restart_gpukill.ps1`），确保 `gpukill` 可用并允许监听本机 `9998`。
* 在防火墙上允许 TCP 端口 **9998** 的入站连接。

**在查看端（A 电脑）**：

* 打开 `index (2).html`，编辑 `WS_URL` 变量（在文件顶部 JS 中）：

```js
// 默认（本机）
const WS_URL = 'ws://127.0.0.1:9998/ws';

// 若要监控 B 电脑（把 [B_IP] 换成 B 电脑的实际 IP）
const WS_URL = 'ws://[B_IP]:9998/ws';
```

* 保存并在浏览器中打开修改后的 `index.html`。

---

## 文件说明

* `index.html` — 前端仪表板页面（包含所有 CSS/JS，直接用浏览器打开即可）。
* `restart_gpukill.ps1` — PowerShell 脚本：不断循环启动/停止 `gpukill`（实现“伪实时”）。
* `1.bat` — Windows 批处理，便捷地以 PowerShell 方式运行上面的脚本。

> 若需在 Linux 上运行，请将重启逻辑改写为 `bash` 或使用 systemd/docker 等替代方案。

---

## 配置项（你可能想改的）

* **WS_URL**：在 `index (2).html` 中修改（默认 `ws://127.0.0.1:9998/ws`）。
* **端口**：默认 `9998`，若修改后需同时修改脚本与页内的 `WS_URL`。
* **刷新 / 重启间隔**：由 `restart_gpukill.ps1` 控制（脚本中有等待时长）；缩短会更“实时”但更频繁地重启 `gpukill`。
* **图表滚动窗口**：Chart.js 插件里有 `duration`/`refresh` 等选项，可在 JS 中调整滚动长度与刷新频率。

---

## 已知限制与注意事项

* `gpukill --server` 本身不是持续 WebSocket 服务 —— 本项目通过重启循环来“模拟”实时，这会导致短暂断连。
* 对于非常严格或高频率的监控场景，此方法并非最优（建议寻找或实现一个持续运行的后端服务以提供连续数据流）。
* 如果防火墙或网络环境阻止端口连接，请在防火墙/路由器上放行 TCP 9998。
* 本仪表盘前端基于浏览器运行；大量节点与 GPU 会消耗浏览器内存与渲染资源，可能出现性能瓶颈。

---

## 故障排查（FAQ）

* **页面显示“正在等待 gpukill --server 启动…”且长时间无数据**：

  * 确认 `1.bat` / `restart_gpukill.ps1` 正在运行并成功启动 `gpukill`。
  * 确认 `gpukill` 可在命令行中手动运行并输出 JSON 快照。
  * 检查防火墙或端口占用（确保 9998 没被占用且允许连接）。

* **网页频繁报错 WebSocket 无法连接**：

  * 这是重启循环导致的短暂断连属于正常，若长时间重连失败，检查脚本是否已停止或 `gpukill` 是否崩溃。

* **图表没显示新 GPU 的数据**：

  * 仪表板会为每个新检测到的 `hostname_gpuIndex` 自动创建数据集，确认发送到前端的数据中包含 `nodes`、`hostname`、`gpus` 等字段（参照 `gpukill` 的输出结构）。

---

##  依赖

* 前端界面与数据可视化基于 `[kagehq/gpu-kill](https://github.com/kagehq/gpu-kill)` 的功能实现。
* 使用了：**Chart.js** 与 **chartjs-plugin-streaming**（用于历史滚动图表）。

---

## 贡献与许可


MIT Licences


> * 将 `restart_gpukill.ps1` 的核心逻辑改写为 Linux-friendly 的 `bash` 版本；
> * 或把 README 写成英文版 / 生成到项目根目录（如 `/mnt/data/README.md`）。
