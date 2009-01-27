From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC] [PATCH] Cgroup based OOM killer controller
Date: Tue, 27 Jan 2009 12:56:07 +0530
Message-ID: <20090127072607.GM504__47072.2601785839$1233041356$gmane$org@balbir.in.ibm.com>
References: <20090126195431.GC504@balbir.in.ibm.com>
	<20090126195622.1d5bf488@lxorguk.ukuu.org.uk>
	<20090127155825.D476.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090127155825.D476.KOSAKI.MOTOHIRO-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arve Hj?nnev?g <arve-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, Linus-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Chris Snook <csnook-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Id: containers.vger.kernel.org

* KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org> [2009-01-27 16:02:34]:

> Hi
> 
> > > > As Alan Cox suggested/wondered in this thread, 
> > > > http://lkml.org/lkml/2009/1/12/235 , this is a container group based approach 
> > > > to override the oom killer selection without losing all the benefits of the 
> > > > current oom killer heuristics and oom_adj interface.
> > > > 
> > > > It adds a tunable oom.victim to the oom cgroup. The oom killer will kill the 
> > > > process using the usual badness value but only within the cgroup with the 
> > > > maximum value for oom.victim before killing any process from a cgroup with a 
> > > > lesser oom.victim number. Oom killing could be disabled by setting 
> > > > oom.victim=0.
> > > 
> > > Looking at the patch, I wonder if it is time for user space OOM
> > > notifications that were discussed during the containers mini-summit.
> > > The idea is to inform user space about OOM's and let user space take
> > > action, if no action is taken, the default handler kicks in.
> > 
> > The OLPC folks (Marcelo I believe) posted code for this and I believe
> > OLPC is using this functionality internally so that under memory pressure
> > (before we actually hit OOM) programs can respond by doing stuff like
> > evicting caches.
> 

I did see the patches on linux-mm, but a more generic cgroup patch
would help both cases, in the absence of cgroups, the default cgroup
will contain all tasks and can carry out the handling.

> Confused.
> 
> As far as I know, people want the method of flexible cache treating.
> but oom seems less flexible than userland notification.
> 
> Why do you think notification is bad?

I did not find Alan's message confusing or stating that notification
was bad, but I might be misreading it.

-- 
	Balbir
