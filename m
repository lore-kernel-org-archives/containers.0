From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 03/11] cgroup: bring some sanity to naming around
	cg_cgroup_link
Date: Thu, 13 Jun 2013 10:34:56 +0800
Message-ID: <51B92FD0.8020907@huawei.com>
References: <1371070996-20613-1-git-send-email-tj@kernel.org>
	<1371070996-20613-4-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1371070996-20613-4-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, koverstreet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2013/6/13 5:03, Tejun Heo wrote:
> cgroups and css_sets are mapped M:N and this M:N mapping is
> represented by struct cg_cgroup_link which points to forms linked
> lists on both sides.  The naming around this already confusing struct
> is pretty bad.
> 
>>From cgroup side, it starts off ->css_sets and runs through
> ->cgrp_link_list.  From css_set side, it starts off ->cg_links and
> runs through ->cg_link_list.  This is rather reversed as
> cgrp_link_list is used to iterate css_sets and cg_link_list cgroups.
> Also, this is the only place which is still using the confusing "cg"
> for css_sets.  This patch cleans it up a bit.
> 
> * s/cgroup->css_sets/cgroup->cset_links/
>   s/css_set->cg_links/css_set->cgrp_links/
>   s/cgroup_iter->cg_link/cgroup_iter->cset_link/
> 
> * s/cg_cgroup_link/cgrp_cset_link/
> 
> * s/cgrp_cset_link->cg/cgrp_cset_link->cset/
>   s/cgrp_cset_link->cgrp_link_list/cgrp_cset_link->cset_link/
>   s/cgrp_cset_link->cg_link_list/cgrp_cset_link->cgrp_link/
> 
> * s/init_css_set_link/init_cgrp_cset_link/
>   s/free_cg_links/free_cgrp_cset_links/
>   s/allocate_cg_links/allocate_cgrp_cset_links/
> 
> * s/cgl[12]/link[12]/ in compare_css_sets()
> 
> * s/saved_link/tmp_link/ s/tmp/tmp_links/ and a couple similar
>   adustments.
> 
> * Comment and whiteline adjustments.
> 
> After the changes, we have
> 
> 	list_for_each_entry(link, &cont->cset_links, cset_link) {
> 		struct css_set *cset = link->cset;
> 
> instead of
> 
> 	list_for_each_entry(link, &cont->css_sets, cgrp_link_list) {
> 		struct css_set *cset = link->cg;
> 

Those renames really make the code more readable! I have to think for a while
everytime I see those namings.
