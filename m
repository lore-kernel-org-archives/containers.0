From: <gregkh-l3A5Bk7waGM@public.gmane.org>
Subject: patch devpts_get_tty-should-validate-inode.patch added to gregkh-2.6
	tree
Date: Thu, 19 Nov 2009 15:59:25 -0800
Message-ID: <1258675165223@kroah.org>
References: <20091118023541.GA14430@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091118023541.GA14430-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org, root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org


This is a note to let you know that I've just added the patch titled

    Subject: devpts_get_tty() should validate inode

to my gregkh-2.6 tree.  Its filename is

    devpts_get_tty-should-validate-inode.patch

This tree can be found at 
    http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/


From sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org  Thu Nov 19 15:40:33 2009
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Tue, 17 Nov 2009 18:35:43 -0800
Subject: devpts_get_tty() should validate inode
To: gregkh-l3A5Bk7waGM@public.gmane.org
Cc: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Message-ID: <20091118023541.GA14430-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>


devpts_get_tty() assumes that the inode passed in is associated with a valid
pty.  But if the only reference to the pty is via a bind-mount, the inode
passed to devpts_get_tty() while valid, would refer to a pty that no longer
exists.

With a lot of debug effort, Grzegorz Nosek developed a small program (see
below) to reproduce a crash on recent kernels. This crash is a regression
introduced by the commit:

	commit 527b3e4773628b30d03323a2cb5fb0d84441990f
	Author: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
	Date:   Mon Oct 13 10:43:08 2008 +0100

To fix, ensure that the dentry associated with the inode has not yet been
deleted/unhashed by devpts_pty_kill().

See also:
https://lists.linux-foundation.org/pipermail/containers/2009-July/019273.html 

tty-bug.c:

#define _GNU_SOURCE
#include <fcntl.h>
#include <sched.h>
#include <stdlib.h>
#include <sys/mount.h>
#include <sys/signal.h>
#include <unistd.h>
#include <stdio.h>

#include <linux/fs.h>

void dummy(int sig)
{
}

static int child(void *unused)
{
	int fd;

	signal(SIGINT, dummy); signal(SIGHUP, dummy);
	pause(); /* cheesy synchronisation to wait for /dev/pts/0 to appear */

	mount("/dev/pts/0", "/dev/console", NULL, MS_BIND, NULL);
	sleep(2);

	fd = open("/dev/console", O_RDWR);
	dup(0); dup(0);
	write(1, "Hello world!\n", sizeof("Hello world!\n")-1);
	return 0;
}

int main(void)
{
	pid_t pid;
	char *stack;

	stack = malloc(16384);
	pid = clone(child, stack+16384, CLONE_NEWNS|SIGCHLD, NULL);

	open("/dev/ptmx", O_RDWR|O_NOCTTY|O_NONBLOCK);

	unlockpt(fd); grantpt(fd);

	sleep(2);
	kill(pid, SIGHUP);
	sleep(1);
	return 0; /* exit before child opens /dev/console */
}

Reported-by: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Tested-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: stable <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Signed-off-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>

---
 fs/devpts/inode.c |   16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -517,11 +517,23 @@ int devpts_pty_new(struct inode *ptmx_in
 
 struct tty_struct *devpts_get_tty(struct inode *pts_inode, int number)
 {
+	struct dentry *dentry;
+	struct tty_struct *tty;
+
 	BUG_ON(pts_inode->i_rdev == MKDEV(TTYAUX_MAJOR, PTMX_MINOR));
 
+	/* Ensure dentry has not been deleted by devpts_pty_kill() */
+	dentry = d_find_alias(pts_inode);
+	if (!dentry)
+		return NULL;
+
+	tty = NULL;
 	if (pts_inode->i_sb->s_magic == DEVPTS_SUPER_MAGIC)
-		return (struct tty_struct *)pts_inode->i_private;
-	return NULL;
+		tty = (struct tty_struct *)pts_inode->i_private;
+
+	dput(dentry);
+
+	return tty;
 }
 
 void devpts_pty_kill(struct tty_struct *tty)
