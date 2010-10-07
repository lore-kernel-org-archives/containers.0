From: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Subject: Re: [RFC] Restrict size of page_cgroup->flags
Date: Thu, 7 Oct 2010 09:54:58 +0900
Message-ID: <20101007095458.a992969e.nishimura__36063.3172480904$1286413284$gmane$org@mxp.nes.nec.co.jp>
References: <20101006142314.GG4195@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101006142314.GG4195-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 6 Oct 2010 19:53:14 +0530
Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

> I propose restricting page_cgroup.flags to 16 bits. The patch for the
> same is below. Comments?
> 
> 
> Restrict the bits usage in page_cgroup.flags
> 
> From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> 
> Restricting the flags helps control growth of the flags unbound.
> Restriciting it to 16 bits gives us the possibility of merging
> cgroup id with flags (atomicity permitting) and saving a whole
> long word in page_cgroup
> 
I agree that reducing the size of page_cgroup would be good and important.
But, wouldn't it be better to remove ->page, if possible ?

Thanks,
Daisuke Nishimura.

> Signed-off-by: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> ---
> 
>  include/linux/page_cgroup.h |    3 +++
>  mm/page_cgroup.c            |    1 +
>  2 files changed, 4 insertions(+), 0 deletions(-)
> 
> 
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index 872f6b1..10c37b4 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -44,8 +44,11 @@ enum {
>  	PCG_FILE_WRITEBACK, /* page is under writeback */
>  	PCG_FILE_UNSTABLE_NFS, /* page is NFS unstable */
>  	PCG_MIGRATION, /* under page migration */
> +	PCG_MAX_NR,
>  };
>  
> +#define PCG_MAX_BIT_SIZE	16
> +
>  #define TESTPCGFLAG(uname, lname)			\
>  static inline int PageCgroup##uname(struct page_cgroup *pc)	\
>  	{ return test_bit(PCG_##lname, &pc->flags); }
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 5bffada..e16ad2e 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -258,6 +258,7 @@ void __init page_cgroup_init(void)
>  	unsigned long pfn;
>  	int fail = 0;
>  
> +	BUILD_BUG_ON(PCG_MAX_NR >= PCG_MAX_BIT_SIZE);
>  	if (mem_cgroup_disabled())
>  		return;
>  
> 
> -- 
> 	Three Cheers,
> 	Balbir
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo-Bw31MaZKKs0EbZ0PF+XxCw@public.gmane.org  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org"> email-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org </a>
> 
