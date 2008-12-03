From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] Unused check for thread group leader in
	mem_cgroup_move_task
Date: Wed, 3 Dec 2008 19:10:25 +0530
Message-ID: <20081203134024.GD17701@balbir.in.ibm.com>
References: <200811291259.27681.knikanth@suse.de>
	<20081201101208.08e0aa98.kamezawa.hiroyu@jp.fujitsu.com>
	<200812010951.36392.knikanth@suse.de>
	<20081201133030.0a330c7b.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081201133030.0a330c7b.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, nikanth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

* KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> [2008-12-01 13:30:30]:

> On Mon, 1 Dec 2008 09:51:35 +0530
> Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org> wrote:
> 
> > Ok. Then should we remove the unused code which simply checks for thread group 
> > leader but does nothing?
> >  
> > Thanks
> > Nikanth
> > 
> Hmm, it seem that code is obsolete. thanks.
> Balbir, how do you think ?
> 
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> 
> Anyway we have to visit here, again.

Sorry, I did not review this patch. The correct thing was nikanth did
at first, move this to can_attach(). Why would we allow threads to
exist in different groups, but still mark them as being accounted to
the thread group leader.

It can be a bit confusing for end users, it can be helpful when all
controllers are mounted together. I agree we did not do anything
useful in move_task(). The correct check now, should be for mm->owner.

If the common case is going to be that memory and cpu are mounted
together, then this patch is correct, but it can be confusing to users
who look at tasks/threads, but as the threads consume memory, the
accounting will happen with mm->owner.

-- 
	Balbir
