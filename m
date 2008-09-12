From: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 10/10] Document usage of multiple-instances of devpts
Date: Fri, 12 Sep 2008 10:53:47 -0700
Message-ID: <20080912175347.GK17350@us.ibm.com>
References: <20080912174845.GA17350@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080912174845.GA17350-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org


From 6d2fe9386880157f871667077db3180e9f0083a1 Mon Sep 17 00:00:00 2001
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Tue, 9 Sep 2008 10:43:50 -0700
Subject: [PATCH 10/10] Document usage of multiple-instances of devpts

Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 Documentation/filesystems/devpts.txt |  122 ++++++++++++++++++++++++++++++++++
 1 files changed, 122 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/filesystems/devpts.txt

diff --git a/Documentation/filesystems/devpts.txt b/Documentation/filesystems/devpts.txt
new file mode 100644
index 0000000..93d9d01
--- /dev/null
+++ b/Documentation/filesystems/devpts.txt
@@ -0,0 +1,122 @@
+
+To support containers, we now allow multiple instances of devpts filesystem,
+such that indices of ptys allocated in one instance are independent of indices
+allocated in other instances of devpts.
+
+To preserve backward compatibility, this support for multiple instances is
+enabled only if:
+
+	- CONFIG_DEVPTS_MULTIPLE_INSTANCES=y, and
+	- '-o newinstance' mount option is specified while mounting devpts
+
+IOW, devpts now supports both single-instance and multi-instance semantics.
+
+If CONFIG_DEVPTS_MULTIPLE_INSTANCES=n, there is no change in behavior and
+this referred to as the "legacy" mode. In this mode, the new mount options
+(-o newinstance and -o ptmxmode) will be ignored with a 'bogus option' message
+on console.
+
+If CONFIG_DEVPTS_MULTIPLE_INSTANCES=y and devpts is mounted without the
+'newinstance' option (as in current start-up scripts) the new mount binds
+to the initial kernel mount of devpts. This mode is referred to as the
+'single-instance' mode and the current, single-instance semantics are
+preserved, i.e PTYs are common across the system.
+
+The only difference between this single-instance mode and the legacy mode
+is the presence of new, '/dev/pts/ptmx' node with permissions 0000, which
+can safely be ignored.
+
+If CONFIG_DEVPTS_MULTIPLE_INSTANCES=y and 'newinstance' option is specified,
+the mount is considered to be in the multi-instance mode and a new instance
+of the devpts fs is created. Any ptys created in this instance are independent
+of ptys in other instances of devpts. Like in the single-instance mode, the
+/dev/pts/ptmx node is present. To effectively use the multi-instance mode,
+open of /dev/ptmx must be a redirected to '/dev/pts/ptmx' using a symlink or
+bind-mount.
+
+Eg: A container startup script could do the following:
+
+	$ chmod 0666 /dev/pts/ptmx
+	$ rm /dev/ptmx
+	$ ln -s pts/ptmx /dev/ptmx
+	$ ns_exec -cm /bin/bash
+
+	# We are now in new container
+
+	$ umount /dev/pts
+	$ mount -t devpts -o newinstance lxcpts /dev/pts
+	$ sshd -p 1234
+
+where 'ns_exec -cm /bin/bash' calls clone() with CLONE_NEWNS flag and execs
+/bin/bash in the child process.  A pty created by the sshd is not visible in
+the original mount of /dev/pts.
+
+User-space changes
+------------------
+
+In multi-instance mode (i.e '-o newinstance' mount option is specified at least
+once), following user-space issues should be noted.
+
+1. If -o newinstance mount option is never used, /dev/pts/ptmx can be ignored
+   and no change is needed to system-startup scripts.
+
+2. To effectively use multi-instance mode (i.e -o newinstance is specified)
+   administrators or startup scripts should "redirect" open of /dev/ptmx to
+   /dev/pts/ptmx using either a bind mount or symlink.
+
+	$ mount -t devpts -o newinstance devpts /dev/pts
+
+   followed by either
+
+	$ rm /dev/ptmx
+	$ ln -s pts/ptmx /dev/ptmx
+	$ chmod 666 /dev/pts/ptmx
+   or
+	$ mount -o bind /dev/pts/ptmx /dev/ptmx
+
+3. The '/dev/ptmx -> pts/ptmx' symlink is the preferred method since it
+   enables better error-reporting and treats both single-instance and
+   multi-instance mounts similarly.
+
+   But this method requires that system-startup scripts set the mode of
+   /dev/pts/ptmx correctly (default mode is 0000). The scripts can set the
+   mode by, either
+
+   	- adding ptmxmode mount option to devpts entry in /etc/fstab, or
+	- using 'chmod 0666 /dev/pts/ptmx'
+
+4. If multi-instance mode mount is needed for containers, but the system
+   startup scripts have not yet been updated, container-startup scripts
+   should bind mount /dev/ptmx to /dev/pts/ptmx to avoid breaking single-
+   instance mounts.
+
+   Or, in general, container-startup scripts should use:
+
+	mount -t devpts -o newinstance -o ptmxmode 0666 devpts /dev/pts
+	if [ ! -L /dev/ptmx ]; then
+		mount -o bind /dev/pts/ptmx /dev/ptmx
+	fi
+
+   When all devpts mounts are multi-instance, /dev/ptmx can permanently be
+   a symlink to pts/ptmx and the bind mount can be ignored.
+
+5. A multi-instance mount that is not accompanied by the /dev/ptmx to
+   /dev/pts/ptmx redirection would result in an unusable/unreachable pty.
+
+	mount -t devpts -o newinstance lxcpts /dev/pts
+
+   immediately followed by:
+
+	open("/dev/ptmx")
+
+    would create a pty, say /dev/pts/7, in the initial kernel mount.
+    But /dev/pts/7 would be invisible in the new mount.
+
+6. The permissions for /dev/pts/ptmx node should be specified when mounting
+   /dev/pts, using the '-o ptmxmode=%o' mount option (default is 0000).
+
+	mount -t devpts -o newinstance -o ptmxmode=0644 devpts /dev/pts
+
+   The permissions can be later be changed as usual with 'chmod'.
+
+	chmod 666 /dev/pts/ptmx
-- 
1.5.2.5
