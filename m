From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: memrlimit controller merge to mainline
Date: Tue, 29 Jul 2008 15:01:11 +0900
Message-ID: <20080729150111.f879c989.kamezawa.hiroyu@jp.fujitsu.com>
References: <6599ad830807250114h7ab0fdb1u98c0968961647642@mail.gmail.com>
	<Pine.LNX.4.64.0807251004570.31120@blonde.site>
	<6599ad830807250706t23e483b5j18d683c0470d1d22@mail.gmail.com>
	<Pine.LNX.4.64.0807251715070.12089@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0807251715070.12089-popGQ1T0qN76K7/ahGyk6A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>
Cc: Rik van Riel <riel-ebMLmSuQjDVBDgjK7y7TUQ@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org" <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, Linux-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 25 Jul 2008 17:46:45 +0100 (BST)
Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org> wrote:

> IIRC Rik expressed the same by pointing out that a cgroup at its
> swap limit would then be forced to grow in mem (until it hits its
> mem limit): so controlling the less precious resource would increase
> pressure on the more precious resource.  (Actually, that probably
> bears little relation to what he said - sorry, Rik!)  I don't recall
> what answer he got, perhaps I'd be persuaded if I heard it again.
> 
Added Nishimura to CC.

IMHO, from user point of view, both of
 - having 2 controls as mem controller + swap controller
 - mem + swap controller
doesn't have much difference. The users will use as they like.

From memory controller's point of view, treating mem+swap by the same
controller makes sense. Because memory controller can check wheter we can use
more swap or not, we can avoid hopeless-scanning of Anon at swap-shortage.
(By split-lru, I think we can do this avoidance.)
 
Another-Topic?

In recent servers, memory is big, swap is (relatively) small.
And under memory resource controller, the whole swap is easily occupied
by a group. I want to avoid it.

For users, swap is not precious because it's not fast. 
But for memory reclaiming, swap is precious resource to page out
anonymous/shmem/tmpfs memory. I think usual system-admin considers swap as
some emergency spare of memory. I'd like to allow this "emergency spare" to each
cgroup.
(For example, swap is used even if vm.swappiness==0. This is for avoiding OOM-Killer
 under some situation, this behavior is added by Rik.)


== following is another use case I explained to Rik at 23/May/08 ==

IIRC, a man shown his motivation to controll swap in OLS2007/BOF as following.
Consider following system. (and there is no swap controller.) 
Memory 4G. Swap 1G. with 2 cgroups A, B.

state 1) swap is not used.
  A....memory limit to be 1G  no swap usage memory_usage=0M
  B....memory limit to be 1G  no swap usage memory_usage=0M

state 2) Run a big program on A.
  A....memory limit to be 1G and try to use 1.7G. uses 700MBytes of swap.
       memory_usage=1G swap_usage=700M
  B....memory_usage=0M

state 3) A some of programs ends in 'A'
  A....memory_usage=500M swap_usage=700M
  B....memory_usage=0M.

state 4) Run a big program on B.
  A...memory_usage=500M swap_usage=700M.
  B...memory_usage=1G   swap_usage=300M

Group B can only use 1.3G because of unfair swap use of group A.
But users think why A uses 700M of swap with 500M of free memory....
==



Thanks,
-Kame
