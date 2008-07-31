From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][PATCH 2/2] CR: handle a single task with private memory maps
Date: Thu, 31 Jul 2008 15:12:32 -0400
Message-ID: <48920EA0.1060608@cs.columbia.edu>
References: <Pine.LNX.4.64.0807292325290.9868@takamine.ncl.cs.columbia.edu>
	<20080730220752.GA3518@us.ibm.com>
	<4890E930.9090204@cs.columbia.edu>
	<20080731135703.GC22403@hawkmoon.kerlabs.com>
	<4891D5C2.8090000@cs.columbia.edu>
	<20080731155856.GH22403@hawkmoon.kerlabs.com>
	<4891E849.1050701@cs.columbia.edu>
	<20080731175058.GI22403@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080731175058.GI22403-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org



Louis Rilling wrote:
> On Thu, Jul 31, 2008 at 12:28:57PM -0400, Oren Laadan wrote:
>>
>> Louis Rilling wrote:
>>> On Thu, Jul 31, 2008 at 11:09:54AM -0400, Oren Laadan wrote:
>>>> Louis Rilling wrote:
>>>>> On Wed, Jul 30, 2008 at 06:20:32PM -0400, Oren Laadan wrote:
>>>>>> Serge E. Hallyn wrote:
>>>>>>> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>>>>>>>> +int do_checkpoint(struct cr_ctx *ctx)
>>>>>>>> +{
>>>>>>>> +	int ret;
>>>>>>>> +
>>>>>>>> +	/* FIX: need to test whether container is checkpointable */
>>>>>>>> +
>>>>>>>> +	ret = cr_write_hdr(ctx);
>>>>>>>> +	if (!ret)
>>>>>>>> +		ret = cr_write_task(ctx, current);
>>>>>>>> +	if (!ret)
>>>>>>>> +		ret = cr_write_tail(ctx);
>>>>>>>> +
>>>>>>>> +	/* on success, return (unique) checkpoint identifier */
>>>>>>>> +	if (!ret)
>>>>>>>> +		ret = ctx->crid;
>>>>>>> Does this crid have a purpose?
>>>>>> yes, at least three; both are for the future, but important to set the
>>>>>> meaning of the return value of the syscall already now. The "crid" is
>>>>>> the CR-identifier that identifies the checkpoint. Every checkpoint is
>>>>>> assigned a unique number (using an atomic counter).
>>>>>>
>>>>>> 1) if a checkpoint is taken and kept in memory (instead of to a file) then
>>>>>> this will be the identifier with which the restart (or cleanup) would refer
>>>>>> to the (in memory) checkpoint image
>>>>>>
>>>>>> 2) to reduce downtime of the checkpoint, data will be aggregated on the
>>>>>> checkpoint context, as well as referenced to (cow-ed) pages. This data can
>>>>>> persist between calls to sys_checkpoint(), and the 'crid', again, will be
>>>>>> used to identify the (in-memory-to-be-dumped-to-storage) context.
>>>>>>
>>>>>> 3) for incremental checkpoint (where a successive checkpoint will only
>>>>>> save what has changed since the previous checkpoint) there will be a need
>>>>>> to identify the previous checkpoints (to be able to know where to take
>>>>>> data from during restart). Again, a 'crid' is handy.
>>>>>>
>>>>>> [in fact, for the 3rd use, it will make sense to write that number as
>>>>>> part of the checkpoint image header]
>>>>>>
>>>>>> Note that by doing so, a process that checkpoints itself (in its own
>>>>>> context), can use code that is similar to the logic of fork():
>>>>>>
>>>>>> 	...
>>>>>> 	crid = checkpoint(...);
>>>>>> 	switch (crid) {
>>>>>> 	case -1:
>>>>>> 		perror("checkpoint failed");
>>>>>> 		break;
>>>>>> 	default:
>>>>>> 		fprintf(stderr, "checkpoint succeeded, CRID=%d\n", ret);
>>>>>> 		/* proceed with execution after checkpoint */
>>>>>> 		...
>>>>>> 		break;
>>>>>> 	case 0:
>>>>>> 		fprintf(stderr, "returned after restart\n");
>>>>>> 		/* proceed with action required following a restart */
>>>>>> 		...
>>>>>> 		break;
>>>>>> 	}
>>>>>> 	...
>>>>> If I understand correctly, this crid can live for quite a long time. So many of
>>>>> them could be generated while some container would accumulate incremental
>>>>> checkpoints on, say crid 5, and possibly crid 5 could be reused for another
>>>>> unrelated checkpoint during that time. This brings the issue of allocating crids
>>>>> reliably (using something like a pidmap for instance). Moreover, if such ids are
>>>>> exposed to userspace, we need to remember which ones are allocated accross
>>>>> reboots and migrations.
>>>>>
>>>>> I'm afraid that this becomes too complex...
>>>> And I'm afraid I didn't explain myself well. So let me rephrase:
>>>>
>>>> CRIDs are always _local_ to a specific node. The local CRID counter is
>>>> bumped (atomically) with each checkpoint attempt. The main use case is
>>>> for when the checkpoint is kept is memory either shortly (until it is
>>>> written back to disk) or for a longer time (use-cases that want to keep
>>>> it there). It only remains valid as long as the checkpoint image is
>>>> still in memory and have not been committed to storage/network. Think
>>>> of it as a way to identify the operation instance.
>>>>
>>>> So they can live quite a long time, but only as long as the original
>>>> node is still alive and the checkpoint is still kept in memory. They
>>>> are meaningless across reboots and migrations. I don't think a wrap
>>>> around is a concern, but we can use 64 bit if that is the case.
>>>>
>>>> Finally, the incremental checkpoint use-case: imagine a container that
>>>> is checkpointed regularly every minutes. The first checkpoint will be
>>>> a full checkpoint, say CRID=1. The second will be incremental with
>>>> respect to the first, with CRID=2, and so on the third and the forth.
>>>> Userspace could use these CRID to name the image files (for example,
>>>> app.img.CRID). Assume that we decide (big "if") that the convention is
>>>> that the last part of the filename must be the CRID, and if we decide
>>>> (another big "if") to save the CRID as part of the checkpoint image --
>>>> the part that describe the "incremental nature" of a new checkpoint.
>>>> (That part would specify where to get state that wasn't really saved
>>>> in the new checkpoint but instead can be retrieved from older ones).
>>>> If that was the case, then the logic in the kernel would be fairly
>>>> to find (and access) the actual files that hold the data. Note, that
>>>> in this case - the CRID are guaranteed to be unique per series of
>>>> incremental checkpoints, and incremental chekcpoint is meaningless
>>>> across reboots (and we can require that across migration too).
>>> Letting the kernel guess where to find the missing data of an incremental
>>> checkpoint seems a bit hazardous indeed. What about just appending incremental
>>> checkpoints to the last full checkpoint file?
>> It isn't quite a "guess", it's like the kernel assumes that a kernel-helper
>> resides in some directory - it's a convention. I agree, though, that it may
>> not be the best method to do it.
>>
>> As for putting everything in a single file, I prefer not to do that, and it
>> may not even always possible I believe.
>>
>> An incremental would include a section that describes how to find the missing
>> data from previous checkpoints, so it must have a way to identify a previous
>> checkpoint.
>>
>> On way is like I suggested name them with this identifier, another would be,
>> for example, that the user provides a list of file-descriptors that match
>> the required identifiers. Other ways may be possible too.
>>
>> In any event, I think it is now  bit early to discuss the exact format and
>> logic, when we don't even have a simple checkpoint working :)
>>
>> Incremental checkpoint is one of a few reasons to use CRIDs, let us first
>> agree about CRIDs, and later, when we design incremental checkpoints, decide
>> on the technical details of incorporating this CRIDs.
>>
> 
> Agreed, but since your point is to introduce CRIDs, I'd like to be convinced
> that they are needed :) At least I'd like to be convinced that they will not
> generate hard-to-manage side effects.
> 
>> (Just to avoid confusion, an incremental checkpoint is _not_ a pre-copy or
>> live-migration: in a pre-copy, we repeatedly copy the state of the container
>> without freezing it until the delta is small enough, then we freeze and then
>> we checkpoint the remaining residues. All this activity belongs to a single
>> checkpoint. In incremental checkpoints, we talk about multiple checkpoints
>> that save only the delta with respect to their preceding checkpoint).
> 
> Don't worry, I know what incremental checkpointing is.
> 
>>>> We probably don't want to use something like a pid to identify the
>>>> checkpoint (while in memory), because we may have multiple checkpoints
>>>> in memory at a time (of the same container).
>>> Agreed.
>>>
>>>>> It would be way easier if the only (kernel-level) references to a checkpoint
>>>>> were pointers to its context. Ideally, the only reference would live in a
>>>>> 'struct container' and would be easily updated at restart-time.
>>>> Consider the following scenario of calls from user-space (which is
>>>> how I envision the checkpoint optimized for minimal downtime, in the
>>>> future):
>>>>
>>>> 1)	while (syscall_to_do_precopy)		<- do precopy until ready to
>>>> 		if (too_long_already)		<- checkpoint or too long
>>>> 			break;
>>>>
>>>> 2)	freeze_container();
>>>>
>>>> 3)	crid = checkpoint(.., .., CR_CKPT_LAZY);	<- checkpoint container
>>>> 							<- don't commit to disk
>>>> 							<- (minimize owntime)
>>>>
>>>> 4)	unfreeze_container();			<- now can unfreeze container
>>>> 						<- already as soon as possible
>>>>
>>>> 5)	ckpt_writeback(crid, fd);		<- container is back running. we
>>>> 						<- can commit data to storage or
>>>> 						<- network in the background.
>>>>
>>>> #2 and #4 are done with freezer_cgroup()
>>>>
>>>> #1, #3 and #5 must be syscalls
>>>>
>>>> More specifically, syscall #5 must be able to refer to the result of syscall #3
>>>> (that is the CRID !). It is possible that another syscall #3 occur, on the same
>>>> container, between steps 4 and 5 ... but then that checkpoint will be assigned
>>>> another, unique CRID.
>>> Hm, assuming that, as proposed above, incremental checkpoints are stored in the
>>> same file as the ancestor full checkpoint, why not simply give fd as argument in
>>> #5? I'd expect that the kernel would associate the file descriptor to the
>>> checkpoint until it is finalized (written back, sent over the wire, etc.).
>> The above procedure, step 1-5 are for a _single_ checkpoint.
> 
> This is what I understood.
> 
>> Why would the kernel associate a file descriptor with the checkpoint until it
>> is finalized ?   As far as I'm concerned, the checkpoint call in step 3 can go
>> without any FD.  Also, what happens if there is another checkpoint, of the
>> same container, taken between steps 4 and 5, how would you tell the difference
>> or select which one goes in first ?   Finally, keeping that FD alive between
>> multiple checkpoints would require the checkpointer (e.g. a daemon that will
>> periodically checkpoint) to keep it alive.
>>
>> I view it differently: a checkpoint held in memory is like a kernel resource,
>> and requires a handle/identifier for user space to refer to it. Like an IPC
>> object. Why tie that object to a specific file descriptor ?
>> The only exception I can see, is the need to tie it to a some process - the
>> checkpointer for instance, such that if that process dies without completing
>> the work, the checkpoint image in memory will be cleaned up.
>> That, however, still is problematic, because it will not allow you to use
>> different procesess for different steps (above).
>>
>> Since we are not yet optimizing the checkpoint procedure, just building the
>> infrastructure, my goal is to convince that a CRID is a desired feature (and
>> I can certainly see how it will be used in various scenarios).
> 
> Here is probably the source of the misunderstanding. I was assuming that step #3
> needed a file descriptor to dump the checkpoint progressively, but reading your
> first use-case more carefully might have avoided this misunderstanding :)

Even without the first use-case (checkpoint in memory), step 3 does not need
necessarily a file-descriptor to which data will be dumped, in the case of
said optimization. Consider a scenario with periodic checkpointing of a long
running application, where we would like to minimize the downtime of the
application due to each checkpoint. The idea is to do steps 1 and 3 entirely
in memory, keep the data in a buffer (see below comment about tmpfs). The
expensive operation of streaming the data to the file-descriptor is only
done in step 5.

(In the case of checkpoint in memory - it is never written to a file. There
are various optimization to do there for fast restart for which putting the
data in a file doesn't make sense).

As for using tmpfs -- so during step 3 the state of all tasks is saved; part
of it is headers, task data, signals etc, but mostly the memory content. For
as long as the checkpoint is kept in memory (either because it is meant to
stay there, or because it is not committed to the file-descriptor yet), there
is no reason to make a copy of each (dirty) page. On the contrary - the pages
will be marked COW and a reference will be kept, as part of the checkpoint
context. Sure, you can put the rest of the data in a file in tmpfs; but you
probably don't want to copy all the pages to a file in tmpfs - that would be
wasteful.

> Anyway, we can still give a fd to sys_checkpoint() which will identify the
> checkpoint for the remaining operations. It's up to userspace to show the
> difference between two checkpoints taken (roughly) at the same time. From the
> kernel point of view, a file descriptor is enough to make the difference.

That is indeed an option. I haven't given a lot of thought to this approach,
because in Zap I use CRIDs. Three points against this approach are that:

(1) as I said, that would require that the file descriptor remains alive for
as long as we want to keep the checkpoint alive (in memory), and

(2) if the checkpoint is taken by a process from within the container, we
create a situation where a resource held by the process (an FD), is referring
to the checkpoint itself and at the same time also referred to by the
checkpoint (because it is part of the state of a process that is in the
container...). In particular this will necessitate some special case treatment
during the restart operation.

(3) if a give tasks wants to keep many checkpoints in memory (again, either
permanently or shortly), it will have to keep, forever, a lot of open file
descriptors.

On the other hand, using an FD provide the advantage of a simple cleanup (FD
closed -> checkpoint data discarded) and ridding us from the need to come up
with a cleanup strategy.

> 
> Let's consider the three use cases of CRID you mentioned earlier:
> 
> 1) Checkpointing in memory:
> Actually, checkpointing in memory could also be done from userspace using tmpfs.
> Again, I agree that this kind of optimization should be discussed later. I'm
> just not convinced that this needs a CRID...

See my comment about regarding tmpfs. You are right, however, in that we could
use FD to tmpfs where the rest of the data (not pages) will be stored.

> 
> 2) Reducing downtime of the checkpoint:
> If reducing downtime is just a matter of avoiding disk accesses, tmpfs is again
> a kind of solution. It even allows to swap if the checkpoint size is too big.
> What kind of scenario (other than incremental checkpointing) do you envision
> where multiple calls to sys_checkpoint() would use the same checkpoint object?

Again, see the comment regarding tmpfs. The actual memory copy operation between
the real pages and the space allocated in tmpfs can take substantial time for
applications with large memory (compared to merely marking the pages COW, and
amortizing the cost during regular execution of the application), besides the
extra space overhead. Also, writing tmpfs incurs visible overhead when you care
about milliseconds of downtime; I've seen that with Zap.

> 3) Incremental checkpoint:
> I agree that maintaing a fd alive (in a checkpointer daemon for instance) may
> look restrictive, but I'm not sure that it is really needed to keep it alive
> between consecutive incremental checkpoints. I'd really like to see incremental
> checkpointing as an append operation to a checkpoint file. This way the file

Why ?  What's the advantage of having all data in a single file as opposed to
multiple files ?

Recall that the data can be streamed, so when you start to read a file you
don't know a-priori how long is the checkpoint image, until you have parsed
it all; So you can't easily find the beginning of the, say 15th checkpoint
int that case.

Depending on the size of your checkpoint, a single file may eventually become
very large in a short time. I have one system that takes a checkpoint every
second of en entire user-desktop ...

One single large file is harder to manager, parse, and inspect, even with
proper user tools. If you wanted to change something inside (for whatever
reasons), that would be a difficult to do. Same goes for when you want to
coalesce multiple checkpoints into a single checkpoint (e.g. to save space,
or because you don't care about some of your past)

Ahh.. ok.. I stop here. This is not related to CRID vs. FD anymore :)

> could contain the entire checkpoint history. On the other hand, you are not sure
> that we could do incremental checkpoint this way, which justifies your need for
> a CRID. Perhaps you have an example?

Arguments given above. Note that even with multiple files we don't _need_
CRID, they are merely helpful. Instead, the user could be required to provide
the kernel with an array of file names, corresponding to checkpoint#0 (base),
checkpoint#2, checkpoint#3 etc; In this case, the "incremental state" that
is saved with checkpoint#4, is (a) that it is #4, and (b) for each part of
state that is found in a previous checkpoint, a reference to the serial no.
of that checkpoint is kept.

(The proposal for CRID was that instead of a serial number that starts from
0 with every full (base) checkpoint, we use the CRID).

> 
> Anyway, do not take this as an attack. I just want to be well convinced that

On the contrary; your comments are definitely in place.

> CRIDs are really needed, and are worth the effort of managing them cleanly.
> Exposing them to userspace just scares me a bit.

I'm not sure why is there an "effort of managing" them ?  It's a simple
atomic counter, that won't wrap around (use 64 bit if we wish). All in-memory
checkpoint contexts will be (also) in global linked list and easily located
there by their CRID.

> 
> Btw, if we ever decide to use CRIDs, I'd propose to manage them in some
> pseudo-filesystem, like SYSV IPC objects actually are.

Eventually, yes ;)

> Thanks,
> 
> Louis
> 

Thanks for the comments and stimulating the discussion.

Oren.
