From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH -last version] freezer_cg: disable writing freezer.state
	of root  cgroup
Date: Thu, 06 Nov 2008 09:13:48 +0100
Message-ID: <4912A73C.4080308__8908.24153689227$1225959440$gmane$org@fr.ibm.com>
References: <491245F1.5070707@cn.fujitsu.com>
	<6599ad830811051724p1f97026fl96be5efe38b33152@mail.gmail.com>
	<49124DFF.1090702@cn.fujitsu.com> <49125006.4050206@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49125006.4050206-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello Li ! 

Li Zefan wrote:
> Li Zefan wrote:
>>> Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>>>
>>> I might use the term "non-freezable" rather than "unfreezable".
>>>
>> My bad English :(
>>
>> patch updated. (some annoying leading tabs are also removed in the doc)
>>
> 
> And I forgot to s/EIO/EINVAL in the document..
> 
> This patch should be the last version.. Sorry for the bothering.
> 
> 
> ======================
> 
> From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> Date: Tue, 4 Nov 2008 15:26:29 +0800
> Subject: [PATCH] freezer_cg: disable writing freezer.state of root cgroup
> 
> With this change, control file 'freezer.state' doesn't exist in root
> cgroup, making root cgroup unfreezable.
> 
> I think it's reasonable to disallow freeze tasks in the root cgroup.
> And then we can avoid fork overhead when freezer subsystem is
> compiled but not used.
> 
> Also make writing invalid value to freezer.state returns EINVAL
> rather than EIO. This is more consistent with other cgroup subsystem.
> 
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

It looks fine 

Acked-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

I've also tested it.

here's a minor comment,

I would make a small macro is_root_freezer() to show explicitly
what we are testing and use the CSS_ROOT bit to test. That's what
the CSS_ROOT bit is for Paul ?

if yes, here's a possible result is below. 

C.

Signed-off-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
---
 kernel/cgroup_freezer.c |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

Index: 2.6.27-lxc/kernel/cgroup_freezer.c
===================================================================
--- 2.6.27-lxc.orig/kernel/cgroup_freezer.c
+++ 2.6.27-lxc/kernel/cgroup_freezer.c
@@ -47,6 +47,11 @@ static inline struct freezer *task_freez
 			    struct freezer, css);
 }
 
+static inline int is_root_freezer(struct freezer *freezer)
+{
+	return test_bit(CSS_ROOT, &freezer->css.flags);
+}
+
 int cgroup_frozen(struct task_struct *task)
 {
 	struct freezer *freezer;
@@ -190,6 +195,13 @@ static void freezer_fork(struct cgroup_s
 	freezer = task_freezer(task);
 	task_unlock(task);
 
+	/*
+	 * The root cgroup is non-freezable, so we can skip the
+	 * following check.
+	 */
+	if (is_root_freezer(freezer))
+		return;
+
 	BUG_ON(freezer->state == CGROUP_FROZEN);
 	spin_lock_irq(&freezer->lock);
 	/* Locking avoids race with FREEZING -> THAWED transitions. */
@@ -363,6 +375,9 @@ static struct cftype files[] = {
 
 static int freezer_populate(struct cgroup_subsys *ss, struct cgroup *cgroup)
 {
+	if (is_root_freezer(cgroup_freezer(cgroup)))
+		return 0;
+
 	return cgroup_add_files(cgroup, ss, files, ARRAY_SIZE(files));
 }
