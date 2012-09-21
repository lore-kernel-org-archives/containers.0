From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 14/14] userns: On alpha modify linux_to_osf_stat to use
	convert from kuids and kgids
Date: Thu, 20 Sep 2012 17:28:50 -0700
Message-ID: <1348187330-6616-14-git-send-email-ebiederm@xmission.com>
References: <87k3vote43.fsf@xmission.com>
	<1348187330-6616-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348187330-6616-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ivan Kokshaysky <ink-biIs/Y0ymYJMZLIVYojuPNP0rXTJTi09@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Matt Turner <mattst88-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Richard Henderson <rth-hL46jP5Bxq7R7s880joybQ@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Silencing build errors and potentially allowing people to use osf
system calls in from processes running in a non-default user namespace.

It seems this stat call was missed in my first round of converting the
stat system calls, bother.

Cc: Richard Henderson <rth-hL46jP5Bxq7R7s880joybQ@public.gmane.org>
Cc: Ivan Kokshaysky <ink-biIs/Y0ymYJMZLIVYojuPNP0rXTJTi09@public.gmane.org>
Cc: Matt Turner <mattst88-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 arch/alpha/kernel/osf_sys.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/alpha/kernel/osf_sys.c b/arch/alpha/kernel/osf_sys.c
index 98a1036..32c5f9d 100644
--- a/arch/alpha/kernel/osf_sys.c
+++ b/arch/alpha/kernel/osf_sys.c
@@ -278,8 +278,8 @@ linux_to_osf_stat(struct kstat *lstat, struct osf_stat __user *osf_stat)
 	tmp.st_dev	= lstat->dev;
 	tmp.st_mode	= lstat->mode;
 	tmp.st_nlink	= lstat->nlink;
-	tmp.st_uid	= lstat->uid;
-	tmp.st_gid	= lstat->gid;
+	tmp.st_uid	= from_kuid_munged(current_user_ns(), lstat->uid);
+	tmp.st_gid	= from_kgid_munged(current_user_ns(), lstat->gid);
 	tmp.st_rdev	= lstat->rdev;
 	tmp.st_ldev	= lstat->rdev;
 	tmp.st_size	= lstat->size;
-- 
1.7.5.4
