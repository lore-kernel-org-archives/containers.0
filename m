From: "IKEDA, Munehiro" <m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org>
Subject: Re: [PATCH 18/18] io-controller: Debug hierarchical IO scheduling
Date: Wed, 06 May 2009 17:40:43 -0400
Message-ID: <4A0203DB.1090809__23568.0606835105$1241646361$gmane$org@ds.jp.nec.com>
References: <1241553525-28095-1-git-send-email-vgoyal@redhat.com>
	<1241553525-28095-19-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1241553525-28095-19-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Vivek,

Patching and compilation error occurred on the 18/18 patch.
I know this is a patch for debug but report them in case.


Vivek Goyal wrote:
> @@ -2203,6 +2241,25 @@ EXPORT_SYMBOL(elv_get_slice_idle);
>  void elv_ioq_served(struct io_queue *ioq, bfq_service_t served)
>  {
>  	entity_served(&ioq->entity, served, ioq->nr_sectors);

Patch failed due to this line.  I guess this should be

	entity_served(&ioq->entity, served);


> +
> +#ifdef CONFIG_DEBUG_GROUP_IOSCHED
> +		{
> +			struct elv_fq_data *efqd = ioq->efqd;
> +			char path[128];
> +			struct io_group *iog = ioq_to_io_group(ioq);
> +			io_group_path(iog, path, sizeof(path));
> +			elv_log_ioq(efqd, ioq, "ioq served: QSt=0x%lx QSs=0x%lx"
> +				" QTt=0x%lx QTs=0x%lx grp=%s GTt=0x%lx "
> +				" GTs=0x%lx rq_queued=%d",
> +				served, ioq->nr_sectors,
> +				ioq->entity.total_service,
> +				ioq->entity.total_sector_service,
> +				path,
> +				iog->entity.total_service,
> +				iog->entity.total_sector_service,
> +				ioq->nr_queued);
> +		}
> +#endif
>  }

Because
  io_entity::total_service
and
  io_entity::total_sector_service
are not defined, compilation failed if CONFIG_DEBUG_GROUP_IOSCHED=y
here. (and everywhere referencing entity.total_service or  entity.total_sector_service)
They need to be defined like:

diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index 1ea4ff3..6d0a735 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -147,6 +147,10 @@ struct io_entity {
        unsigned short ioprio_class, new_ioprio_class;
 
        int ioprio_changed;
+
+#ifdef CONFIG_DEBUG_GROUP_IOSCHED
+       unsigned long total_service, total_sector_service;
+#endif
 };
 
 /*

Unfortunately I couldn't figure out where and how the members
should be calculated, sorry.


-- 
IKEDA, Munehiro
  NEC Corporation of America
    m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org
