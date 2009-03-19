From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] [RFC] c/r: Add UTS support
Date: Wed, 18 Mar 2009 18:06:30 -0700
Message-ID: <m1ab7icodl.fsf@fess.ebiederm.org>
References: <1236880612-15316-1-git-send-email-danms@us.ibm.com>
	<20090312162954.4a4b8e00@thinkcentre.lan>
	<87fxhipfrh.fsf@caffeine.danplanet.com>
	<20090312224820.GA12723@hallyn.com>
	<87bps6pcyf.fsf@caffeine.danplanet.com>
	<49C0B069.6060300@cs.columbia.edu> <20090318134932.GC22636@us.ibm.com>
	<878wn353mf.fsf@caffeine.danplanet.com> <49C1175F.9060600@free.fr>
	<49C1506C.1080500@google.com> <m1bprye5io.fsf@fess.ebiederm.org>
	<49C195CF.1080506@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49C195CF.1080506-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> (Mike Waychison's message of "Wed\,
	18 Mar 2009 17\:46\:07 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> writes:

> Eric W. Biederman wrote:
>> Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> writes:
>>
>>> Cedric Le Goater wrote:
>>>> Dan Smith wrote:
>>>>> SH> (Note that in Dan's next version, he did move unshare into
>>>>> SH> userspace)
>>>>>
>>>>> The idealist in me still wants it to be in the kernel.  However, after
>>>>> seeing it done I agree that it's the right thing to do, at least in
>>>>> this case.
>>>> I would say in all cases.
>>>>
>>>> as you can't unshare(CLONE_NEWPID), 
>>> Eric,
>>>
>>> Is there a particular reason the above doesn't work?  I made an attempt to
>>> implement it a while back, but haven't convinced myself that signals and
>>> re-attaching a new struct pid to a running task is correct.
>>
>> Last time I was thinking about this I figured unsharing a pid namespace would
>> simply place it's children in a different pid namespace, not the originating
>> process.
>>
>> Would that semantic be useful?  It would certainly be a lot less effort than
>> changing the pid on a running process correctly.
>
> Hmm, that would be a little odd.  I think getting the unsharing task to become
> pid 1 is a bit easier to understand and it makes it clear which task is the
> reaper for the new namespace.  Otherwise the first child becomes pid 1 but it
> isn't the reaper.

For very lightweight pid namespaces that may be desirable, and that is where
all of this conversation originally started.   I am happy to set the starting
pid to 2 to avoid confusion on that point.

One of the other problems with changing the pid is that user space in general
glibc in particular can not cope with the pid of a process changing.

My memories are foggy at the moment but I do know that on the several occasions
we have looked at unshare of the pid namespace it has failed due to kernel issues.
I also remember I was close to having resolved the issues of unsharing the pid
namespace if we did not change the pid of processing calling unshare.


You did not answer my question.  I don't quite see how you were envisioning
using unsharing the pid namespace as part of restart so I can't tell if my
proposed semantics would work for that case.

Eric
