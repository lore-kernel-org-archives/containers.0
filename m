From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.10] cgroup: make cgroup_path() not print
	double slashes
Date: Mon, 15 Apr 2013 11:10:33 +0800
Message-ID: <516B6FA9.9030301@huawei.com>
References: <20130414173704.GB3050@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130414173704.GB3050-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2013/4/15 1:37, Tejun Heo wrote:
>>From 277f3d4be79aefe2071d9053a9c7c89c4e5dad30 Mon Sep 17 00:00:00 2001
> From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Date: Sun, 14 Apr 2013 10:32:19 -0700
> 
> While reimplementing cgroup_path(), 65dff759d2 ("cgroup: fix
> cgroup_path() vs rename() race") introduced a bug where the path of a
> non-root cgroup would have two slahses at the beginning, which is
> caused by adding '/' before the name of the root cgroup which is an
> empty string.
> 

I guess I booted a wrong kernel when testing that patch...

>  $ grep systemd /proc/self/cgroup
>  1:name=systemd://user/root/1
> 
> Fix it by special casing root cgroup.
> 

I made a patch to fix it before the weekend, but didn't post it. It doesn't
treat root-only cgroup specially.

You can apply whichever you like better.

> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> ---
> Applying to cgroup/for-3.10.
> 
> Thanks.
> 
>  kernel/cgroup.c | 13 ++++++++-----
>  1 file changed, 8 insertions(+), 5 deletions(-)
> 

[PATCH] cgroup: make cgroup_path() not print double slashes

While reimplementing cgroup_path(), 65dff759d2 ("cgroup: fix
cgroup_path() vs rename() race") introduced a bug where the path of a
non-root cgroup would have two slahses at the beginning, which is
caused by treating the root cgroup which has the name '/' like
non-root cgroups.

Fix it by not adding '/' if it's the root cgroup.

 $ grep systemd /proc/self/cgroup
 1:name=systemd://user/root/1

Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 kernel/cgroup.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 06aeb42..2a28425 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1809,14 +1809,15 @@ int cgroup_path(const struct cgroup *cgrp, char *buf, int buflen)
 			goto out;
 		memcpy(start, name, len);
 
-		if (!cgrp->parent)
+		cgrp = cgrp->parent;
+		if (!cgrp)
 			break;
+		if (!cgrp->parent)
+			continue;
 
 		if (--start < buf)
 			goto out;
 		*start = '/';
-
-		cgrp = cgrp->parent;
 	}
 	ret = 0;
 	memmove(buf, start, buf + buflen - start);
-- 
1.8.0.2
