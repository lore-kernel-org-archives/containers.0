From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] liblxc: handle interruption/failure of lxc-debian more
	gracefully
Date: Thu, 05 Feb 2009 01:22:19 -0800
Message-ID: <1233825739.28338.22.camel@localhost>
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

If lxc-debian fails or is interrupted during debootstrap then the next
invocation of lxc-debian breaks because it only checks for the existence
of the directory. This forces the user to remove the cache by hand to
retry the create step.

Let's allow the user to re-run lxc-debian to resume/retry. Store the
cache in a partial-$ARCH directory until debootstrap succeeds. Then move
the valid cache to its final destination.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 scripts/lxc-debian.in |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: lxc/scripts/lxc-debian.in
===================================================================
--- lxc.orig/scripts/lxc-debian.in
+++ lxc/scripts/lxc-debian.in
@@ -217,19 +217,20 @@ create() {
 		
 		echo "not cached"
 		
-		mkdir -p "$CACHE/rootfs-$ARCH"
+		mkdir -p "$CACHE/partial-$ARCH"
 		
 	        # download a mini debian into a cache
 		echo "Downloading debian minimal ..."
 		debootstrap --verbose --variant=minbase --arch=$ARCH \
 		    --include apache,netbase,net-tools,iproute,openssh-server \
-		    etch $CACHE/rootfs-$ARCH http://ftp.debian.org/debian
+		    etch $CACHE/partial-$ARCH http://ftp.debian.org/debian
 		
 		RESULT=$?
 		if [ "$RESULT" != "0" ]; then
 		    echo "Failed to download the rootfs, aborting."
 		    exit 1
 		fi
+		mv "$CACHE/partial-$ARCH" "$CACHE/rootfs-$ARCH"
 		echo "Download complete."
 	    else
 		echo "Found."
