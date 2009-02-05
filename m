From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] liblxc: Update lxc-debian to use the lenny release
Date: Thu, 05 Feb 2009 01:32:33 -0800
Message-ID: <1233826353.28338.35.camel@localhost>
References: <1233825739.28338.22.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1233825739.28338.22.camel@localhost>
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

With the release of lenny nearing this patch may soon be useful.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 scripts/lxc-debian.in |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: lxc/scripts/lxc-debian.in
===================================================================
--- lxc.orig/scripts/lxc-debian.in
+++ lxc/scripts/lxc-debian.in
@@ -222,8 +222,8 @@ create() {
 	        # download a mini debian into a cache
 		echo "Downloading debian minimal ..."
 		debootstrap --verbose --variant=minbase --arch=$ARCH \
-		    --include apache,netbase,net-tools,iproute,openssh-server \
-		    etch $CACHE/partial-$ARCH http://ftp.debian.org/debian
+		    --include apache2,netbase,net-tools,iproute,openssh-server \
+		    lenny $CACHE/partial-$ARCH http://ftp.debian.org/debian
 		
 		RESULT=$?
 		if [ "$RESULT" != "0" ]; then
