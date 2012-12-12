From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH] mm/hugetlb: create hugetlb cgroup file in hugetlb_init
Date: Wed, 12 Dec 2012 13:48:17 +0100
Message-ID: <20121212124817.GF32081__42254.4591049247$1355316527$gmane$org@dhcp22.suse.cz>
References: <50C83F97.3040009@huawei.com>
	<20121212101917.GD32081@dhcp22.suse.cz> <50C85FFD.10305@huawei.com>
	<20121212112329.GE32081@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121212112329.GE32081-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Xishi Qiu <qiuxishi-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Liujiang <jiang.liu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, dhillf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Jianguo Wu <wujianguo-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, Hanjun Guo <guohanjun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Jiang Liu <liuj97-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed 12-12-12 12:23:29, Michal Hocko wrote:
> On Wed 12-12-12 18:44:13, Xishi Qiu wrote:
[...]
> > Hi Michal,
> > 
> > __initcall functions will be called in
> > start_kernel()
> > 	rest_init()  // -> slab is already
> > 		kernel_init()
> > 			kernel_init_freeable()
> > 				do_basic_setup()
> > 					do_initcalls()
> > 
> > and setup_hugepagesz() will be called in
> > start_kernel()
> > 	parse_early_param()  // -> before mm_init() -> kmem_cache_init()
> > 
> > Is this right?
> 
> Yes this is right. I just noticed that kmem_cache_init_late is an __init
> function as well and didn't realize it is called directly. Sorry about
> the confusion.
> Anyway I still think it would be a better idea to move the call into the
> hugetlb_cgroup_create callback where it is more logical IMO but now that
> I'm looking at other controllers (blk and kmem.tcp) they all do this from
> init calls as well. So it doesn't make sense to have hugetlb behave
> differently.
> 
> So
> Acked-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>

Ohh, and this deserves to be backported to stable (since 3.6).
-- 
Michal Hocko
SUSE Labs
