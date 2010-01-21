From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: 2.6.33-rc4 i686 clone function looping (seems real!)
Date: Thu, 21 Jan 2010 18:35:25 +0100
Message-ID: <1264095325.4283.1198.camel@laptop>
References: <1263852243.4745.363.camel@Mercier.safe.ca>
	<20100119150931.GA7708@us.ibm.com>
	<1263916851.4745.386.camel@Mercier.safe.ca>
	<20100121171338.GA16904@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100121171338.GA16904-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 2010-01-21 at 11:13 -0600, Serge E. Hallyn wrote:
> The culprit is e2912009fb7b715728311b0d8fe327a1432b3f79
>     sched: Ensure set_task_cpu() is never called on blocked tasks
> 
> If you mount both the ns and cpuset cgroups with this patch applied,
> then doing clone with CLONE_NEWPID, CLONE_NEWNET, etc, you get the
> hang.  The hang is actually hard enough that alt-sysrq isn't helpful :)
> Still trying to figure out what is going on - Peter, any ideas offhand?


Does it replicate on x86_64 ?

/me looks at the NEWPID and NEWNET code


Hmm, I have an idea.. does it really need the ns cgroup stuff?

Let me try and come up with a debug patch...
