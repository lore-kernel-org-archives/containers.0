From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [REVIEW][PATCH 3/3] exec: Ensure mm->user_ns contains the execed files
Date: Thu, 17 Nov 2016 11:10:13 -0600
Message-ID: <87d1huav7u.fsf_-___34414.5249728628$1479402863$gmane$org@xmission.com>
References: <87twcbq696.fsf@x220.int.ebiederm.org>
	<20161018135031.GB13117@dhcp22.suse.cz> <8737jt903u.fsf@xmission.com>
	<20161018150507.GP14666@pc.thejh.net> <87twc9656s.fsf@xmission.com>
	<20161018191206.GA1210@laptop.thejh.net> <87r37dnz74.fsf@xmission.com>
	<87k2d5nytz.fsf_-_@xmission.com>
	<CALCETrU4SZYUEPrv4JkpUpA+0sZ=EirZRftRDp+a5hce5E7HgA@mail.gmail.com>
	<87y41kjn6l.fsf@xmission.com> <20161019172917.GE1210@laptop.thejh.net>
	<CALCETrWSY1SRse5oqSwZ=goQ+ZALd2XcTP3SZ8ry49C8rNd98Q@mail.gmail.com>
	<87pomwi5p2.fsf@xmission.com>
	<CALCETrUz2oU6OYwQ9K4M-SUg6FeDsd6Q1gf1w-cJRGg2PdmK8g@mail.gmail.com>
	<87pomwghda.fsf@xmission.com>
	<CALCETrXA2EnE8X3HzetLG6zS8YSVjJQJrsSumTfvEcGq=r5vsw@mail.gmail.com>
	<87twb6avk8.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87twb6avk8.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Thu, 17 Nov 2016 11:02:47 -0600")
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
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org


When the user namespace support was merged the need to prevent
ptrace from revealing the contents of an unreadable executable
was overlooked.

Correct this oversight by ensuring that the executed file
or files are in mm->user_ns, by adjusting mm->user_ns.

Use the new function privileged_wrt_inode_uidgid to see if
the executable is a member of the user namespace, and as such
if having CAP_SYS_PTRACE in the user namespace should allow
tracing the executable.  If not update mm->user_ns to
the parent user namespace until an appropriate parent is found.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Reported-by: Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
Fixes: 9e4a36ece652 ("userns: Fail exec for suid and sgid binaries with ids outside our user namespace.")
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/exec.c                  | 16 +++++++++++++++-
 include/linux/capability.h |  1 +
 kernel/capability.c        | 16 ++++++++++++++--
 3 files changed, 30 insertions(+), 3 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index de107f74e055..4ce5d68d6f5b 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1275,8 +1275,22 @@ EXPORT_SYMBOL(flush_old_exec);
 
 void would_dump(struct linux_binprm *bprm, struct file *file)
 {
-	if (inode_permission(file_inode(file), MAY_READ) < 0)
+	struct inode *inode = file_inode(file);
+	if (inode_permission(inode, MAY_READ) < 0) {
+		struct user_namespace *old, *user_ns;
 		bprm->interp_flags |= BINPRM_FLAGS_ENFORCE_NONDUMP;
+
+		/* Ensure mm->user_ns contains the executable */
+		user_ns = old = bprm->mm->user_ns;
+		while ((user_ns != &init_user_ns) &&
+		       !privileged_wrt_inode_uidgid(user_ns, inode))
+			user_ns = user_ns->parent;
+
+		if (old != user_ns) {
+			bprm->mm->user_ns = get_user_ns(user_ns);
+			put_user_ns(old);
+		}
+	}
 }
 EXPORT_SYMBOL(would_dump);
 
diff --git a/include/linux/capability.h b/include/linux/capability.h
index d6088e2a7668..6ffb67e10c06 100644
--- a/include/linux/capability.h
+++ b/include/linux/capability.h
@@ -240,6 +240,7 @@ static inline bool ns_capable_noaudit(struct user_namespace *ns, int cap)
 	return true;
 }
 #endif /* CONFIG_MULTIUSER */
+extern bool privileged_wrt_inode_uidgid(struct user_namespace *ns, const struct inode *inode);
 extern bool capable_wrt_inode_uidgid(const struct inode *inode, int cap);
 extern bool file_ns_capable(const struct file *file, struct user_namespace *ns, int cap);
 extern bool ptracer_capable(struct task_struct *tsk, struct user_namespace *ns);
diff --git a/kernel/capability.c b/kernel/capability.c
index dfa0e4528b0b..4984e1f552eb 100644
--- a/kernel/capability.c
+++ b/kernel/capability.c
@@ -457,6 +457,19 @@ bool file_ns_capable(const struct file *file, struct user_namespace *ns,
 EXPORT_SYMBOL(file_ns_capable);
 
 /**
+ * privileged_wrt_inode_uidgid - Do capabilities in the namespace work over the inode?
+ * @ns: The user namespace in question
+ * @inode: The inode in question
+ *
+ * Return true if the inode uid and gid are within the namespace.
+ */
+bool privileged_wrt_inode_uidgid(struct user_namespace *ns, const struct inode *inode)
+{
+	return kuid_has_mapping(ns, inode->i_uid) &&
+		kgid_has_mapping(ns, inode->i_gid);
+}
+
+/**
  * capable_wrt_inode_uidgid - Check nsown_capable and uid and gid mapped
  * @inode: The inode in question
  * @cap: The capability in question
@@ -469,8 +482,7 @@ bool capable_wrt_inode_uidgid(const struct inode *inode, int cap)
 {
 	struct user_namespace *ns = current_user_ns();
 
-	return ns_capable(ns, cap) && kuid_has_mapping(ns, inode->i_uid) &&
-		kgid_has_mapping(ns, inode->i_gid);
+	return ns_capable(ns, cap) && privileged_wrt_inode_uidgid(ns, inode);
 }
 EXPORT_SYMBOL(capable_wrt_inode_uidgid);
 
-- 
2.10.1
