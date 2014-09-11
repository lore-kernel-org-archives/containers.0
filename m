From: Chen Hanxiao <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [RESEND][PATCH] userns: use marco instead of magic number for max
	userns level
Date: Thu, 11 Sep 2014 17:51:31 +0800
Message-ID: <1410429091-7234-1-git-send-email-chenhanxiao@cn.fujitsu.com>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Fabian Frederick <fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Use marco instead of magic number
for max user namespace level.

Signed-off-by: Chen Hanxiao <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/user_namespace.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index aa312b0..5435489 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -47,6 +47,8 @@ static void set_cred_user_ns(struct cred *cred, struct user_namespace *user_ns)
 	cred->user_ns = user_ns;
 }
 
+#define MAX_USER_NS_LEVEL 32
+
 /*
  * Create a new user namespace, deriving the creator from the user in the
  * passed credentials, and replacing that user with the new root user for the
@@ -62,7 +64,7 @@ int create_user_ns(struct cred *new)
 	kgid_t group = new->egid;
 	int ret;
 
-	if (parent_ns->level > 32)
+	if (parent_ns->level > MAX_USER_NS_LEVEL)
 		return -EUSERS;
 
 	/*
-- 
1.9.0
