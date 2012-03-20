From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 09/10] cgroup: introduce struct cfent
Date: Tue, 20 Mar 2012 20:03:03 +0400
Message-ID: <4F68AA37.80604@parallels.com>
References: <1331940963-15756-1-git-send-email-tj@kernel.org>
	<1331940963-15756-10-git-send-email-tj@kernel.org>
	<4F688EA9.8050905@parallels.com> <20120320160228.GD5684@google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------030309020803090007030503"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120320160228.GD5684-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

--------------030309020803090007030503
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit

On 03/20/2012 08:02 PM, Tejun Heo wrote:
> On Tue, Mar 20, 2012 at 06:05:29PM +0400, Glauber Costa wrote:
>> On 03/17/2012 03:36 AM, Tejun Heo wrote:
>>> +static void cgroup_clear_directory(struct dentry *dir)
>>> +{
>>> +	struct cgroup *cgrp = __d_cgrp(dir);
>>> +
>>> +	while (!list_empty(&cgrp->files))
>>> +		cgroup_rm_file(cgrp, NULL);
>>> +	WARN_ON_ONCE(!list_empty(&dir->d_subdirs));
>>>   }
>>
>>
>> I am hitting this warning here under pretty much normal conditions.
>> You forgot to account for trivial directories like "."
>>
>> I'll send a patch ontop of what you have.
>
> Heh, yeah, I hit that yesterday too and was gonna look into that
> today.  Is the patch coming? :)
>
> Thanks.

I was about to send it together with my proposal for sock memcg, so I'm 
compile testing that under multiple config options just to be sure we're 
fine.

That's more or less what I have, see if you agree. I tried to keep the 
warning itself, because it is valuable...


--------------030309020803090007030503
Content-Type: text/x-patch;
	name="0001-don-t-trigger-warning-when-d_subdirs-is-not-empty.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="0001-don-t-trigger-warning-when-d_subdirs-is-not-empty.patch"

From 04604201411ab0a14fa1447072cd1b273d0774ed Mon Sep 17 00:00:00 2001
From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Date: Tue, 20 Mar 2012 18:12:55 +0400
Subject: [PATCH] don't trigger warning when d_subdirs is not empty.

It is never empty at this point, because of the self references.
a better test is to see if any of them gets d_inode set.

Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index cf7b298..b45a653 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -947,10 +947,16 @@ static int cgroup_rm_file(struct cgroup *cgrp, const struct cftype *cft)
 static void cgroup_clear_directory(struct dentry *dir)
 {
 	struct cgroup *cgrp = __d_cgrp(dir);
+	struct list_head *child;
 
 	while (!list_empty(&cgrp->files))
 		cgroup_rm_file(cgrp, NULL);
-	WARN_ON_ONCE(!list_empty(&dir->d_subdirs));
+
+	list_for_each(child, &dir->d_subdirs) {
+		struct dentry *d;
+		d = list_entry(child, struct dentry, d_u.d_child);
+		WARN_ON_ONCE(d->d_inode);
+	}
 }
 
 /*
-- 
1.7.7.6


--------------030309020803090007030503
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--------------030309020803090007030503--
