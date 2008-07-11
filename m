From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH][RFC] dirty balancing for cgroups
Date: Fri, 11 Jul 2008 14:15:11 +0900
Message-ID: <20080711141511.515e69a5.kamezawa.hiroyu__28580.8911467486$1215754757$gmane$org@jp.fujitsu.com>
References: <20080711085449.ba7d14dd.kamezawa.hiroyu@jp.fujitsu.com>
	<20080711040657.87AE71E3DF1@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080711040657.87AE71E3DF1-Pcsii4f/SVk@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 11 Jul 2008 13:06:57 +0900 (JST)
yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi) wrote:

> hi,
> 
> > On Wed,  9 Jul 2008 15:00:34 +0900 (JST)
> > yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org (YAMAMOTO Takashi) wrote:
> > 
> > > hi,
> > > 
> > > the following patch is a simple implementation of
> > > dirty balancing for cgroups.  any comments?
> > > 
> > > it depends on the following fix:
> > > 	http://lkml.org/lkml/2008/7/8/428
> > > 
> > 
> > A few comments  ;)
> 
> thanks for comments.
> 
> >  - This looks simple but, could you merge this into memory resource controller ?
> 
> why?
> 
3 points.
 1. Is this useful if used alone ?
 2. memcg requires this kind of feature, basically.
 3. I wonder I need more work to make this work well under memcg.

If chasing page->cgroup and memcg make this patch much more complex,
I think this style of implimentation is a choice.

 About 3. 
    Does this works well if I changes get_dirty_limit()'s
    determine_dirtyable_memory() calculation under memcg ?
    But to do this seems not valid if dirty_ratio cgroup and memcg cgroup 
    containes different set of tasks.
 
Thanks,
-Kame
