From: Danny Feng <dfeng-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroup: fix reverse unlock sequence in cgroup_get_sb
Date: Wed, 22 Jul 2009 09:57:44 +0800
Message-ID: <4A667218.7040105__10156.2255098999$1248228128$gmane$org@redhat.com>
References: <1248171926-20232-1-git-send-email-dfeng@redhat.com>
	<6599ad830907210903q7206cac2l83a9139d19c5e1a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------050805030304000303050602"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830907210903q7206cac2l83a9139d19c5e1a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

This is a multi-part message in MIME format.
--------------050805030304000303050602
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 07/22/2009 12:03 AM, Paul Menage wrote:
> On Tue, Jul 21, 2009 at 3:25 AM, Xiaotian Feng<dfeng-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>  wrote:
>> In cgroup_get_sb, the lock sequence is:
>>         mutex_lock(&inode->i_mutex);
>>         mutex_lock(&cgroup->mutex);
>> so the last unlock sequence should be:
>
> Make this "so for consistency the last ..." ?
>
> Maybe make the patch title "Make unlock sequence in cgroup_get_sb
> consistent" so someone looking through the change logs for fixes to
> backport doesn't wrongly thing that this fixes any bug"?
>

Yep, this is a trivial patch.  Modified following your suggestion, thank 
you.

>>         mutex_unlock(&cgroup->mutex);
>>         mutex_unlock(&inode->i_mutex);
>>
>> Signed-off-by: Xiaotian Feng<dfeng-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>
> Acked-by: Paul Menage<menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>
> Paul


--------------050805030304000303050602
Content-Type: text/x-patch;
 name="0001-cgroup-make-unlock-sequence-in-cgroup_get_sb-consistent.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-cgroup-make-unlock-sequence-in-cgroup_get_sb-consistent";
 filename*1=".patch"

From ff96b0dc4a5f06a0e5b7f8dfa5df2b93e993302c Mon Sep 17 00:00:00 2001
From: Xiaotian Feng <dfeng-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date: Tue, 21 Jul 2009 18:06:43 +0800
Subject: [PATCH] cgroup: make unlock sequence in cgroup_get_sb consistent

Make the last unlock sequence consistent with previous unlock sequeue.

Signed-off-by: Xiaotian Feng <dfeng-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 kernel/cgroup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 3737a68..11ef162 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1140,8 +1140,8 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
 		BUG_ON(root->number_of_cgroups != 1);
 
 		cgroup_populate_dir(root_cgrp);
-		mutex_unlock(&inode->i_mutex);
 		mutex_unlock(&cgroup_mutex);
+		mutex_unlock(&inode->i_mutex);
 	}
 
 	simple_set_mnt(mnt, sb);
-- 
1.6.2.5


--------------050805030304000303050602
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--------------050805030304000303050602--
