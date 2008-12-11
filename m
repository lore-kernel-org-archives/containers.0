From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC][PATCH 2/3] CGroups: Use hierarchy_mutex in memory controller
Date: Thu, 11 Dec 2008 15:53:23 +0900
Message-ID: <20081211155323.957eb73c.kamezawa.hiroyu__15938.6733001613$1228978656$gmane$org@jp.fujitsu.com>
References: <20081210233654.563182000@menage.corp.google.com>
	<20081210234432.236302000@menage.corp.google.com>
	<20081211094938.85b00cf3.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830812101652o25bc33f3r2a710e0879f9b196@mail.gmail.com>
	<20081211100501.bf538f0c.kamezawa.hiroyu@jp.fujitsu.com>
	<20081211063307.GL3008@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081211063307.GL3008-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 11 Dec 2008 12:03:07 +0530
Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> [2008-12-11 10:05:01]:
> 
> > On Wed, 10 Dec 2008 16:52:57 -0800
> > Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> > 
> > > On Wed, Dec 10, 2008 at 4:49 PM, KAMEZAWA Hiroyuki
> > > <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> > > >
> > > >        an operation like rmdir() in somewhere.
> > > >                hierarchy_lock for A (acquired)
> > > >                hierarchy_lock for B (waiting)
> > > >
> > > >        in subsys A.
> > > >                mmap_sem (acquired)
> > > >                hierarchy_lock for A (waiting)
> > > >        in subsys B.
> > > >                hierarchy_lock for B (aquired)
> > > >                mmap_sem             (waiting)
> > > >
> > > 
> > > That's a valid deadlock - you'd need to require the mmap_sem nests
> > > either inside all hierarchy_mutexes or else outside all of them.
> > > 
> > This was a found dead lock between memcg and cpuset.
> > 
> > another one was 
> > 
> > 	an operation like rmdir() in somewhere.
> > 		hierarchy_lock for memcg (acquired)
> > 		hierarchy_lock for B (waiting)
> > 
> > 	in subsys B.
> > 		hierarchy_lock for B (aquired)
> 
> But then the hierarchy_locks acquired will be different right?
> 
yes.

> > 		have to do some memory reclaim -> hierarchy_lock for memcg (waiting)
> > 
> > I have no objections to hierarchy_lock itself but calling context to memcg is very
> > complicated and simple replace of these locks will be just a small help.
> 
> Could you please explain the race better?
> 
I explained...
One example was mmap_sem. above one is recursive lock in cpuset you tried to fix.
(Fortunately, cpuset's subsys ID is smaller than memcg's one. you'll not see
 in real environment.)
And there are other unknown subsyses are planned, bio, checkpoint, etc..

Could you write a document to explain what kind of nest of locks are allowed
before merging this ?

Thanks,
-Kame
