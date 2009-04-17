From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/9] io-throttle documentation
Date: Fri, 17 Apr 2009 12:41:35 +0200
Message-ID: <20090417104134.GA19872__27927.8848822743$1239965599$gmane$org@linux>
References: <1239740480-28125-1-git-send-email-righi.andrea@gmail.com>
	<1239740480-28125-2-git-send-email-righi.andrea@gmail.com>
	<20090417102417.88a0ef93.kamezawa.hiroyu@jp.fujitsu.com>
	<49E7E1CF.6060209@cn.fujitsu.com> <20090417102539.GA16838@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090417102539.GA16838@linux>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Apr 17, 2009 at 12:25:40PM +0200, Andrea Righi wrote:
> So, what about implementing the bio-cgroup functionality as cgroup "page
> tracking" infrastructure and provide the following interfaces:
> 
> /*
>  * Encode the cgrp->css.id in page_group->flags

sorry, I meant css_id(struct cgroup_subsys_state *css) here.

>  */
> void set_cgroup_page_owner(struct page *page, struct cgroup *cgrp);
> 
> /*
>  * Returns the cgroup owner of a page, decoding the cgroup id from
>  * page_cgroup->flags.
>  */
> struct cgroup *get_cgroup_page_owner(struct page *page);

Or better, even more generic:

/*
 * Encode id in page_group->flags.
 */
void set_page_id(struct page *page, unsigned short id);

/*
 * Returns the id of a page, decoding it from page_cgroup->flags.
 */
unsigned short get_page_id(struct page *page);

Then we can use css_id() for cgroups, or any kind of ID for other
potential users (dm-ioband, etc.).

-Andrea

> 
> This also wouldn't increase the size of page_cgroup because we can
> encode the cgroup id in the unused bits of page_cgroup->flags, as
> originally suggested by Kame.
> 
> And I think it could be used also by dm-ioband, even if it's not a
> cgroup-based subsystem... but I may be wrong. Ryo what's your opinion?
