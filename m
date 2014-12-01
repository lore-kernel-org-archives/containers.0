From: Chen Hanxiao <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH v9 0/3] ns,
	procfs: pid conversion between ns and showing pidns hierarchy
Date: Mon, 1 Dec 2014 19:06:15 +0800
Message-ID: <1417431978-24723-1-git-send-email-chenhanxiao@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Richard Weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mateusz Guzik <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

This series will expose pid inside containers
via procfs.
Also show the hierarchy of pid namespcae.
Then we could know how pid looks inside a container
and their ns relationships.

1. helpful for nested container check/restore
From /proc/PID/ns/pid, we could know whether two pid lived
in the same ns.
From this patch, we could know whether two pid had relationship
between each other.

2. used for pid translation from container
Ex:
     init_pid_ns    ns1         ns2
 t1  2
 t2   `- 3          1
 t3   `- 4          3
 t4       `- 5      `- 5        1
 t5       `- 6      `- 8        3

It could solve problems like: we see a pid 3 goes wrong
in container's log, what is its pid on hosts:
a) inside container:
# readlink /proc/3/ns/pid
pid:[4026532388]

b) on host:
We show it in the form of :
<init_PID> <parent_of_init_PID> <relative PID level>

# cat /proc/pidns_hierarchy
14918 1 1
16263 14918 2
16581 1 1
Then we could easily find /proc/16263/ns/pid->4026532388.
On host, we knew that reported pid 3 is in level 2,
   and its parental pid ns is from pid 14918.

c) on host, check child of 16263, grep it from status:
NSpid:  16268   8       3

We knew that pid 16268 is pid 3 reported by container.

v9: fix codes be inluded if CONFIG_PID_NS=n
v8: fix some improper comments
    use max() from kernel.h
v7: change stype to be consistent with current interface like
    <init_PID> <parent_of_init_PID> <relative PID level>
    remove EXPERT dependent in Kconfig
v6: fix some get_pid leaks and do some cleanups
v5: collect pid by find_ge_pid;
    use local list inside nslist_proc_show;
    use get_pid, remove mutex lock.
v4: simplify pid collection and some performance optimizamtion
    fix another race issue.
v3: fix a race issue and memory leak issue in pidns_hierarchy;
    add another two fielsd: NSpgid and NSsid.
v2: use a procfs text file instead of dirs under /proc for
    showing pidns hierarchy;
    add two new fields: NStgid and NSpid
    keep fields of Tgid and Pid unchanged for back compatibility.

Chen Hanxiao (3):
  procfs: show hierarchy of pid namespace
  /proc/PID/status: show all sets of pid according to ns
  Documentation: add docs for /proc/pidns_hierarchy

 Documentation/namespaces/pidns-hierarchy.txt |  51 +++++
 fs/proc/Kconfig                              |   6 +
 fs/proc/Makefile                             |   1 +
 fs/proc/array.c                              |  17 ++
 fs/proc/internal.h                           |   9 +
 fs/proc/pidns_hierarchy.c                    | 280 +++++++++++++++++++++++++++
 fs/proc/root.c                               |   1 +
 7 files changed, 365 insertions(+)
 create mode 100644 Documentation/namespaces/pidns-hierarchy.txt
 create mode 100644 fs/proc/pidns_hierarchy.c

-- 
1.9.3
