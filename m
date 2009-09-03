From: Munehiro Ikeda <m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org>
Subject: Re: [PATCH 07/23] io-controller: Common hierarchical fair queuing
	code in elevaotor layer
Date: Wed, 02 Sep 2009 23:08:09 -0400
Message-ID: <4A9F3319.8040509__46411.4888724454$1251947467$gmane$org@ds.jp.nec.com>
References: <1251495072-7780-1-git-send-email-vgoyal@redhat.com>
	<1251495072-7780-8-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1251495072-7780-8-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

Vivek Goyal wrote, on 08/28/2009 05:30 PM:
> +static struct io_group *io_find_alloc_group(struct request_queue *q,
> +			struct cgroup *cgroup, struct elv_fq_data *efqd,
> +			int create)
> +{
> +	struct io_cgroup *iocg = cgroup_to_io_cgroup(cgroup);
> +	struct io_group *iog = NULL;
> +	/* Note: Use efqd as key */
> +	void *key = efqd;
> +
> +	/*
> +	 * Take a refenrece to css object. Don't want to map a bio to
> +	 * a group if it has been marked for deletion
> +	 */
> +
> +	if (!css_tryget(&iocg->css))
> +		return iog;

cgroup_to_io_cgroup() returns NULL if only blkio subsystem
is mounted but io subsystem is not.  It can cause NULL pointer
access.

Signed-off-by: Munehiro "Muuhh" Ikeda <m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org>
---
 block/elevator-fq.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index b723c12..6714e73 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -1827,7 +1827,7 @@ static struct io_group *io_find_alloc_group(struct request_queue *q,
         * a group if it has been marked for deletion
         */
 
-       if (!css_tryget(&iocg->css))
+       if (!iocg || !css_tryget(&iocg->css))
                return iog;
 
        iog = io_cgroup_lookup_group(iocg, key);
-- 
1.6.2.5


-- 
IKEDA, Munehiro
  NEC Corporation of America
    m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org
