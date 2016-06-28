From: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 0/3 v2] fs: allow to use dirfd as root for openat and other
	*at syscalls
Date: Tue, 28 Jun 2016 10:38:27 -0700
Message-ID: <1467135510-2564-1-git-send-email-avagin@openvz.org>
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
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "J. Bruce Fields" <bfields-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>, criu-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

The problem is that a pathname can contain absolute symlinks and now
they are resolved relative to the current root.

It may be a problem if you want to open a file in another namespace.
For example, you open /proc/PID/root for a process from the target
namespace and then you use openat() to open a file from this namespace.

If a path to the file contains an absolute symlink, you will open a file
from the current namespace, because a symlink will be resolved relative
to the current root.

A proposed solution adds a new flag which means that dirfd should be
set as a root for a current system call (openat(), statat(), etc).

Here are examples how we can open a file in a contex of another process.

How we can do this without these changes:

	old_root = open("/", O_PATH);
	old_cwd = open(".", O_PATH);
	chroot("/proc/PID/root");

	fd = open(pathname, O_RDONLY);

	fchdir(old_root); /* emulate fchroot() */
	chroot(".");
	fchdir(old_cwd);

	close(old_cwd);
	close(old_root);

How this code is simplified with new flags:
	dirfd = open("/proc/PID/root", O_PATH);
	fd = open(dirfd, pathname, O_RDONLY | O_ATROOT);
	close(dirfd);

One more thing is that chroot isn't available for unprivileged users.

We met this problem, when we tryed to dump an ubuntu container and
failed to resolve /proc/PID/root/var/run/mysqld/mysqld.sock, because
/var/run was a symlink to /run.

Changes since the first version:
- change a value of O_ATROOT to not intersect with other constants. 

Cc: Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Cc: "J. Bruce Fields" <bfields-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>
Cc: Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Signed-off-by: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

Andrey Vagin (3):
  namei: add LOOKUP_DFD_ROOT to use dfd as root
  fs: allow to use dirfd as root for openat and other *at syscalls
  selftests: check O_ATROOT and AT_FDROOT flags

 fs/exec.c                                       |  4 +-
 fs/namei.c                                      | 22 ++++++--
 fs/open.c                                       |  6 ++-
 fs/stat.c                                       |  4 +-
 fs/utimes.c                                     |  4 +-
 include/linux/namei.h                           |  2 +
 include/uapi/asm-generic/fcntl.h                |  4 ++
 include/uapi/linux/fcntl.h                      |  1 +
 tools/testing/selftests/Makefile                |  1 +
 tools/testing/selftests/lookup/.gitignore       |  1 +
 tools/testing/selftests/lookup/Makefile         |  8 +++
 tools/testing/selftests/lookup/lookup_at_root.c | 69 +++++++++++++++++++++++++
 tools/testing/selftests/lookup/run.sh           | 14 +++++
 13 files changed, 131 insertions(+), 9 deletions(-)
 create mode 100644 tools/testing/selftests/lookup/.gitignore
 create mode 100644 tools/testing/selftests/lookup/Makefile
 create mode 100644 tools/testing/selftests/lookup/lookup_at_root.c
 create mode 100755 tools/testing/selftests/lookup/run.sh

-- 
2.5.5
