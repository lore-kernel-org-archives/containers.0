From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 18/38] C/R: core stuff
Date: Wed, 27 May 2009 18:45:04 -0400
Message-ID: <4A1DC270.8080807__44210.5318805718$1243464420$gmane$org@cs.columbia.edu>
References: <1242968132-1044-1-git-send-email-adobriyan@gmail.com>
	<1242968132-1044-18-git-send-email-adobriyan@gmail.com>
	<20090526131644.GA20920@hallyn.com>
	<20090526193503.GB11909@x200.localdomain>
	<4A1DA8FB.3000306@cs.columbia.edu>
	<20090527221753.GB8321@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090527221753.GB8321-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org



Alexey Dobriyan wrote:
> On Wed, May 27, 2009 at 04:56:27PM -0400, Oren Laadan wrote:
>> Alexey Dobriyan wrote:
>>> On Tue, May 26, 2009 at 08:16:44AM -0500, Serge E. Hallyn wrote:
>>>> Quoting Alexey Dobriyan (adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
>>>>> Introduction
>>>>> ------------
>>>>> Checkpoint/restart (C/R from now) allows to dump group of processes to disk
>>>>> for various reasons like saving process state in case of box failure or
>>>>> restoration of group of processes on another or same machine later.
>>>>>
>>>>> Unlike, let's say, hypervisor C/R style which only needs to freeze guest kernel
>>>>> and dump more or less raw pages, proposed C/R doesn't require hypervisor.
>>>>> For that C/R code needs to know about all little and big intimate kernel details.
>>>>>
>>>>> The good thing is that not all details needs to be serialized and saved
>>>>> like, say, readahead state. The bad things is still quite a few things
>>>>> need to be.
>>>> Hi Alexey,
>>>>
>>>> the last time you posted this, I went through and tried to discern the
>>>> meaningful differences between yours and Oren's patchsets.  Then I sent some
>>>> patches to Oren to make his set configurable to act more like yours.  And Oren
>>>> took them!  But now you resend this patchset with no real changelog, no
>>>> acknowledgment that Oren's set even exists
>>> Is this a requirement? Everybody following topic already knows about
>>> Oren's patchset.
>> Some people do ack other people's work. See for example patches #1
>> and #24 in my recent post. You're welcome.
>>
>>>> - or is much farther along and pretty widely reviewed and tested (which is
>>>> only because he started earlier and, when we asked for your counterpatches
>>>> at an earlier stage, you would never reply) - or, most importantly, what
>>>> it is that you think your patchset does that his does not and cannot.
>>> There are differences. And they're not small like you're trying to describe
>>> but pretty big compared the scale of the problem.
>> I've asked before, and I repeat now: can you enumerate these "big"
>> scary differences that make it such a "big" problem ?
>>
>> So far, we identified two main "design" issues -
> 
> Why in "? Yes, they are high-level design issues.
> 

In quotes, because I argued further on that, although my patchset
takes a stand on both issues, it can be easily reverted _within_
that patchset. Moreover, I argue that they can co-exist.

>> 1) Whether or not allow c/r of sub-container (partial hierarchy)
>>
>> 2) Creation of restarting process hierarchy in kernel or in userspace
>>
>> As for #1, you are the _only_ one who advocates restricting c/r to
>> a full container only. I guess you have your reasons, but I'm unsure
>> what they may be.
> 
> The reason is that checkpointing half-frozen, half-live container is
> essentially equivalent to live container which adds much complexity
> to code fundamentally preventing kernel from taking coherent snapshot.
> 
> In such situations kernel will do its job badly.

In such situation the kernel will do a bad job if the user is asking
for a bad job. Just like checkpointing without snapshotting the
file system and expecting it to always work.

But if the user is a bit more careful (and even then, not that much),
she can enjoy the wonderful benefits of c/r without the wonderful
benefits of containers.

If useful, it's easy to pass a flag to checkpoint() that will ask
to enforce, say, shared memory "leaks" but not nsproxy or file "leaks".

In fact, even shared memory "leaks" may be useful for some users (e.g.
what the guys from kerlabs pointed out).

> 
> Manpage will be filled with strings like "if $FOO is shared then $BAR is
> not guaranteed".
> 
> What to do if user simply doesn't know if container is bounded?
> Checkpoint and to hell with consequences?
> 
> If two tasks share mm_struct you can't even detect that pages you dump
> aren't filled with garbage meanwhile from second task.
> 
> If two tasks share mm_struct, other task can issue AIO indefinitely
> preventing from taking even coherent filesystem snapshot.
> 
> That's why I raise this issue again to hear from people what they think
> and these people shouldn't be containers and C/R people, because the
> latter already made up their minds.

Lol .. and disagreement persists among us :)

And indeed, I have heard and seen already a few opinions in favor
of permitting non-container checkpoint. From potential users (not
c/r people).

> 
> This is super-important issue to get right from the beginning.
> 
>> On the other hand, there has been a handful of use-cases and opinions
>> in favor of allowing both capabilities to co-exist. Not the mention
>> that nearly no additional code is necessary, on the contrary.
>>
>> As for #2, you didn't even bother to reply to the discussion that I
>> had started about it. This decision is important to allow future
>> flexibility of the mechanism, and to address the needs of several
>> potential users, as seen in that discussion and others. Here, too,
>> you are the _only_ one that advocates that direction.
> 
> Are you going to fork to-become-zombies, make them call restart(2) and
> zombify?

Yes.

> 
>> And the funniest thing -- *both* decisions can be *easily* overturned
>> in my patchset. In fact, regarding #2 - either way can be easily done
>> in it.
>>
>> So I wonder, what are the "big" issues that bother you so much ?
>> "if there is a will, there is a way".
> 
> Oren, don't you really understand?
> 
> Users want millions of things, but every thing has price.

I beg to differ: there is marginal price to support both -- in fact,
enforcing the container requirement (e.g. leaks detection - which,
btw, is imperfect and cannot be made race-free) *adds* code over
the non-container case. So in a sense, we get the no-container case
for free.

Oren.
