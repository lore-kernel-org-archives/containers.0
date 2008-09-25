From: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [dm-devel] Re: [PATCH 4/8] bio-cgroup: Split the cgroup memory
	subsystem into two parts
Date: Thu, 25 Sep 2008 17:46:34 +0900 (JST)
Message-ID: <20080925.174634.02448435.taka__21951.9194834449$1222332604$gmane$org@valinux.co.jp>
References: <20080924.191234.104048747.ryov@valinux.co.jp>
	<20080924.191309.189710495.ryov@valinux.co.jp>
	<20080925161400.602ddfdb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080925161400.602ddfdb.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

> I posted new ones.
>  - http://lkml.org/lkml/2008/9/25/33 
>  (changes in page_cgroup) http://lkml.org/lkml/2008/9/25/56
> (I'm not sure this gets Ack or Nack. but direction will not change.)
> 
> Then, please tell me if you have new troubles with new ones.
> Or if you have requests.
> Major changes are
> 
>   - page_cgroup.h is added.
>   - lookup_page_cgroup(struct page*), lock_page_cgroup() etc.. is exported.
>   - All page_cgroup are allocated at boot.
>   - you can use atomic operation to modify page_cgroup->flags.

Good new!

> One concern from me to this bio_cgroup is that this increases size of
> +#ifdef CONFIG_CGROUP_BIO
> +	struct list_head blist;		/* for bio_cgroup page list */
> +	struct bio_cgroup *bio_cgroup;
> +#endif
> struct page_cgroup...more 24bytes per 4096bytes.
> Could you reduce this ? I think 8bytes per memcg is reasonable.
> Can you move lru to bio itself ?

I have a plan on getting rid of the blist after your work is done,
whose design will depend on that all page_cgroups are preallocated.
I also think the size of bio_cgroup can be reduced if making bio_cgroup
contain a bio-cgroup ID instead of the pointer.

Just wait! :)

> This makes page_cgroup to be 64bytes from 40bytes and makes it larger
> than mem_map....
> After bio_cgroup, page_cgroup, allocated at boot, size on my 48GB box 
> will jump up.
> 480MB -> 760MB.
> 
> Thanks,
> -Kame
