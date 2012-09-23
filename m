From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 2/4] devpts: Set the default permissions of /dev/pts/ptmx and
	/dev/ptmx to 0666
Date: Sat, 22 Sep 2012 20:49:37 -0700
Message-ID: <87ipb5760e.fsf_-_@xmission.com>
References: <20120124000517.GA28878@sergelap>
	<CA+55aFz9ofF+Ey8VCDS8UEf2XSw36kj2RhkHfFScuzLXMeNrkA@mail.gmail.com>
	<20120124002555.GA29534@sergelap>
	<CA+55aFzwOU137V6wtyBjessx05NJo2G4KV0rvTKWvC79A+o9iQ@mail.gmail.com>
	<20120124010758.GJ23916@ZenIV.linux.org.uk>
	<m1k44gj1cu.fsf@fess.ebiederm.org> <20120124220247.GA26353@hallyn.com>
	<CAPXgP13_gczQmG_USAp0p2AuTfxkzAvzHvjbZY_rbbLH-4rDyg@mail.gmail.com>
	<20120124231601.GA4470@sergelap>
	<CAPXgP12REAwmDORzdGJhsxZKU8nhiauCxoVdKa8Eifw4MWWtgA@mail.gmail.com>
	<20120128195103.GA11299@sergelap> <87txup763i.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87txup763i.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Sat, 22 Sep 2012 20:47:45 -0700")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Andy Whitcroft <apw-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Id: containers.vger.kernel.org


These are difference instances of the same device not so it only
makes sense that they would have the same default permissions.

Move the definitions of DEVPTS_DEEFAULT_PTMX_MODE and PTM_MINOR
into devpts_fs.h so we can use the same definitions throughout.

Acked-by: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 drivers/tty/pty.c         |    6 +++---
 drivers/tty/tty_io.c      |    5 +++--
 fs/devpts/inode.c         |    8 --------
 include/linux/devpts_fs.h |    3 +++
 4 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/drivers/tty/pty.c b/drivers/tty/pty.c
index 5505ffc..6beb7e1 100644
--- a/drivers/tty/pty.c
+++ b/drivers/tty/pty.c
@@ -722,10 +722,10 @@ static void __init unix98_pty_init(void)
 	ptmx_fops.open = ptmx_open;
 
 	cdev_init(&ptmx_cdev, &ptmx_fops);
-	if (cdev_add(&ptmx_cdev, MKDEV(TTYAUX_MAJOR, 2), 1) ||
-	    register_chrdev_region(MKDEV(TTYAUX_MAJOR, 2), 1, "/dev/ptmx") < 0)
+	if (cdev_add(&ptmx_cdev, MKDEV(TTYAUX_MAJOR, PTMX_MINOR), 1) ||
+	    register_chrdev_region(MKDEV(TTYAUX_MAJOR, PTMX_MINOR), 1, "/dev/ptmx") < 0)
 		panic("Couldn't register /dev/ptmx driver\n");
-	device_create(tty_class, NULL, MKDEV(TTYAUX_MAJOR, 2), NULL, "ptmx");
+	device_create(tty_class, NULL, MKDEV(TTYAUX_MAJOR, PTMX_MINOR), NULL, "ptmx");
 }
 
 #else
diff --git a/drivers/tty/tty_io.c b/drivers/tty/tty_io.c
index b425c79..6c3a7c2 100644
--- a/drivers/tty/tty_io.c
+++ b/drivers/tty/tty_io.c
@@ -3314,9 +3314,10 @@ static char *tty_devnode(struct device *dev, umode_t *mode)
 {
 	if (!mode)
 		return NULL;
-	if (dev->devt == MKDEV(TTYAUX_MAJOR, 0) ||
-	    dev->devt == MKDEV(TTYAUX_MAJOR, 2))
+	if (dev->devt == MKDEV(TTYAUX_MAJOR, 0))
 		*mode = 0666;
+	if (dev->devt == MKDEV(TTYAUX_MAJOR, PTMX_MINOR))
+		*mode = DEVPTS_DEFAULT_PTMX_MODE;
 	return NULL;
 }
 
diff --git a/fs/devpts/inode.c b/fs/devpts/inode.c
index 5f0d64e..61b54aa 100644
--- a/fs/devpts/inode.c
+++ b/fs/devpts/inode.c
@@ -27,14 +27,6 @@
 #include <linux/seq_file.h>
 
 #define DEVPTS_DEFAULT_MODE 0600
-/*
- * ptmx is a new node in /dev/pts and will be unused in legacy (single-
- * instance) mode. To prevent surprises in user space, set permissions of
- * ptmx to 0. Use 'chmod' or remount with '-o ptmxmode' to set meaningful
- * permissions.
- */
-#define DEVPTS_DEFAULT_PTMX_MODE 0000
-#define PTMX_MINOR	2
 
 /*
  * sysctl support for setting limits on the number of Unix98 ptys allocated.
diff --git a/include/linux/devpts_fs.h b/include/linux/devpts_fs.h
index 5ce0e5f..2d539ae 100644
--- a/include/linux/devpts_fs.h
+++ b/include/linux/devpts_fs.h
@@ -15,6 +15,9 @@
 
 #include <linux/errno.h>
 
+#define DEVPTS_DEFAULT_PTMX_MODE 0666
+#define PTMX_MINOR	2
+
 #ifdef CONFIG_UNIX98_PTYS
 
 int devpts_new_index(struct inode *ptmx_inode);
-- 
1.7.5.4
