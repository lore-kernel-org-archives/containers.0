From: Chen Hanxiao <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [RFC PATCH 0/3] ns,
	procfs: pid conversion between ns and showing pidns hierarchy
Date: Wed, 3 Sep 2014 18:29:57 +0800
Message-ID: <1409740200-26461-1-git-send-email-chenhanxiao@cn.fujitsu.com>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Richard Weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

This series will expose pid inside containers
via procfs.
Also show the hierarchy of pid namespcae.
Then we could know how pid looks inside a container
and their ns relationships.

Chen Hanxiao (3):
  procfs: check uniq proc_dir_entry subdir name
  procfs: show hierarchy of pid namespace
  /proc/pid/status: show all sets of pid according to ns

 fs/proc/Kconfig           |   6 ++
 fs/proc/Makefile          |   1 +
 fs/proc/array.c           |  17 +++++
 fs/proc/generic.c         |  15 +++++
 fs/proc/pidns_hierarchy.c | 161 ++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/proc_fs.h   |   3 +
 6 files changed, 203 insertions(+)
 create mode 100644 fs/proc/pidns_hierarchy.c

-- 
1.9.0
