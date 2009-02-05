From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] liblxc: lxc-debian expects missing directories
Date: Thu, 05 Feb 2009 01:05:17 -0800
Message-ID: <1233824717.28338.8.camel@localhost>
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
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

lxc-debian fails unless the directories a given rootfs needs already
exist. To fix this without relying on any particular function call order
we can do: mkdir -p `dirname PATH/TO/FILE`
before actually making the file.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 scripts/lxc-debian.in |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

Index: lxc/scripts/lxc-debian.in
===================================================================
--- lxc.orig/scripts/lxc-debian.in
+++ lxc/scripts/lxc-debian.in
@@ -24,13 +24,14 @@ SSHD_CONFIG="/etc/ssh/sshd_config"
 # custom selinux
 
 write_debian_selinux() {
-    mkdir $ROOTFS/selinux
+    mkdir -p $ROOTFS/selinux
     echo 0 > $ROOTFS/selinux/enforce
 }
 
 # custom fstab
 
 write_debian_fstab() {
+mkdir -p `dirname $ROOTFS/$FSTAB`
 cat <<EOF > $ROOTFS/$FSTAB
 tmpfs  /dev/shm   tmpfs  defaults  0 0
 EOF
@@ -39,6 +40,7 @@ EOF
 # custom inittab
 
 write_debian_inittab() {
+mkdir -p `dirname $ROOTFS/$INITTAB`
 cat <<EOF > $ROOTFS/$INITTAB
 id:3:initdefault:
 si::sysinit:/etc/init.d/rcS
@@ -62,6 +64,7 @@ EOF
 # custom network configuration
 
 write_debian_network() {
+mkdir -p `dirname $ROOTFS/$INTERFACES`
 cat <<EOF > $ROOTFS/$INTERFACES
 auto eth0 lo
 iface eth0 inet static
@@ -76,6 +79,7 @@ EOF
 # custom hostname
 
 write_debian_hostname() {
+mkdir -p `dirname $ROOTFS/$HOSTNAME`
 cat <<EOF > $ROOTFS/$HOSTNAME
 $UTSNAME
 EOF
@@ -84,6 +88,7 @@ EOF
 # custom sshd configuration file
 
 write_debian_sshd_config() {
+mkdir -p `dirname $ROOTFS/$SSHD_CONFIG`
 cat <<EOF > $ROOTFS/$SSHD_CONFIG
 Port 22
 Protocol 2
