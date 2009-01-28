From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] liblxc: Complete use of autoconf prefix in lxc-debian
Date: Tue, 27 Jan 2009 16:23:28 -0800
Message-ID: <1233102208.9544.10.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

The lxc-debian script does not consistently address the lxc lock as
@LOCALSTATEDIR@/lock/subsys/lxc. Make consistent use of the autotools
substitution to completely enable configure --prefixes.

I also added a comment explaining why some of the paths didn't need
autoconf substitutions for anyone who wants to understand the script.
Also, to separate it from the container contents proper, I moved the
CACHE variable initialization above the container-internal path
variables.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 scripts/lxc-debian.in |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

Index: lxc-0.5.2/scripts/lxc-debian.in
===================================================================
--- lxc-0.5.2.orig/scripts/lxc-debian.in
+++ lxc-0.5.2/scripts/lxc-debian.in
@@ -1,18 +1,21 @@
 #!/bin/bash
 set -ex
 
+CACHE="@LOCALSTATEDIR@/cache/lxc/debian"
+
 NAME="debian"
 CONFFILE="lxc.conf"
 MNTFILE="mount.conf"
 UTSNAME=
 IPV4="172.20.0.21"
 GATEWAY="172.20.0.1"
+
+# These paths are within the container so do not need to obey configure
prefixes
 INTERFACES="/etc/network/interfaces"
 INITTAB="/etc/inittab"
 HOSTNAME="/etc/hostname"
 FSTAB="/etc/fstab"
 SSHD_CONFIG="/etc/ssh/sshd_config"
-CACHE="@LOCALSTATEDIR@/cache/lxc/debian"
 

################################################################################
 #                    debian custom configuration files
@@ -223,7 +226,7 @@ create() {
             # make a local copy of the minidebian
 	    echo -n "Copying rootfs ..."
 	    cp -a $CACHE/rootfs-$ARCH $ROOTFS && echo "Done." || exit
-	) 200>/var/lock/subsys/lxc
+	) 200> "@LOCALSTATEDIR@/lock/subsys/lxc"
     fi
 
 write_lxc_mounts
@@ -335,7 +338,7 @@ purge() {
 	rm --preserve-root --one-file-system -rf $CACHE && echo "Done." ||
exit 1
 	exit 0
 
-    ) 200>/var/lock/subsys/lxc
+    ) 200> "@LOCALSTATEDIR@/lock/subsys/lxc"
 }
 
 if [ "$(id -u)" != "0" ]; then
