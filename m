From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [REVIEW][PATCH 2/3] exec: Don't allow ptracing an exec of an
	unreadable file
Date: Thu, 17 Nov 2016 11:08:22 -0600
Message-ID: <87inrmavax.fsf_-___3297.06196575916$1479402775$gmane$org@xmission.com>
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


It is the reasonable expectation that if an executable file is not
readable there will be no way for a user without special privileges to
read the file.  This is enforced in ptrace_attach but if we are
already attached there is no enforcement if a readonly executable
is exec'd.

Therefore do the simple thing and if there is a non-dumpable
executable that we are tracing without privilege fail to exec it.

Fixes: v1.0
Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Reported-by: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/exec.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/exec.c b/fs/exec.c
index fdec760bfac3..de107f74e055 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1230,6 +1230,11 @@ int flush_old_exec(struct linux_binprm * bprm)
 {
 	int retval;
 
+	/* Fail if the tracer can't read the executable */
+	if ((bprm->interp_flags & BINPRM_FLAGS_ENFORCE_NONDUMP) &&
+	    !ptracer_capable(current, bprm->mm->user_ns))
+		return -EPERM;
+
 	/*
 	 * Make sure we have a private signal table and that
 	 * we are unassociated from the previous thread group.
@@ -1301,7 +1306,6 @@ void setup_new_exec(struct linux_binprm * bprm)
 	    !gid_eq(bprm->cred->gid, current_egid())) {
 		current->pdeath_signal = 0;
 	} else {
-		would_dump(bprm, bprm->file);
 		if (bprm->interp_flags & BINPRM_FLAGS_ENFORCE_NONDUMP)
 			set_dumpable(current->mm, suid_dumpable);
 	}
@@ -1736,6 +1740,8 @@ static int do_execveat_common(int fd, struct filename *filename,
 	if (retval < 0)
 		goto out;
 
+	would_dump(bprm, bprm->file);
+
 	retval = exec_binprm(bprm);
 	if (retval < 0)
 		goto out;
-- 
2.10.1
