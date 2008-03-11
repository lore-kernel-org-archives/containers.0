From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] Add a 'trigger' callback on struct cftype.
Date: Tue, 11 Mar 2008 19:13:12 +0300
Message-ID: <47D6AF98.4030204@openvz.org>
References: <47D6A36F.2080706@openvz.org>
	<6599ad830803110900j7d47bd6eqf8747bdb704c9226@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830803110900j7d47bd6eqf8747bdb704c9226-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Paul Menage wrote:
> On Tue, Mar 11, 2008 at 8:21 AM, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> wrote:
>> If the patch with max_usage for res_counter will be accepted we'll have
>>  two :) files, that a event-triggers essentially, i.e. they don't care
>>  what the user actually write to then, but are interested in the writing
>>  by its own.
>>
>>  So the proposal is to make cgroups infrastructure handle this case.
> 
> This could be useful, but in the case of force_empty don't we lose the
> ability to report an error (EBUSY?) in the event that the cgroup still
> has tasks?

Yikes :( Good catch. The fix, however, is pretty small.

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index df579e3..f6b882d 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -243,7 +243,7 @@ struct cftype {
         */
        int (*write_s64) (struct cgroup *cgrp, struct cftype *cft, s64 val);
 
-       void (*trigger) (struct cgroup *cgrp, unsigned int event);
+       int (*trigger) (struct cgroup *cgrp, unsigned int event);
        int (*release) (struct inode *inode, struct file *file);
 };
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 7d73c2b..f2d8f25 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1411,8 +1411,8 @@ static ssize_t cgroup_file_write(struct file *file, const char __user *buf,
        if (cft->write_u64 || cft->write_s64)
                return cgroup_write_X64(cgrp, cft, file, buf, nbytes, ppos);
        if (cft->trigger) {
-               cft->trigger(cgrp, (unsigned int)cft->private);
-               return nbytes;
+               int ret = cft->trigger(cgrp, (unsigned int)cft->private);
+               return ret ? ret : nbytes;
        }
        return -EINVAL;
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4c1d24c..ab1a862 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -868,14 +868,15 @@ static ssize_t mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
                                mem_cgroup_write_strategy);
 }
 
-static void mem_cgroup_max_reset(struct cgroup *cont, unsigned int event)
+static int mem_cgroup_max_reset(struct cgroup *cont, unsigned int event)
 {
        res_counter_reset_max(&mem_cgroup_from_cont(cont)->res);
+       return 0;
 }
 
-static void mem_force_empty_write(struct cgroup *cont, unsigned int event)
+static int mem_force_empty_write(struct cgroup *cont, unsigned int event)
 {
-       mem_cgroup_force_empty(mem_cgroup_from_cont(cont));
+       return mem_cgroup_force_empty(mem_cgroup_from_cont(cont));
 }
 
 static const struct mem_cgroup_stat_desc {


> Paul
> 
