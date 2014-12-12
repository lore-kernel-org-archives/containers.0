From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 12/18] userns: Check euid no fsuid when establishing an
	unprivileged uid mapping
Date: Fri, 12 Dec 2014 16:48:23 -0600
Message-ID: <1418424509-22389-12-git-send-email-ebiederm__32637.9604558044$1418424959$gmane$org@xmission.com>
References: <87k31wzehb.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87k31wzehb.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

setresuid allows the euid to be set to any of uid, euid, suid, and
fsuid.  Therefor it is safe to allow an unprivileged user to map
their euid and use CAP_SETUID privileged with exactly that uid,
as no new credentials can be obtained.

I can not find a combination of existing system calls that allows setting
uid, euid, suid, and fsuid from the fsuid making the previous use
of fsuid for allowing unprivileged mappings a bug.

This is part of a fix for CVE-2014-8989.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Reviewed-by: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 kernel/user_namespace.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 1ce6d67c07b7..9451b12a9b6c 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -819,7 +819,7 @@ static bool new_idmap_permitted(const struct file *file,
 		u32 id = new_map->extent[0].lower_first;
 		if (cap_setid == CAP_SETUID) {
 			kuid_t uid = make_kuid(ns->parent, id);
-			if (uid_eq(uid, file->f_cred->fsuid))
+			if (uid_eq(uid, file->f_cred->euid))
 				return true;
 		}
 	}
-- 
1.9.1
