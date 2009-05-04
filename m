From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v14][PATCH 00/54] Kernel based checkpoint/restart
Date: Mon, 04 May 2009 16:13:59 -0400
Message-ID: <49FF4C87.2090406@cs.columbia.edu>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
	<20090429081815.GA1813@hawkmoon.kerlabs.com>
	<49F8D8FC.8010400@cs.columbia.edu> <49FEB01B.208@cs.columbia.edu>
	<20090504130108.GA21521@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090504130108.GA21521-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, =?ISO-8859-1?Q?Matthieu_Fertr=E9?= <matthieu.fertre-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>>> I see one drawback with this approach if you allow checkpoint of
>>> application that is not isolated in a container. In that case, you may
>>> want to select which IPC objects to dump to not dump all the IPC objects
>>> living in the system. Indeed, this is why we have chosen in Kerrighed to
>>> checkpoint IPC objects independently of tasks, since we have no
>>> container/namespaces support currently.
>> I assume that in this case it will be the application itself that
>> will somehow tell the system which specific sysvipc objects (ids) it
>> cares about.
>>
>> (I'm not sure how would the system otherwise know what to dump and
>> what to leave out).
>>
>> I originally proposed the construct of cradvise() syscall to handle
>> exactly those cases where the application would like to advise the
>> kernel about certain resources. So, extending the previous example,
>> a task may call something like:
>>
>>    cradvise(CHECKPOINT_SYSVIPC_SHM, false);  /* generally skip shm */
>>    cradvise(CHECKPOINT_SYSVIPC_SHMID, id, true);  /* but include this */
>>
>> or:
>>    cradvise(CHECKPOINT_SYSVIPC_SHM, true);  /* generally include shm */
>>    cradvise(CHECKPOINT_SYSVIPC_SHMID, id, false);  /* but skip this */
>>
>> Anyway, these are just examples of the concept and what sort of generic
>> interface can be used to implement it; don't pick on the details...
>>
>> Oren.
> 
> Oren, I have to be honest:  I could of course be wrong, but imo there
> is 0 chance of such a bigger-and-uglier-than-ioctl syscall as cradvise
> being accepted upstream.  There may be good uses for it, but I think
> it's worthwhile thinking of ways around it whenever possible.

Clearly there is a tradeoff is between the flexibility and granularity
of control that one can have over how checkpoint/restart is done, vs.
complexity of the interface.

Unlike ioctl() which is a dump-place for any _type_ of device, what I'd
expect from cradvise()-like mechanism is to allow control on any _class_
of resource in the kernel. One can easily enumerate the existing ones
now in the kernel: mostly open file descriptors, namespaces, sysvipc,
memory descriptors, memory contents, etc. I don't expect cradvise() to
be specific to a specific device - that'll be userspace responsibility.

IOW, while we need to think carefully about what the interface would be,
I don't expect it to be bigger and uglier than ioctl(), because it's
focused scope, besides the fact the ioctl() is hard to compete with to
begin with...

> 
> In this particular case, wouldn't it be better to do something like:
> 
> 	1. freeze + checkpoint full application + container (== C1)
> 	2. continue application, which does a clone(CLONE_COPYIPC) (*1)
> 	3. application removes all shms except the one to be
> 	checkpointed
> 	4. freeze + checkpoint application again ( == C2)
> 	5. restart applicaiton from C1
> 
> This requires an ability to clone an ipc namespace while copying its
> contents, but that seems more viable upstream, and more generally
> useful, than yet another use for cradvise().

Sure, and indeed possibly useful outside c/r domain.

Note that for performance (speed, memory) reasons it will require
that the clone be done in COW style - not trivial for SHM.

Oren.
