From: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: Hang with fair cgroup scheduler (reproducer is attached.)
Date: Fri, 14 Dec 2007 19:45:28 +0530
Message-ID: <20071214141528.GA6161@linux.vnet.ibm.com>
References: <20071214161834.034e6efe.kamezawa.hiroyu@jp.fujitsu.com>
	<20071214171759.59f7ba57.kamezawa.hiroyu@jp.fujitsu.com>
	<20071214094909.GG11266@elte.hu>
	<20071214195837.0d3511db.kamezawa.hiroyu@jp.fujitsu.com>
	<b647ffbd0712140447kfba5945ybde40f18653dd164@mail.gmail.com>
Reply-To: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <b647ffbd0712140447kfba5945ybde40f18653dd164-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dmitry Adamushko <dmitry.adamushko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Dec 14, 2007 at 01:47:13PM +0100, Dmitry Adamushko wrote:
> On 14/12/2007, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> > Here is much easier test.
> > (I'm sorry I'll be absent tomorrow.)
> >
> > the number of cpus is 8. ia64/NUMA.
> >
> > The hang occurs when the number of tasks is not smaller than available cpus.
> > Can be a hint ?
> >
> > [ ... ]
> >
> > [root@rhel51GA testpro]#./batech-test.sh
> > no hang.
> >
> > [root@rhel51GA testpro]#taskset 0f ./batech-test.sh
> > no hang
> >
> > [root@rhel51GA testpro]#taskset 03 ./batech-test.sh
> > hang.
> 
> have you tried :
> 
> [root@rhel51GA testpro]#taskset 01 ./batech-test.sh
> 
> hang?
> 
> just to be sure SMP does matter here (most likely yes, I guess).
> 

NUMA? I am not able to reproduce it here locally on an x86 8 CPU box.


-- 
regards,
Dhaval
