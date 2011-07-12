From: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH 11/14] userns: make some net-sysfs capable calls targeted
Date: Tue, 12 Jul 2011 23:30:49 +0000
Message-ID: <1310513452-13397-12-git-send-email-serge__28531.7514594228$1310514192$gmane$org@hallyn.com>
References: <1310513452-13397-1-git-send-email-serge@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1310513452-13397-1-git-send-email-serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

Changelog: jul 1: fix compilation errors (net_device != net)

Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/core/net-sysfs.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 33d2a1f..b651baf 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -76,7 +76,7 @@ static ssize_t netdev_store(struct device *dev, struct device_attribute *attr,
 	unsigned long new;
 	int ret = -EINVAL;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(dev_net(net)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	new = simple_strtoul(buf, &endp, 0);
@@ -262,7 +262,7 @@ static ssize_t store_ifalias(struct device *dev, struct device_attribute *attr,
 	size_t count = len;
 	ssize_t ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(dev_net(netdev)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	/* ignore trailing newline */
-- 
1.7.4.1
