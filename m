From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 11/14] userns: Convert s390 getting uid and gid system calls
	to use kuid and kgid
Date: Thu, 20 Sep 2012 17:28:47 -0700
Message-ID: <1348187330-6616-11-git-send-email-ebiederm@xmission.com>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Convert getresuid, getresgid, getuid, geteuid, getgid, getegid

Convert struct cred kuids and kgids into userspace uids and gids when
returning them.

These s390 system calls slipped through the cracks in my first
round of converstions :(

Cc: Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Cc: Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 arch/s390/kernel/compat_linux.c |   36 ++++++++++++++++++++++++------------
 1 files changed, 24 insertions(+), 12 deletions(-)

diff --git a/arch/s390/kernel/compat_linux.c b/arch/s390/kernel/compat_linux.c
index d122508..73995a7 100644
--- a/arch/s390/kernel/compat_linux.c
+++ b/arch/s390/kernel/compat_linux.c
@@ -131,13 +131,19 @@ asmlinkage long sys32_setresuid16(u16 ruid, u16 euid, u16 suid)
 		low2highuid(suid));
 }
 
-asmlinkage long sys32_getresuid16(u16 __user *ruid, u16 __user *euid, u16 __user *suid)
+asmlinkage long sys32_getresuid16(u16 __user *ruidp, u16 __user *euidp, u16 __user *suidp)
 {
+	const struct cred *cred = current_cred();
 	int retval;
+	u16 ruid, euid, suid;
 
-	if (!(retval = put_user(high2lowuid(current->cred->uid), ruid)) &&
-	    !(retval = put_user(high2lowuid(current->cred->euid), euid)))
-		retval = put_user(high2lowuid(current->cred->suid), suid);
+	ruid = high2lowuid(from_kuid_munged(cred->user_ns, cred->uid));
+	euid = high2lowuid(from_kuid_munged(cred->user_ns, cred->euid));
+	suid = high2lowuid(from_kuid_munged(cred->user_ns, cred->suid));
+
+	if (!(retval   = put_user(ruid, ruidp)) &&
+	    !(retval   = put_user(euid, euidp)))
+		retval = put_user(suid, suidp);
 
 	return retval;
 }
@@ -148,13 +154,19 @@ asmlinkage long sys32_setresgid16(u16 rgid, u16 egid, u16 sgid)
 		low2highgid(sgid));
 }
 
-asmlinkage long sys32_getresgid16(u16 __user *rgid, u16 __user *egid, u16 __user *sgid)
+asmlinkage long sys32_getresgid16(u16 __user *rgidp, u16 __user *egidp, u16 __user *sgidp)
 {
+	const struct cred *cred = current_cred();
 	int retval;
+	u16 rgid, egid, sgid;
+
+	rgid = high2lowgid(from_kgid_munged(cred->user_ns, cred->gid));
+	egid = high2lowgid(from_kgid_munged(cred->user_ns, cred->egid));
+	sgid = high2lowgid(from_kgid_munged(cred->user_ns, cred->sgid));
 
-	if (!(retval = put_user(high2lowgid(current->cred->gid), rgid)) &&
-	    !(retval = put_user(high2lowgid(current->cred->egid), egid)))
-		retval = put_user(high2lowgid(current->cred->sgid), sgid);
+	if (!(retval   = put_user(rgid, rgidp)) &&
+	    !(retval   = put_user(egid, egidp)))
+		retval = put_user(sgid, sgidp);
 
 	return retval;
 }
@@ -258,22 +270,22 @@ asmlinkage long sys32_setgroups16(int gidsetsize, u16 __user *grouplist)
 
 asmlinkage long sys32_getuid16(void)
 {
-	return high2lowuid(current->cred->uid);
+	return high2lowuid(from_kuid_munged(current_user_ns(), current_uid()));
 }
 
 asmlinkage long sys32_geteuid16(void)
 {
-	return high2lowuid(current->cred->euid);
+	return high2lowuid(from_kuid_munged(current_user_ns(), current_euid()));
 }
 
 asmlinkage long sys32_getgid16(void)
 {
-	return high2lowgid(current->cred->gid);
+	return high2lowgid(from_kgid_munged(current_user_ns(), current_gid()));
 }
 
 asmlinkage long sys32_getegid16(void)
 {
-	return high2lowgid(current->cred->egid);
+	return high2lowgid(from_kgid_munged(current_user_ns(), current_egid()));
 }
 
 /*
-- 
1.7.5.4
