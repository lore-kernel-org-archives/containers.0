From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH RFC] procfs: add pidnr file
Date: Wed, 26 Jun 2013 11:18:20 -0500
Message-ID: <20130626161820.GA32142__19618.7395057224$1372263538$gmane$org@tp>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, =?iso-8859-1?Q?St=E9phane?= Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Add a file called pidnr under /proc/task/.  Reading this file gives the
pid of /proc/task in the reading task's namespace (or 0 if there is no
valid pid).

This fills a need currently not solvable at all.  The particular need I
have for it is so that a task inside a container can pass requests to a
task outside the container (using an open fd for /proc/task) to have the
target task moved to a new cgroup.  Others have asked for this ability
for other reasons.

Signed-off-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: St=E9phane Graber <stgraber-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
---
 fs/proc/base.c |   25 ++++++++++++++++++++++++-
 1 file changed, 24 insertions(+), 1 deletion(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index c3834da..b7499eb 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -899,6 +899,28 @@ static const struct file_operations proc_environ_opera=
tions =3D {
 	.release	=3D mem_release,
 };
 =

+#define TMPBUFLEN 21
+static ssize_t pidnr_read(struct file * file, char __user * buf,
+				  size_t count, loff_t *ppos)
+{
+	struct inode * inode =3D file_inode(file);
+	struct task_struct *task =3D get_proc_task(inode);
+	ssize_t length;
+	char tmpbuf[TMPBUFLEN];
+
+	if (!task)
+		return -ESRCH;
+	length =3D scnprintf(tmpbuf, TMPBUFLEN, "%u\n",
+			task_pid_vnr(task));
+	put_task_struct(task);
+	return simple_read_from_buffer(buf, count, ppos, tmpbuf, length);
+}
+
+static const struct file_operations pidnr_operations =3D {
+	.read		=3D pidnr_read,
+	.llseek		=3D generic_file_llseek,
+};
+
 static ssize_t oom_adj_read(struct file *file, char __user *buf, size_t co=
unt,
 			    loff_t *ppos)
 {
@@ -1096,7 +1118,6 @@ static const struct file_operations proc_oom_score_ad=
j_operations =3D {
 };
 =

 #ifdef CONFIG_AUDITSYSCALL
-#define TMPBUFLEN 21
 static ssize_t proc_loginuid_read(struct file * file, char __user * buf,
 				  size_t count, loff_t *ppos)
 {
@@ -2642,6 +2663,7 @@ static const struct pid_entry tgid_base_stuff[] =3D {
 	DIR("net",        S_IRUGO|S_IXUGO, proc_net_inode_operations, proc_net_op=
erations),
 #endif
 	REG("environ",    S_IRUSR, proc_environ_operations),
+	REG("pidnr",      S_IRUGO, pidnr_operations),
 	INF("auxv",       S_IRUSR, proc_pid_auxv),
 	ONE("status",     S_IRUGO, proc_pid_status),
 	ONE("personality", S_IRUGO, proc_pid_personality),
@@ -2999,6 +3021,7 @@ static const struct pid_entry tid_base_stuff[] =3D {
 	DIR("fdinfo",    S_IRUSR|S_IXUSR, proc_fdinfo_inode_operations, proc_fdin=
fo_operations),
 	DIR("ns",	 S_IRUSR|S_IXUGO, proc_ns_dir_inode_operations, proc_ns_dir_ope=
rations),
 	REG("environ",   S_IRUSR, proc_environ_operations),
+	REG("pidnr",     S_IRUGO, pidnr_operations),
 	INF("auxv",      S_IRUSR, proc_pid_auxv),
 	ONE("status",    S_IRUGO, proc_pid_status),
 	ONE("personality", S_IRUGO, proc_pid_personality),
-- =

1.7.9.5
