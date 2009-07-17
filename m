From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 22/25] io-controller: Per io group bdi congestion interface
Date: Fri, 17 Jul 2009 09:52:46 -0400
Message-ID: <20090717135246.GA16839__44677.7898738675$1247838952$gmane$org@redhat.com>
References: <1246564917-19603-1-git-send-email-vgoyal@redhat.com>
	<1246564917-19603-23-git-send-email-vgoyal@redhat.com>
	<4A5FC2CA.1040609@ds.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A5FC2CA.1040609-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Munehiro Ikeda <m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Jul 16, 2009 at 08:16:10PM -0400, Munehiro Ikeda wrote:
> Hi,
> 
> Vivek Goyal wrote, on 07/02/2009 04:01 PM:
> > diff --git a/block/blk-core.c b/block/blk-core.c
> > index 2035c20..79fe6a9 100644
> > --- a/block/blk-core.c
> > +++ b/block/blk-core.c
> > @@ -90,6 +90,27 @@ void blk_queue_congestion_threshold(struct request_queue *q)
> >   	q->nr_congestion_off = nr;
> >   }
> > 
> > +#ifdef CONFIG_GROUP_IOSCHED
> > +int blk_queue_io_group_congested(struct backing_dev_info *bdi, int bdi_bits,
> > +					struct page *page)
> > +{
> > +	int ret = 0;
> > +	struct request_queue *q = bdi->unplug_io_data;
> > +
> > +	if (!q&&  !q->elevator)
> > +		return bdi_congested(bdi, bdi_bits);
> 
> It causes NULL pointer dereference for brd etc.
> 
> Signed-off-by: Munehiro "Muuhh" Ikeda <m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org>
> ---
>  block/blk-core.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/block/blk-core.c b/block/blk-core.c
> index 79fe6a9..39fab66 100644
> --- a/block/blk-core.c
> +++ b/block/blk-core.c
> @@ -97,7 +97,7 @@ int blk_queue_io_group_congested(struct backing_dev_info *bdi, int bdi_bits,
>  	int ret = 0;
>  	struct request_queue *q = bdi->unplug_io_data;
>  
> -	if (!q && !q->elevator)
> +	if (!q || !q->elevator)
>  		return bdi_congested(bdi, bdi_bits);
>  

Hi,

Thanks for the patch. I also noticed this recently and fixed it for next
to be posted version.

Thanks
Vivek

>  	/* Do we need to hold queue lock? */
> -- 
> 1.6.2.5
> 
> 
> -- 
> IKEDA, Munehiro
>   NEC Corporation of America
>     m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org
