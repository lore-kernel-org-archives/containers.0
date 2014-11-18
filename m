From: Chen Hanxiao <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH v8 2/2] /proc/PID/status: show all sets of pid according to ns
Date: Tue, 18 Nov 2014 17:30:13 +0800
Message-ID: <1416303013-13762-3-git-send-email-chenhanxiao@cn.fujitsu.com>
References: <1416303013-13762-1-git-send-email-chenhanxiao@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1416303013-13762-1-git-send-email-chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Richard Weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mateusz Guzik <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

If some issues occurred inside a container guest, host user
could not know which process is in trouble just by guest pid:
the users of container guest only knew the pid inside containers.
This will bring obstacle for trouble shooting.

This patch adds four fields: NStgid, NSpid, NSpgid and NSsid:
a) In init_pid_ns, nothing changed;

b) In one pidns, will tell the pid inside containers:
NStgid:	21776   5       1
NSpid:  21776   5       1
NSpgid:	21776   5       1
NSsid:  21729   1       0
** Process id is 21776 in level 0, 5 in level 1, 1 in level 2.

c) If pidns is nested, it depends on which pidns are you in.
NStgid: 5       1
NSpid:  5       1
NSpgid: 5       1
NSsid:  1       0
** Views from level 1

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Tested-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

Signed-off-by: Chen Hanxiao <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
No change since v3
v3: add another two fielsd: NSpgid and NSsid.
v2: add two new fields: NStgid and NSpid.
    keep fields of Tgid and Pid unchanged for back compatibility.

 fs/proc/array.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/fs/proc/array.c b/fs/proc/array.c
index cd3653e..c30875d 100644
--- a/fs/proc/array.c
+++ b/fs/proc/array.c
@@ -193,6 +193,23 @@ static inline void task_state(struct seq_file *m, struct pid_namespace *ns,
 		from_kgid_munged(user_ns, cred->egid),
 		from_kgid_munged(user_ns, cred->sgid),
 		from_kgid_munged(user_ns, cred->fsgid));
+	seq_puts(m, "NStgid:");
+	for (g = ns->level; g <= pid->level; g++)
+		seq_printf(m, "\t%d ",
+			task_tgid_nr_ns(p, pid->numbers[g].ns));
+	seq_puts(m, "\nNSpid:");
+	for (g = ns->level; g <= pid->level; g++)
+		seq_printf(m, "\t%d ",
+			task_pid_nr_ns(p, pid->numbers[g].ns));
+	seq_puts(m, "\nNSpgid:");
+	for (g = ns->level; g <= pid->level; g++)
+		seq_printf(m, "\t%d ",
+			task_pgrp_nr_ns(p, pid->numbers[g].ns));
+	seq_puts(m, "\nNSsid:");
+	for (g = ns->level; g <= pid->level; g++)
+		seq_printf(m, "\t%d ",
+			task_session_nr_ns(p, pid->numbers[g].ns));
+	seq_putc(m, '\n');
 
 	task_lock(p);
 	if (p->files)
-- 
1.9.3
