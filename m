From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][PATCH 2/2] CR: handle a single task with private memory maps
Date: Mon, 04 Aug 2008 22:37:20 -0400
Message-ID: <4897BCE0.1080508@cs.columbia.edu>
References: <20080731135703.GC22403@hawkmoon.kerlabs.com>
	<4891D5C2.8090000@cs.columbia.edu>
	<20080731155856.GH22403@hawkmoon.kerlabs.com>
	<4891E849.1050701@cs.columbia.edu>
	<20080731175058.GI22403@hawkmoon.kerlabs.com>
	<48920EA0.1060608@cs.columbia.edu>
	<20080801102600.GJ22403@hawkmoon.kerlabs.com>
	<48931A7E.1040302@cs.columbia.edu>
	<20080801180038.GL22403@hawkmoon.kerlabs.com>
	<48935B4D.7070302@cs.columbia.edu>
	<20080804101608.GA4081@localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080804101608.GA4081@localdomain>
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
> On Fri, Aug 01, 2008 at 02:51:57PM -0400, Oren Laadan wrote:
>> Louis Rilling wrote:
>>> On Fri, Aug 01, 2008 at 10:15:26AM -0400, Oren Laadan wrote:
>>>> Louis Rilling wrote:
>>>>> On Thu, Jul 31, 2008 at 03:12:32PM -0400, Oren Laadan wrote:
> 
> Cut the less interesting (IMHO at least) history to make Dave happier ;)
> 
>>> Returning 0 in case of a restart is what I called a special handling. You won't
>>> do this for the other tasks, so this is special. Since userspace must cope with
>>> it anyway, userspace can be clever enough to avoid using the fd on restart, or
>>> stupid enough to destroy its checkpoint after restart.
>> It's a different "special hanlding" :)   In the case of a single task that wants
>> to checkpoint itself - there are no other tasks.  In the case of a container -
>> there will be only a single task that calls sys_checkpoint(), so only that task
>> will either get the CRID or the 0 (or an error). The other tasks will resume
>> whatever it was that they were doing (lol, assuming of course restart works).
>>
>> So this "special handling" ends up being a two-liner: setting the return
>> value of the syscall for the task that called sys_checkpoint() (well, actually
>> it will call sys_restart() to restart, and return from sys_checkpoint() with
>> a value of 0 ...).
> 
> I knew it, since I actually saw it in the patches you sent last week.
> 
>> If you use an FD, you will have to checkpoint that resource as part of the
>> checkpoint, and restore it as part of the restart. In doing so you'll need
>> to specially handle it, because it has a special meaning. I agree, of course,
>> that it is feasible.
>>
> 
>>>>> - Userspace makes less errors when managing incremental checkpoints.
>>>> have you implemented this ?  did you experience issues in real life ?  user
>>>> space will need a way to manage all of it anyway in many aspects. This will
>>>> be the last/least of the issues ...
>>> No it was not implemented, and I'm not going to enter a discussion about the
>>> weight of arguments whether they are backed by implementations or not. It just
>>> becomes easier to create a mess with things depending on each other created as
>>> separate, "freely" (userspace-decided)-named objects.
>> If I were to write a user-space tool to handle this, I would keep each chain
>> of checkpoints (from "base" and on) in a separate subdir, for example. In fact,
>> that's how I did it :)
> 
> This is intuitive indeed. Checkpoints are already organized in a similar way in
> Kerrighed, except that a notion of application (transparent to applications)
> replaces the notion of container, and the kernel decides where to put the
> checkpoints and how they are named (I'm not saying that this is the best
> way though).
> 
>>>> Besides, this scheme begins to sound much more complex than a single file.
>>>> Do you really gain so much from not having multiple files, one per checkpoint ?
>>> Well, at least you are not limited by the number of open file descriptors
>>> (assuming that, as you mentioned earlier, you pass an array of previous images
>>> to compute the next incremental checkpoint).
>> You aren't limited by the number of open file. User space could provide an array
>> of <CRID, pathname> (or <serial#, pathname>) to the kernel, the kernel will
>> access the files as necessary.
> 
> But the kernel itself would have to cope with this limit (even if it is
> not enforced, just to avoid consuming too much resources), or close and
> reopen files when needed...

You got - close and reopen as needed with LRU policy to decide which open file
to close. My experience so far is that you rarely need more than 100 open files.

> 
>> Uhh .. hold on:  you need the array of previous checkpoint to _restart_ from
>> an incremental checkpoint. You don't care about it when you checkpoint: instead,
>> you keep track in memory of (1) what changed (e.g. which pages where touched),
>> and (2) where to find unmodified pages in previous checkpoints. You save this
>> information with each new checkpoint.  The data structure to describe #2 is
>> dynamic and changes with the execution, and easily keeps track of when older
>> checkpoint images become irrelevant (because all the pages they hold have been
>> overwritten already).
> 
> I see. I thought that you also intended to build incremental checkpoints
> from previous checkpoints only, because even if this is not fast, this
> saves storage space. I agree that if you always keep necessary metadata
> in kernel memory, you don't need the previous images. Actually I don't
> know any incremental checkpoint scheme not using such in-memory metadata
> scheme. Which does not imply that other schemes are not relevant
> though...
> 
>>
>>>>> where:
>>>>> - base_fd is a regular file containing the base checkpoint, or -1 if a full
>>>>>   checkpoint should be done. The checkpoint could actually also live in memory,
>>>>>   and the kernel should check that it matches the image pointed to by base_fd.
>>>>> - out_fd is whatever file/socket/etc. on which we should dump the checkpoint. In
>>>>>   particular, out_fd can equal base_fd and should point to the beginning of the
>>>>>   file if it's a regular file.
>>>> Excellent example. What if the checkpoint data is streamed over the network;
>>>> so you cannot rewrite the file after it has been streamed...  Or you will have
>>>> to save the entire incremental history in memory :(
>>> I'm not sure to have expressed myself well: as was explained later, streaming
>>> output is ok for an incremental checkpoint, since you need the base checkpoint
>>> anyway. Unless you have a solution to build an incremental checkpoint out of
>>> streamed earlier checkpoints, I don't see what kind of limitation this would
>>> introduce.
>> I suspect we need to clarify the terminology: by "streamed" I mean that
>> the format does not require seeks (going back and forth), so that it can be
>> sent over a socket and make sense. While this is useful for migration, it
>> does not imply a migration. Consider, for instance, if you want to store the
>> checkpoint elsewhere you transfer the data via a socket to a daemon.
> 
> My definition of "streaming" was exactly "non-seekable", not only for
> migration.
> 
>> I actually wasn't thinking of streaming a series of incremental checkpoints
>> (from base and on) to implement migration... I simply didn't have a use-case
>> for that :)
> 
> This could be useful however. Since incremental checkpoint is faster
> this could reduce down-time.

Naturally incremental checkpoint reduces downtime; however since each checkpoint
is taken at a different time, they can be streamed -- transferred over the
network -- as they are taken. This gives more flexibility and can still, if
you wish, can easily be transformed to a single long stream.

Actually, this is a good argument in favor of using multiple files: they are a
more flexible approach and can always be easily transformed to a single long
stream, while the reverse isn't so.

> 
>>>>> This assumes that a checkpoint image has a place in the header to tell where the
>>>>> last checkpoint image is. Eventually, each record (task struct, vma, page, etc.)
>>>>> should contain a field telling which later incremental checkpoint invalidates
>>>>> it, so that we can restart from any intermediate checkpoint if we like.
>>>> My experience is that you really need incremental for memory, but not that
>>>> necessary for the rest of the state. So the way I did it is - whenever a
>>>> vma is saved, if some of its pages are found in previous checkpoints, a
>>>> pointer to where the page data resides is given (CRID, position) instead of
>>>> the page contents.
>>> So in the case I described, say we restart from checkpoint #7, the page would be
>>> found at the first page record of same (mm,address) that is not invalidated by a
>>> checkpoint having id <= 7.
>> Ehhh... I'm confused with this. Invalidated by checkpoint having id <= 7 ?  only
>> a later checkpoint can invalidate a page and provide a newer version of that
>> page.
> 
> Sorry, I was not clear enough. I was talking about restarting from an
> incremental checkpoint in the case were all the sequence of checkpoints
> is stored in as single file. So I meant "not invalidated by a checkpoint
> having an id <= 7, eg. 5". That is, when you restart from (possibly
> intermediate) incremental checkpoint 7 and walk the file containing the sequence
> of checkpoints, some records are invalidated by incremental checkpoints
> having ids > 7 (eg checkpoint 9) and thus are part of checkpoint 7, some records
> are not invalidated by any checkpoint yet and thus are also part of checkpoint
> 7, and the other records were invalidated by checkpoints havind ids <= 7
> (for instance 5, 3, etc.) and thus are not part of checkpoint 7.
> 
>> So to restart from checkpoint #7, you first restart from checkpoint #7 *as is*.
>> At this point you'll have everything setup, except that some memory contents
>> (hopefully much, because that means you saved a lot by doing incremental) will
>> be incorrect, because they weren't actually saved with checkpoint #7.  But
>> checkpoint #7 will also have a section that describes this remaining memory and
>> where it can be found, e.g many entries like this:
>>
>> 	<mm_struct id, page addr, checkpoint image id, position in file>
>>
>> Now the code will scan this array, and fetch the required pages from where
>> they are stored.
>>
>> (As mentioned before, the data structure that describes this array will be
>> dynamically updated as applications modify their memory).
>>
>> This, of course, assumes that an incremental restart is _not_ stream-able,
>> and that all the files (or the entire single file) is available and seek-able.
>> (Still, being able to stream the (regular) checkpoint/restart operation is one
>> of our goals).
> 
> Ok. The single file approach, with records tagged with the first
> checkpoint id not using them anymore (as mentioned again above), makes
> incremental restarts streamable (pages that are part of the checkpoint
> can be stored in a array until they are mapped), although this makes an
> incremental restart read the whole checkpoint sequence.
> 
> In the multiple files approach, we could first restore all but missing
> memory pages from the incremental checkpoint file, at the same time
> record in a temporary array which pages are missing and where to find
> them, sorting the entries by checkpoint file and location in the file,
> and in a second pass read sequentially the needed checkpoint files and
> fetch the needed pages. Since the array is sorted by location in the
> files, this second pass would not need costly lookups in the array to
> figure out whether a pages is needed or not.
> 
>>> Again, how do you build an incremental checkpoint out of streamed-only previous
>>> checkpoints?
>> I hope the clarification above explains that what I meant by "data being
>> steamed" is that the file is not seek-able.

streamed, that is :)

> 
> I hope that the clarification above explains what I expected from
> incremental checkpoints :)
> 
>>>> Live migration is orthogonal to incremental checkpoint, they have nothing
>>>> in common. There are use cases for restarting from an intermediate checkpoint
>>>> like the paper I mentioned, as well as fault tolerance, debugging, forensics,
>>>> and more.
>>> I'm definitely sure that intermediate checkpoints are interesting. I was only
>>> wondering if streaming was so interesting for them.
>> Not in the sense of streaming for migration :)
> 
> But possibly in the sense of streaming from a remote store? Maybe
> performance is not so critical in those cases?
> 
>>> The point is that you need previous data when building an incremental
>>> checkpoint, so you will read it at least. And since it was previously stored (in
>> The scheme that I described above and is implemented in Zap does not require
>> access to previous checkpoints when building a new incremental checkpoint.
>> Instead, you keep some data structure in the kernel that describes the pieces
>> that you need to carry with you (what pages were saved, and where; when a task
>> exits, the data describing its mm will be discarded, of course, and so on).
> 
> This is because you probably decided that a mechanism in the kernel that saves
> storage space was not interesting if it does not improve speed. As a
> consequence you need to keep metadata in kernel memory in order to do
> incremental checkpoint. Maybe saving storage space without considering
> speed could equally be done from userspace with sort of checkpoint diff
> tools that would create an incremental checkpoint 2' from two full
> checkpoints 1 and 2.

Good point. In fact, the meta data is not only kept in memory, but also saved
with each incremental checkpoint (well, its version at checkpoint time), so
that restart would know where to find older data. So it is already transfered
to user space; we may as well provide the option to keep it only in user space.

Oren.

> 
> Thanks,
> 
> Louis
> 
