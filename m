From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 3/3] memcgoup: allow memory.failcnt to be reset
Date: Tue, 11 Mar 2008 19:16:49 +0900
Message-ID: <20080311191649.32a2cbae.kamezawa.hiroyu@jp.fujitsu.com>
References: <47D65A3E.100@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47D65A3E.100-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Pavel-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 11 Mar 2008 19:09:02 +0900
Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:

> Allow memory.failcnt to be reset to 0:
> 
>         echo 0 > memory.failcnt
> 
> And '0' is the only valid value.
> 
Can't this be generic resource counter function ?

Thanks,
-Kame


> This is useful when testing or observing the memory resource
> controller. Without this function, one will have to remember
> the previous failcnt to decide whether memory reclaim has
> happened *again*.
> 
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  Documentation/controllers/memory.txt |    4 +++-
>  mm/memcontrol.c                      |   15 +++++++++++++++
>  2 files changed, 18 insertions(+), 1 deletions(-)
> 
> diff --git a/Documentation/controllers/memory.txt b/Documentation/controllers/memory.txt
> index 866b9cd..28f80e3 100644
> --- a/Documentation/controllers/memory.txt
> +++ b/Documentation/controllers/memory.txt
> @@ -194,7 +194,9 @@ this file after a write to guarantee the value committed by the kernel.
>  4096
>  
>  The memory.failcnt field gives the number of times that the cgroup limit was
> -exceeded.
> +exceeded. It can be reset.
> +
> +# echo 0 > memory.failcnt
>  
>  The memory.stat file gives accounting information. Now, the number of
>  caches, RSS and Active pages/Inactive pages are shown.
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6145031..fd26dc2 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -883,6 +883,20 @@ static int mem_force_empty_write(struct cgroup *cont, struct cftype *cft,
>  	return ret;
>  }
>  
> +static int mem_failcnt_write(struct cgroup *cont, struct cftype *cft,
> +			     u64 val)
> +{
> +	struct res_counter *counter;
> +
> +	if (val != 0)
> +		return -EINVAL;
> +
> +	counter = &mem_cgroup_from_cont(cont)->res;
> +	res_counter_write_u64(counter, cft->private, 0);
> +
> +	return 0;
> +}
> +
>  static const struct mem_cgroup_stat_desc {
>  	const char *msg;
>  	u64 unit;
> @@ -934,6 +948,7 @@ static struct cftype mem_cgroup_files[] = {
>  	{
>  		.name = "failcnt",
>  		.private = RES_FAILCNT,
> +		.write_u64 = mem_failcnt_write,
>  		.read_u64 = mem_cgroup_read,
>  	},
>  	{
> -- 
> 1.5.4.rc3
> 
