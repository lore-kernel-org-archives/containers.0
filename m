From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] templates: don't put devpts in $confdir/container/fstab
Date: Fri, 6 May 2011 12:05:17 -0500
Message-ID: <20110506170516.GA20670@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
Cc: stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

src/lxc/conf.c will explicitly mount it anyway.  Furthermore, the fstab
entry, which is getting processed first, did not specify -o newinstance.
This can cause the host's devpts entry mount options to change, as in
https://bugs.launchpad.net/ubuntu/+source/libvirt/+bug/607636.

I believe the lenny, fedora, and debian templates also will need an
update.

Signed-off-by: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
---
 templates/lxc-lucid.in    |    1 -
 templates/lxc-maverick.in |    1 -
 templates/lxc-natty.in    |    1 -
 3 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/templates/lxc-lucid.in b/templates/lxc-lucid.in
index fb5aa6f..fe61313 100644
--- a/templates/lxc-lucid.in
+++ b/templates/lxc-lucid.in
@@ -260,7 +260,6 @@ EOF
 
     cat <<EOF > $path/fstab
 proc            $rootfs/proc         proc    nodev,noexec,nosuid 0 0
-devpts          $rootfs/dev/pts      devpts defaults 0 0
 sysfs           $rootfs/sys          sysfs defaults  0 0
 EOF
 
diff --git a/templates/lxc-maverick.in b/templates/lxc-maverick.in
index a85a6ca..0a8ac8e 100644
--- a/templates/lxc-maverick.in
+++ b/templates/lxc-maverick.in
@@ -183,7 +183,6 @@ EOF
 
     cat <<EOF > $path/fstab
 proc            $rootfs/proc         proc    nodev,noexec,nosuid 0 0
-devpts          $rootfs/dev/pts      devpts defaults 0 0
 sysfs           $rootfs/sys          sysfs defaults  0 0
 EOF
 
diff --git a/templates/lxc-natty.in b/templates/lxc-natty.in
index c71596e..e7e3859 100644
--- a/templates/lxc-natty.in
+++ b/templates/lxc-natty.in
@@ -184,7 +184,6 @@ EOF
 
     cat <<EOF > $path/fstab
 proc            $rootfs/proc         proc    nodev,noexec,nosuid 0 0
-devpts          $rootfs/dev/pts      devpts defaults 0 0
 sysfs           $rootfs/sys          sysfs defaults  0 0
 EOF
 
-- 
1.7.4.1
