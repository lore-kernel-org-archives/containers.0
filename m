From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 4/4] devpts: Update the documentation
Date: Sat, 22 Sep 2012 20:51:41 -0700
Message-ID: <87627575wy.fsf_-_@xmission.com>
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


Document the updated state of devpts.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 Documentation/filesystems/devpts.txt |   88 ++++++++-------------------------
 1 files changed, 22 insertions(+), 66 deletions(-)

diff --git a/Documentation/filesystems/devpts.txt b/Documentation/filesystems/devpts.txt
index 260cf6d..02f2806 100644
--- a/Documentation/filesystems/devpts.txt
+++ b/Documentation/filesystems/devpts.txt
@@ -3,26 +3,17 @@ To support containers, we now allow multiple instances of devpts filesystem,
 such that indices of ptys allocated in one instance are independent of indices
 allocated in other instances of devpts.
 
-To preserve backward compatibility, this support for multiple instances is
-enabled only if:
-
-	- '-o newinstance' mount option is specified while mounting devpts
-
-IOW, devpts now supports both single-instance and multi-instance semantics.
-
-If devpts is mounted without the 'newinstance' option (as in current
-start-up scripts) the new mount binds to the initial kernel mount of
-devpts. This mode is referred to as the 'single-instance' mode and the
-current, single-instance semantics are preserved, i.e PTYs are common
-across the system.
-
-If 'newinstance' option is specified, the mount is considered to be in
-the multi-instance mode and a new instance of the devpts fs is
-created. Any ptys created in this instance are independent of ptys in
-other instances of devpts. Like in the single-instance mode, the
-/dev/pts/ptmx node is present. To effectively use the multi-instance
-mode, open of /dev/ptmx must be a redirected to '/dev/pts/ptmx' using
-a symlink or bind-mount.
+Initially devpts would only support creating multiple instances of itself
+when passed the newinstance mount option.  The newinstance mount option was
+found to be unnecessary and is now recognized but ignored because all mounts
+of devpts create a new instance devpts.
+
+when devpts is mounted a new instance of the devpts fs is created. Any
+ptys created in this instance are independent of ptys in other
+instances of devpts.  The /dev/pts/ptmx node is present.  Opening the
+classic /dev/ptmx device node redirects to /dev/pts/ptmx (if present).
+Creating /dev/ptmx as a symlink to or bind mount of /dev/pts/ptmx is
+preferable to make it explicit what is going on.
 
 Eg: A container startup script could do the following:
 
@@ -44,14 +35,13 @@ the original mount of /dev/pts.
 User-space changes
 ------------------
 
-In multi-instance mode (i.e '-o newinstance' mount option is specified at least
-once), following user-space issues should be noted.
+The following user-space issues should be noted.
 
-1. If -o newinstance mount option is never used, /dev/pts/ptmx can be ignored
+1. If devpts is only mounted once on /dev/pts /dev/pts/ptmx can be ignored
    and no change is needed to system-startup scripts.
 
-2. To effectively use multi-instance mode (i.e -o newinstance is specified)
-   administrators or startup scripts should "redirect" open of /dev/ptmx to
+2. To effectively use multiple instances of devpts administrators or
+   startup scripts should "redirect" open of /dev/ptmx to
    /dev/pts/ptmx using either a bind mount or symlink.
 
 	$ mount -t devpts -o newinstance devpts /dev/pts
@@ -64,21 +54,17 @@ once), following user-space issues should be noted.
    or
 	$ mount -o bind /dev/pts/ptmx /dev/ptmx
 
+   Opening of ptmx attempts to remove the need for this by acting
+   like a relative symlink to pts/ptmx but this does not work if
+   devpts and /dev/ptmx are not in the typical locations.
+
 3. The '/dev/ptmx -> pts/ptmx' symlink is the preferred method since it
    enables better error-reporting and treats both single-instance and
    multi-instance mounts similarly.
 
-   But this method requires that system-startup scripts set the mode of
-   /dev/pts/ptmx correctly (default mode is 0000). The scripts can set the
-   mode by, either
-
-   	- adding ptmxmode mount option to devpts entry in /etc/fstab, or
-	- using 'chmod 0666 /dev/pts/ptmx'
-
-4. If multi-instance mode mount is needed for containers, but the system
-   startup scripts have not yet been updated, container-startup scripts
-   should bind mount /dev/ptmx to /dev/pts/ptmx to avoid breaking single-
-   instance mounts.
+4. If the system startup scripts have not yet been updated,
+   container-startup scripts should bind mount /dev/ptmx to
+   /dev/pts/ptmx.
 
    Or, in general, container-startup scripts should use:
 
@@ -90,33 +76,3 @@ once), following user-space issues should be noted.
    When all devpts mounts are multi-instance, /dev/ptmx can permanently be
    a symlink to pts/ptmx and the bind mount can be ignored.
 
-5. A multi-instance mount that is not accompanied by the /dev/ptmx to
-   /dev/pts/ptmx redirection would result in an unusable/unreachable pty.
-
-	mount -t devpts -o newinstance lxcpts /dev/pts
-
-   immediately followed by:
-
-	open("/dev/ptmx")
-
-    would create a pty, say /dev/pts/7, in the initial kernel mount.
-    But /dev/pts/7 would be invisible in the new mount.
-
-6. The permissions for /dev/pts/ptmx node should be specified when mounting
-   /dev/pts, using the '-o ptmxmode=%o' mount option (default is 0000).
-
-	mount -t devpts -o newinstance -o ptmxmode=0644 devpts /dev/pts
-
-   The permissions can be later be changed as usual with 'chmod'.
-
-	chmod 666 /dev/pts/ptmx
-
-7. A mount of devpts without the 'newinstance' option results in binding to
-   initial kernel mount.  This behavior while preserving legacy semantics,
-   does not provide strict isolation in a container environment. i.e by
-   mounting devpts without the 'newinstance' option, a container could
-   get visibility into the 'host' or root container's devpts.
-   
-   To workaround this and have strict isolation, all mounts of devpts,
-   including the mount in the root container, should use the newinstance
-   option.
-- 
1.7.5.4
