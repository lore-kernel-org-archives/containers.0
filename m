From: yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi)
Subject: Re: [PATCH][RFC] dirty balancing for cgroups
Date: Fri, 11 Jul 2008 14:59:26 +0900 (JST)
Message-ID: <20080711055926.9AF4F5A03__12740.2357910343$1215756090$gmane$org@siro.lan>
References: <20080711141511.515e69a5.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: Your message of "Fri, 11 Jul 2008 14:15:11 +0900"
	<20080711141511.515e69a5.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

> > >  - This looks simple but, could you merge this into memory resource controller ?
> > 
> > why?
> > 
> 3 points.
>  1. Is this useful if used alone ?

it can be.  why not?

>  2. memcg requires this kind of feature, basically.
> 
>  3. I wonder I need more work to make this work well under memcg.

i'm not sure if i understand these points.  can you explain a bit?

my patch penalizes heavy-writer cgroups as task_dirty_limit does
for heavy-writer tasks.  i don't think that it's necessary to be
tied to the memory subsystem because i merely want to group writers.

otoh, if you want to limit the number (or percentage or whatever) of
dirty pages in a memory cgroup, it can't be done independently from
the memory subsystem, of course.  it's another story, tho.

YAMAMOTO Takashi

> 
> If chasing page->cgroup and memcg make this patch much more complex,
> I think this style of implimentation is a choice.
> 
>  About 3. 
>     Does this works well if I changes get_dirty_limit()'s
>     determine_dirtyable_memory() calculation under memcg ?
>     But to do this seems not valid if dirty_ratio cgroup and memcg cgroup 
>     containes different set of tasks.
>  
> Thanks,
> -Kame
