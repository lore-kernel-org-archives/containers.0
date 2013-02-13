From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 01/85] ceph: Only allow mounts in the initial network
	namespace
Date: Wed, 13 Feb 2013 09:50:50 -0800
Message-ID: <1360777934-5663-1-git-send-email-ebiederm__10125.3228066073$1360777989$gmane$org@xmission.com>
References: <87621w14vs.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87621w14vs.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Sage Weil <sage-4GqslpFJ+cxBDgjK7y7TUQ@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Today ceph opens tcp sockets from a delayed work callback.  Delayed
work happens from kernel threads which are always in the initial
network namespace.   Therefore fail early if someone attempts
to mount a ceph filesystem from something other than the initial
network namespace.

Cc: Sage Weil <sage-4GqslpFJ+cxBDgjK7y7TUQ@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/ceph/ceph_common.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/ceph/ceph_common.c b/net/ceph/ceph_common.c
index ee71ea2..1deb29a 100644
--- a/net/ceph/ceph_common.c
+++ b/net/ceph/ceph_common.c
@@ -15,6 +15,8 @@
 #include <linux/slab.h>
 #include <linux/statfs.h>
 #include <linux/string.h>
+#include <linux/nsproxy.h>
+#include <net/net_namespace.h>
 
 
 #include <linux/ceph/ceph_features.h>
@@ -292,6 +294,9 @@ ceph_parse_options(char *options, const char *dev_name,
 	int err = -ENOMEM;
 	substring_t argstr[MAX_OPT_ARGS];
 
+	if (current->nsproxy->net_ns != &init_net)
+		return ERR_PTR(-EINVAL);
+
 	opt = kzalloc(sizeof(*opt), GFP_KERNEL);
 	if (!opt)
 		return ERR_PTR(-ENOMEM);
-- 
1.7.5.4
