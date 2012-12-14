From: Jianguo Wu <wujianguo-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 UPDATE] mm/hugetlb: create hugetlb cgroup file in
	hugetlb_init
Date: Fri, 14 Dec 2012 09:38:19 +0800
Message-ID: <50CA830B.2050209__12247.7447767325$1355449169$gmane$org@huawei.com>
References: <50C94DE5.2040302@huawei.com>
	<20121213135656.GB27775@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121213135656.GB27775-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Liujiang <jiang.liu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, dhillf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hanjun Guo <guohanjun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, qiuxishi <qiuxishi-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Jiang Liu <liuj97-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On 2012/12/13 21:56, Michal Hocko wrote:

> On Thu 13-12-12 11:39:17, Jianguo Wu wrote:
>> Build kernel with CONFIG_HUGETLBFS=y,CONFIG_HUGETLB_PAGE=y
>> and CONFIG_CGROUP_HUGETLB=y, then specify hugepagesz=xx boot option,
>> system will boot fail.
>>
>> This failure is caused by following code path:
>> setup_hugepagesz
>> 	hugetlb_add_hstate
>> 		hugetlb_cgroup_file_init
>> 			cgroup_add_cftypes
>> 				kzalloc <--slab is *not available* yet
>>
>> For this path, slab is not available yet, so memory allocated will be
>> failed, and cause WARN_ON() in hugetlb_cgroup_file_init().
>>
>> So I move hugetlb_cgroup_file_init() into hugetlb_init().
>>
>> Changelog:
>>   do code refactor as suggesting by Aneesh
>>   add Reviewed-by and Acked-by 
>>
>> Signed-off-by: Jianguo Wu <wujianguo-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>> Signed-off-by: Jiang Liu <jiang.liu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
>> Acked-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
> 
> Any reason to not add Cc: stable as I suggested earlier?

Hi Michal,

Sorry for forgot that.
Andrew has added Cc: stable when added to -mm tree.
