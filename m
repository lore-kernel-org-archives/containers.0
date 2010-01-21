From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: 2.6.33-rc4 i686 clone function looping (seems real!)
Date: Thu, 21 Jan 2010 14:20:02 -0600
Message-ID: <20100121202002.GA4725@us.ibm.com>
References: <1263852243.4745.363.camel@Mercier.safe.ca>
	<20100119150931.GA7708@us.ibm.com>
	<1263916851.4745.386.camel@Mercier.safe.ca>
	<20100121171338.GA16904@us.ibm.com>
	<1264095325.4283.1198.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1264095325.4283.1198.camel@laptop>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Peter Zijlstra (peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org):
> On Thu, 2010-01-21 at 11:13 -0600, Serge E. Hallyn wrote:
> > The culprit is e2912009fb7b715728311b0d8fe327a1432b3f79
> >     sched: Ensure set_task_cpu() is never called on blocked tasks
> > 
> > If you mount both the ns and cpuset cgroups with this patch applied,
> > then doing clone with CLONE_NEWPID, CLONE_NEWNET, etc, you get the
> > hang.  The hang is actually hard enough that alt-sysrq isn't helpful :)
> > Still trying to figure out what is going on - Peter, any ideas offhand?
> 
> 
> Does it replicate on x86_64 ?

Hmm, doesn't seem to, no.

> /me looks at the NEWPID and NEWNET code
> 
> 
> Hmm, I have an idea.. does it really need the ns cgroup stuff?

To reproduce it?  Well, there might be some other way to
trigger it, but mounting just cpusets and moving a task into
a different cpuset doesn't trigger it...  So really it must
be something to do with kernel/cgroup.c:cgroup_clone()

> Let me try and come up with a debug patch...

thanks,
-serge
