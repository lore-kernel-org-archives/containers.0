From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v14][PATCH 00/54] Kernel based checkpoint/restart
Date: Wed, 29 Apr 2009 18:47:24 -0400
Message-ID: <49F8D8FC.8010400@cs.columbia.edu>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
	<20090429081815.GA1813@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090429081815.GA1813-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi Louis,

Louis Rilling wrote:
> Hi,
> 
> On 28/04/09 19:23 -0400, Oren Laadan wrote:
>> Here is the latest and greatest of checkpoint/restart (c/r) patchset.
>> The logic and image format reworked and simplified, code refactored,
>> support for PPC, s390, sysvipc, shared memory of all sorts, namespaces
>> (uts and ipc).
> 
> I should have asked before, but what are the reasons to checkpoint SYSV IPCs
> in the same file/stream as tasks? Would it be better to checkpoint them
> independently, like the file system state?
> 
> In Kerrighed we chose to checkpoint SYSV IPCs independently, a bit like the file
> system state, because SYSV IPCs objects' lifetime do not depend on tasks
> lifetime, and we can gain more flexibility this way. In particular we envision
> cases in which two applications share a state in a SYSV SHM (something like a
> producer-consumer scheme), but do not need to be checkpointed together. In such
> a case the SYSV SHM itself could even need more high-availability (using
> active replication) than a checkpoint/restart facility.
> 

Thanks for the feedback, this is actually an interesting idea.

Indeed in the past I also considered SYSV IPC to be a "global" resource
that was checkpointed before iterating through the tasks.

However, in the presence of namespaces, the lifetime of an IPC namespace
does depend on on tasks lifetime - when the last task referring to a
given namespace exits - that namespace is destroyed. Of course, the
root namespace is truly global, because init(1) never exits.

What would 'checkpoint them independently' mean in this case ?

In your use-case, can you restart either application without first
restoring the relevant SYSVIPC ?

Can you think of other use-cases for such a division ?  Am I right to
guess that your use case is specific to the distributed (and SSI-)
nature of your system ?  (Active-replication of SYSV_SHM sounds
awfully related to DSM :)


While not focusing on such use cases, I want to keep the design flexible
enough to not exclude them a-priori, and be able to address them later
on. Indeed, the code is split such that the the function to save a given
IPC namespace does not depend on the task that uses it. Future code
could easily use the same functionality.

One way to be flexible to support your use case, is by having some
mechanism in place to select whether a resource (virtually any) is
to be chekcpointed/restored.

For example, you could imagine checkpoint(..., CHECKPOINT_SYSVIPC)
to checkpoint (also) IPC, and not checkpoint IPC in its absence.

So normally you'd have checkpoint(..., CHECKPOINT_ALL). When you don't
want IPC, you'd use CHECKPOINT_ALL & ~CHECKPOINT_SYSVIPC. When you
want only IPC, you'd use CHECKPOINT_SYSVIPC only.

Same thing for restart, only that it will get trickier in the "only IPC"
case, since you will need to tell which IPC namespace is affected.

Also, I envision a task saying cradvise(CHECKPOINT_SYSVIPC, false),
telling the kernel to not c/r its IPC namespace. (Or any other
resource). Again there would need to be a way to add a restored
namespace.

Does this address your concerns ?

Oren.
