From: Huang Qiang <h.huangqiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] user_ns: Use nsown_capable instead of capable in
	net_ctl_permissions
Date: Tue, 24 Jul 2012 19:05:01 +0800
Message-ID: <500E815D.4070605@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Zhao Hongjiang <zhaohongjiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

HI:
When I use an unprivileged user exec the following command:
# nsexec -cUn /bin/bash
to create a container with new user_ns and net_ns.

Then I exec "echo 4096 4096 4096 > /proc/sys/net/ipv4/tcp_mem",
the result is Permission Denied which we hope it should be allowed.

It is because of capable(CAP_NET_ADMIN).

Even my unprivileged user have the CAP_NET_ADMIN in the new user_ns and the
tcp_mem is belong to the new net_ns, the capable(CAP_NET_ADMIN) checking is
that this must in the init_user_ns, so the result is the network administrator
can't have the same access as root.

Use nsown_capable(...) the problem is solved.

PS: I changed lxc almostly like what serge done, then use an unprivileged user
to start a container, several Permission Denied occur(such as mount), all this
is caused by capabale(...), when i use nsown_capable(...) the container is
running like everything is ok.
Is this capabale() methed is obsolete? If so, i'll send a new patch to solve
all this problems.

Signed-off-by: Zhao Hongjiang<zhaohongjiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Huang Qiang <h.huangqiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 net/sysctl_net.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index c3e65ae..ee31777 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -47,7 +47,7 @@ static int net_ctl_permissions(struct ctl_table_root *root,
 			       struct ctl_table *table)
 {
 	/* Allow network administrator to have same access as root. */
-	if (capable(CAP_NET_ADMIN)) {
+	if (nsown_capable(CAP_NET_ADMIN)) {
 		int mode = (table->mode >> 6) & 7;
 		return (mode << 6) | (mode << 3) | mode;
 	}
-- 
1.7.1
