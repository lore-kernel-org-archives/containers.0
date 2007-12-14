From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: Re: Re: Hang with fair cgroup scheduler (reproducer is attached.)
Date: Fri, 14 Dec 2007 16:33:04 -0500 (EST)
Message-ID: <Pine.LNX.4.58.0712141614340.22005@gandalf.stny.rr.com>
References: <20071214141528.GA6161@linux.vnet.ibm.com>
	<20071214161834.034e6efe.kamezawa.hiroyu@jp.fujitsu.com>
	<20071214171759.59f7ba57.kamezawa.hiroyu@jp.fujitsu.com>
	<20071214094909.GG11266@elte.hu>
	<20071214195837.0d3511db.kamezawa.hiroyu@jp.fujitsu.com>
	<b647ffbd0712140447kfba5945ybde40f18653dd164@mail.gmail.com>
	<20442799.1197642268756.kamezawa.hiroyu@jp.fujitsu.com>
	<20071214153607.GB23670@linux.vnet.ibm.com>
	<20071214153823.GC23670@linux.vnet.ibm.com>
	<b647ffbd0712140825h4f541be0xa7a7866e70b3af7a@mail.gmail.com>
	<b647ffbd0712141151k697d9bbemda9a7e90515e4400@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <b647ffbd0712141151k697d9bbemda9a7e90515e4400-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org


On Fri, 14 Dec 2007, Dmitry Adamushko wrote:

>
> argh... it's a consequence of the 'current is not kept within the tree" indeed.
>

Thanks Dmitry for tracking this down. Although I'm still not convinced we
hit the same bug. But I'm going to go ahead and release 2.6.24-rc5-rt1
anyway. When you have a fix, please CC me and I'll add it to -rt2.

Note: I've added a bunch of logdev (see
http://rostedt.homelinux.com/logdev/README) and I kicked off the hackbench
again. I'll let it run overnight, and if it hits the bug, it will give me
a lot more output to let me know what actually happened.

Thanks,

-- Steve
