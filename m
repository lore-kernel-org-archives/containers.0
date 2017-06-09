From: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Subject: Fwd: patch "tty: add TIOCGPTPEER ioctl" added to tty-next
Date: Sat, 10 Jun 2017 04:39:39 +1000
Message-ID: <f4e9333e-246e-036b-bacf-d1eb881b606d@suse.de>
References: <149703175016723@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <149703175016723-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Just a heads up to any container runtime developers (I forgot to Cc this 
list), I added a new tty_ioctl that will make it possible for userspace 
processes to safely avoid the whole "is /dev/ trustworthy" problem when 
it comes to potentially hostile namespaces.

I would recommend using this if you can (and you've implemented pty 
creation inside the container with nsenter or similar functionality). If 
any of you are going to Linux Plumbers, Christian Brauner and myself 
will (likely) be talking about a whole class of similar problems when 
trying to write a runtime that is secure against hostile containers and 
how we can work to fix them as well.

-------- Forwarded Message --------
Subject: patch "tty: add TIOCGPTPEER ioctl" added to tty-next
Date: Fri, 09 Jun 2017 20:09:10 +0200
From: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org
To: asarai-l3A5Bk7waGM@public.gmane.org, christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, 
gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, vrothberg-IBi9RG/b67k@public.gmane.org


This is a note to let you know that I've just added the patch titled

     tty: add TIOCGPTPEER ioctl

to my tty git tree which can be found at
     git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/tty.git
in the tty-next branch.

The patch will show up in the next release of the linux-next tree
(usually sometime within the next 24 hours during the week.)

The patch will also be merged in the next major kernel release
during the merge window.

If you have any questions about this process, please let me know.


 From 54ebbfb1603415d9953c150535850d30609ef077 Mon Sep 17 00:00:00 2001
From: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Date: Sun, 4 Jun 2017 00:15:15 +1000
Subject: tty: add TIOCGPTPEER ioctl

When opening the slave end of a PTY, it is not possible for userspace to
safely ensure that /dev/pts/$num is actually a slave (in cases where the
mount namespace in which devpts was mounted is controlled by an
untrusted process). In addition, there are several unresolvable
race conditions if userspace were to attempt to detect attacks through
stat(2) and other similar methods [in addition it is not clear how
userspace could detect attacks involving FUSE].

Resolve this by providing an interface for userpace to safely open the
"peer" end of a PTY file descriptor by using the dentry cached by
devpts. Since it is not possible to have an open master PTY without
having its slave exposed in /dev/pts this interface is safe. This
interface currently does not provide a way to get the master pty (since
it is not clear whether such an interface is safe or even useful).

Cc: Christian Brauner <christian.brauner-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: Valentin Rothberg <vrothberg-IBi9RG/b67k@public.gmane.org>
Signed-off-by: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Signed-off-by: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
---
  arch/alpha/include/uapi/asm/ioctls.h   |  1 +
  arch/mips/include/uapi/asm/ioctls.h    |  1 +
  arch/parisc/include/uapi/asm/ioctls.h  |  1 +
  arch/powerpc/include/uapi/asm/ioctls.h |  1 +
  arch/sh/include/uapi/asm/ioctls.h      |  1 +
  arch/sparc/include/uapi/asm/ioctls.h   |  3 +-
  arch/xtensa/include/uapi/asm/ioctls.h  |  1 +
  drivers/tty/pty.c                      | 71 
++++++++++++++++++++++++++++++++--
  include/uapi/asm-generic/ioctls.h      |  1 +
  9 files changed, 76 insertions(+), 5 deletions(-)

diff --git a/arch/alpha/include/uapi/asm/ioctls.h 
b/arch/alpha/include/uapi/asm/ioctls.h
index f30c94ae1bdb..ff67b8373bf7 100644
--- a/arch/alpha/include/uapi/asm/ioctls.h
+++ b/arch/alpha/include/uapi/asm/ioctls.h
@@ -100,6 +100,7 @@
  #define TIOCGPKT	_IOR('T', 0x38, int) /* Get packet mode state */
  #define TIOCGPTLCK	_IOR('T', 0x39, int) /* Get Pty lock state */
  #define TIOCGEXCL	_IOR('T', 0x40, int) /* Get exclusive mode state */
+#define TIOCGPTPEER	_IOR('T', 0x41, int) /* Safely open the slave */
   #define TIOCSERCONFIG	0x5453
  #define TIOCSERGWILD	0x5454
diff --git a/arch/mips/include/uapi/asm/ioctls.h 
b/arch/mips/include/uapi/asm/ioctls.h
index 740219c2c894..68e19b689a00 100644
--- a/arch/mips/include/uapi/asm/ioctls.h
+++ b/arch/mips/include/uapi/asm/ioctls.h
@@ -91,6 +91,7 @@
  #define TIOCGPKT	_IOR('T', 0x38, int) /* Get packet mode state */
  #define TIOCGPTLCK	_IOR('T', 0x39, int) /* Get Pty lock state */
  #define TIOCGEXCL	_IOR('T', 0x40, int) /* Get exclusive mode state */
+#define TIOCGPTPEER	_IOR('T', 0x41, int) /* Safely open the slave */
   /* I hope the range from 0x5480 on is free ... */
  #define TIOCSCTTY	0x5480		/* become controlling tty */
diff --git a/arch/parisc/include/uapi/asm/ioctls.h 
b/arch/parisc/include/uapi/asm/ioctls.h
index b6572f051b67..674c68a5bbd0 100644
--- a/arch/parisc/include/uapi/asm/ioctls.h
+++ b/arch/parisc/include/uapi/asm/ioctls.h
@@ -60,6 +60,7 @@
  #define TIOCGPKT	_IOR('T', 0x38, int) /* Get packet mode state */
  #define TIOCGPTLCK	_IOR('T', 0x39, int) /* Get Pty lock state */
  #define TIOCGEXCL	_IOR('T', 0x40, int) /* Get exclusive mode state */
+#define TIOCGPTPEER	_IOR('T', 0x41, int) /* Safely open the slave */
   #define FIONCLEX	0x5450  /* these numbers need to be adjusted. */
  #define FIOCLEX		0x5451
diff --git a/arch/powerpc/include/uapi/asm/ioctls.h 
b/arch/powerpc/include/uapi/asm/ioctls.h
index 49a25796a61a..bfd609a3e928 100644
--- a/arch/powerpc/include/uapi/asm/ioctls.h
+++ b/arch/powerpc/include/uapi/asm/ioctls.h
@@ -100,6 +100,7 @@
  #define TIOCGPKT	_IOR('T', 0x38, int) /* Get packet mode state */
  #define TIOCGPTLCK	_IOR('T', 0x39, int) /* Get Pty lock state */
  #define TIOCGEXCL	_IOR('T', 0x40, int) /* Get exclusive mode state */
+#define TIOCGPTPEER	_IOR('T', 0x41, int) /* Safely open the slave */
   #define TIOCSERCONFIG	0x5453
  #define TIOCSERGWILD	0x5454
diff --git a/arch/sh/include/uapi/asm/ioctls.h 
b/arch/sh/include/uapi/asm/ioctls.h
index c9903e56ccf4..eec7901e9e65 100644
--- a/arch/sh/include/uapi/asm/ioctls.h
+++ b/arch/sh/include/uapi/asm/ioctls.h
@@ -93,6 +93,7 @@
  #define TIOCGPKT	_IOR('T', 0x38, int) /* Get packet mode state */
  #define TIOCGPTLCK	_IOR('T', 0x39, int) /* Get Pty lock state */
  #define TIOCGEXCL	_IOR('T', 0x40, int) /* Get exclusive mode state */
+#define TIOCGPTPEER	_IOR('T', 0x41, int) /* Safely open the slave */
   #define TIOCSERCONFIG	_IO('T', 83) /* 0x5453 */
  #define TIOCSERGWILD	_IOR('T', 84,  int) /* 0x5454 */
diff --git a/arch/sparc/include/uapi/asm/ioctls.h 
b/arch/sparc/include/uapi/asm/ioctls.h
index 06b3f6c3bb9a..6d27398632ea 100644
--- a/arch/sparc/include/uapi/asm/ioctls.h
+++ b/arch/sparc/include/uapi/asm/ioctls.h
@@ -27,7 +27,7 @@
  #define TIOCGRS485	_IOR('T', 0x41, struct serial_rs485)
  #define TIOCSRS485	_IOWR('T', 0x42, struct serial_rs485)
  -/* Note that all the ioctls that are not available in Linux have a 
+/* Note that all the ioctls that are not available in Linux have a
   * double underscore on the front to: a) avoid some programs to
   * think we support some ioctls under Linux (autoconfiguration stuff)
   */
@@ -88,6 +88,7 @@
  #define TIOCGPTN	_IOR('t', 134, unsigned int) /* Get Pty Number */
  #define TIOCSPTLCK	_IOW('t', 135, int) /* Lock/unlock PTY */
  #define TIOCSIG		_IOW('t', 136, int) /* Generate signal on Pty slave */
+#define TIOCGPTPEER	_IOR('t', 137, int) /* Safely open the slave */
   /* Little f */
  #define FIOCLEX		_IO('f', 1)
diff --git a/arch/xtensa/include/uapi/asm/ioctls.h 
b/arch/xtensa/include/uapi/asm/ioctls.h
index 518954e74e6d..98b004e24e85 100644
--- a/arch/xtensa/include/uapi/asm/ioctls.h
+++ b/arch/xtensa/include/uapi/asm/ioctls.h
@@ -105,6 +105,7 @@
  #define TIOCGPKT	_IOR('T', 0x38, int) /* Get packet mode state */
  #define TIOCGPTLCK	_IOR('T', 0x39, int) /* Get Pty lock state */
  #define TIOCGEXCL	_IOR('T', 0x40, int) /* Get exclusive mode state */
+#define TIOCGPTPEER	_IOR('T', 0x41, int) /* Safely open the slave */
   #define TIOCSERCONFIG	_IO('T', 83)
  #define TIOCSERGWILD	_IOR('T', 84,  int)
diff --git a/drivers/tty/pty.c b/drivers/tty/pty.c
index 2a6bd9ae3f8b..d1399aac05a1 100644
--- a/drivers/tty/pty.c
+++ b/drivers/tty/pty.c
@@ -24,6 +24,9 @@
  #include <linux/slab.h>
  #include <linux/mutex.h>
  #include <linux/poll.h>
+#include <linux/mount.h>
+#include <linux/file.h>
+#include <linux/ioctl.h>
   #undef TTY_DEBUG_HANGUP
  #ifdef TTY_DEBUG_HANGUP
@@ -66,8 +69,13 @@ static void pty_close(struct tty_struct *tty, struct 
file *filp)
  #ifdef CONFIG_UNIX98_PTYS
  		if (tty->driver == ptm_driver) {
  			mutex_lock(&devpts_mutex);
-			if (tty->link->driver_data)
-				devpts_pty_kill(tty->link->driver_data);
+			if (tty->link->driver_data) {
+				struct path *path = tty->link->driver_data;
+
+				devpts_pty_kill(path->dentry);
+				path_put(path);
+				kfree(path);
+			}
  			mutex_unlock(&devpts_mutex);
  		}
  #endif
@@ -440,6 +448,48 @@ static int pty_common_install(struct tty_driver 
*driver, struct tty_struct *tty,
  	return retval;
  }
  +/**
+ *	pty_open_peer - open the peer of a pty
+ *	@tty: the peer of the pty being opened
+ *
+ *	Open the cached dentry in tty->link, providing a safe way for userspace
+ *	to get the slave end of a pty (where they have the master fd and cannot
+ *	access or trust the mount namespace /dev/pts was mounted inside).
+ */
+static struct file *pty_open_peer(struct tty_struct *tty, int flags)
+{
+	if (tty->driver->subtype != PTY_TYPE_MASTER)
+		return ERR_PTR(-EIO);
+	return dentry_open(tty->link->driver_data, flags, current_cred());
+}
+
+static int pty_get_peer(struct tty_struct *tty, int flags)
+{
+	int fd = -1;
+	struct file *filp = NULL;
+	int retval = -EINVAL;
+
+	fd = get_unused_fd_flags(0);
+	if (fd < 0) {
+		retval = fd;
+		goto err;
+	}
+
+	filp = pty_open_peer(tty, flags);
+	if (IS_ERR(filp)) {
+		retval = PTR_ERR(filp);
+		goto err_put;
+	}
+
+	fd_install(fd, filp);
+	return fd;
+
+err_put:
+	put_unused_fd(fd);
+err:
+	return retval;
+}
+
  static void pty_cleanup(struct tty_struct *tty)
  {
  	tty_port_put(tty->port);
@@ -613,6 +663,8 @@ static int pty_unix98_ioctl(struct tty_struct *tty,
  		return pty_get_pktmode(tty, (int __user *)arg);
  	case TIOCGPTN: /* Get PT Number */
  		return put_user(tty->index, (unsigned int __user *)arg);
+	case TIOCGPTPEER: /* Open the other end */
+		return pty_get_peer(tty, (int) arg);
  	case TIOCSIG:    /* Send signal to other side of pty */
  		return pty_signal(tty, (int) arg);
  	}
@@ -740,6 +792,7 @@ static int ptmx_open(struct inode *inode, struct 
file *filp)
  {
  	struct pts_fs_info *fsi;
  	struct tty_struct *tty;
+	struct path *pts_path;
  	struct dentry *dentry;
  	int retval;
  	int index;
@@ -793,16 +846,26 @@ static int ptmx_open(struct inode *inode, struct 
file *filp)
  		retval = PTR_ERR(dentry);
  		goto err_release;
  	}
-	tty->link->driver_data = dentry;
+	/* We need to cache a fake path for TIOCGPTPEER. */
+	pts_path = kmalloc(sizeof(struct path), GFP_KERNEL);
+	if (!pts_path)
+		goto err_release;
+	pts_path->mnt = filp->f_path.mnt;
+	pts_path->dentry = dentry;
+	path_get(pts_path);
+	tty->link->driver_data = pts_path;
   	retval = ptm_driver->ops->open(tty, filp);
  	if (retval)
-		goto err_release;
+		goto err_path_put;
   	tty_debug_hangup(tty, "opening (count=%d)\n", tty->count);
   	tty_unlock(tty);
  	return 0;
+err_path_put:
+	path_put(pts_path);
+	kfree(pts_path);
  err_release:
  	tty_unlock(tty);
  	// This will also put-ref the fsi
diff --git a/include/uapi/asm-generic/ioctls.h 
b/include/uapi/asm-generic/ioctls.h
index 143dacbb7d9a..06d5f7ddf84e 100644
--- a/include/uapi/asm-generic/ioctls.h
+++ b/include/uapi/asm-generic/ioctls.h
@@ -77,6 +77,7 @@
  #define TIOCGPKT	_IOR('T', 0x38, int) /* Get packet mode state */
  #define TIOCGPTLCK	_IOR('T', 0x39, int) /* Get Pty lock state */
  #define TIOCGEXCL	_IOR('T', 0x40, int) /* Get exclusive mode state */
+#define TIOCGPTPEER	_IOR('T', 0x41, int) /* Safely open the slave */
   #define FIONCLEX	0x5450
  #define FIOCLEX		0x5451
-- 
2.13.1




-- 
Aleksa Sarai
Software Engineer (Containers)
SUSE Linux GmbH
https://www.cyphar.com/
