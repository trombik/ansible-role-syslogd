# `trombik.syslogd`

The role manages BSD `syslogd`.

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `syslogd_user` | User name of `syslogd` | `{{ __syslogd_user }}` |
| `syslogd_group` | Group name of `syslogd` | `{{ __syslogd_group }}` |
| `syslogd_log_dir` | Log directory | `/var/log` |
| `syslogd_service` | Service name of `syslogd` | `{{ __syslogd_service }}` |
| `syslogd_conf_dir` | Path to config directory | `{{ __syslogd_conf_dir }}` |
| `syslogd_conf_file` | Path to configuration file | `{{ syslogd_conf_dir }}/syslog.conf` |
| `syslogd_conf_d_dirs` | A list of directories for `syslogd_config_flagments`. Usually, the directories are `included` in `syslog.conf` when supported by `syslogd`. | `{{ __syslogd_conf_d_dirs }}` |
| `syslogd_config` | Content of `syslogd_conf_file` | `""` |
| `syslogd_config_flagments` | See below | `[]` |
| `syslogd_flags` | Flags for `syslogd` service | `""` |

## `syslogd_config_flagments`

This variable is a list of dict. The following keys are accepted.

| Key | Description | Mandatory? |
|-----|-------------|------------|
| `path` | Path to the file | yes |
| `state` | State of the file. The file is created when `present`, removed when `absent` | yes |
| `mode` | Permission of the file. Default is `0644` | no |

## FreeBSD

| Variable | Default |
|----------|---------|
| `__syslogd_user` | `root` |
| `__syslogd_group` | `wheel` |
| `__syslogd_service` | `syslogd` |
| `__syslogd_conf_dir` | `/etc` |
| `__syslogd_conf_d_dirs` | `["/etc/syslog.d", "/usr/local/etc/syslog.d"]` |

## OpenBSD

| Variable | Default |
|----------|---------|
| `__syslogd_user` | `root` |
| `__syslogd_group` | `wheel` |
| `__syslogd_service` | `syslogd` |
| `__syslogd_conf_dir` | `/etc` |
| `__syslogd_conf_d_dirs` | `[]` |

# Dependencies

None

# Example Playbook

```yaml
---
- hosts: localhost
  roles:
    - ansible-role-syslogd
  vars:
    os_syslogd_config:
      FreeBSD: |
        # $FreeBSD$
        #
        #	Spaces ARE valid field separators in this file. However,
        #	other *nix-like systems still insist on using tabs as field
        #	separators. If you are sharing this file between systems, you
        #	may want to use only tabs as field separators here.
        #	Consult the syslog.conf(5) manpage.
        *.err;kern.warning;auth.notice;mail.crit		/dev/console
        *.notice;authpriv.none;kern.debug;lpr.info;mail.crit;news.err	/var/log/messages
        security.*					/var/log/security
        auth.info;authpriv.info				/var/log/auth.log
        mail.info					/var/log/maillog
        cron.*						/var/log/cron
        !-devd
        *.=debug					/var/log/debug.log
        *.emerg						*
        daemon.info					/var/log/daemon.log
        # uncomment this to log all writes to /dev/console to /var/log/console.log
        # touch /var/log/console.log and chmod it to mode 600 before it will work
        #console.info					/var/log/console.log
        # uncomment this to enable logging of all log messages to /var/log/all.log
        # touch /var/log/all.log and chmod it to mode 600 before it will work
        #*.*						/var/log/all.log
        # uncomment this to enable logging to a remote loghost named loghost
        #*.*						@loghost
        # uncomment these if you're running inn
        # news.crit					/var/log/news/news.crit
        # news.err					/var/log/news/news.err
        # news.notice					/var/log/news/news.notice
        # Uncomment this if you wish to see messages produced by devd
        # !devd
        # *.>=notice					/var/log/devd.log
        !*
        include						/etc/syslog.d
        include						/usr/local/etc/syslog.d
      OpenBSD: |
        #	$OpenBSD: syslog.conf,v 1.20 2016/12/27 13:38:14 jca Exp $
        #

        *.notice;auth,authpriv,cron,ftp,kern,lpr,mail,user.none	/var/log/messages
        kern.debug;syslog,user.info				/var/log/messages
        auth.info						/var/log/authlog
        authpriv.debug						/var/log/secure
        cron.info						/var/cron/log
        daemon.info						/var/log/daemon
        ftp.info						/var/log/xferlog
        lpr.debug						/var/log/lpd-errs
        mail.info						/var/log/maillog

        # Uncomment this line to send "important" messages to the system
        # console: be aware that this could create lots of output.
        #*.err;auth.notice;authpriv.none;kern.debug;mail.crit	/dev/console

        # Uncomment this to have all messages of notice level and higher
        # as well as all authentication messages sent to root.
        #*.notice;auth.debug					root

        # Everyone gets emergency messages.
        #*.emerg							*

        # Uncomment to log to a central host named "loghost".  You need to run
        # syslogd with the -u option on the remote host if you are using this.
        # (This is also required to log info from things like routers and
        # ISDN-equipment).  If you run -u, you are vulnerable to syslog bombing,
        # and should consider blocking external syslog packets.
        #*.notice;auth,authpriv,cron,ftp,kern,lpr,mail,user.none	@loghost
        #auth,daemon,syslog,user.info;authpriv,kern.debug		@loghost

        # Uncomment to log messages from doas(1) to its own log file.  Matches are done
        # based on the program name.
        # Program-specific logs:
        #!doas
        #*.*							/var/log/doas

    syslogd_config: "{{ os_syslogd_config[ansible_os_family] }}"
    os_syslogd_flags:
      FreeBSD: |
        syslogd_flags="-s"
      OpenBSD: ""
    syslogd_flags: "{{ os_syslogd_flags[ansible_os_family] }}"
    os_syslogd_config_flagments:
      OpenBSD: []
      FreeBSD:
        - path: /usr/local/etc/syslog.d/foo.conf
          mode: "0775"
          state: present
          content: |
            # empty
    syslogd_config_flagments: "{{ os_syslogd_config_flagments[ansible_os_family] }}"

```

# License

```
Copyright (c) 2021 Tomoyuki Sakurai <y@trombik.org>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <y@trombik.org>

This README was created by [qansible](https://github.com/trombik/qansible)
