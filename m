From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 18/38] C/R: core stuff
Date: Wed, 27 May 2009 16:56:27 -0400
Message-ID: <4A1DA8FB.3000306__26437.5860141174$1243457956$gmane$org@cs.columbia.edu>
References: <1242968132-1044-1-git-send-email-adobriyan@gmail.com>	<1242968132-1044-18-git-send-email-adobriyan@gmail.com>	<20090526131644.GA20920@hallyn.com>
	<20090526193503.GB11909@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090526193503.GB11909-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
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
> On Tue, May 26, 2009 at 08:16:44AM -0500, Serge E. Hallyn wrote:
>> Quoting Alexey Dobriyan (adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
>>> Introduction
>>> ------------
>>> Checkpoint/restart (C/R from now) allows to dump group of processes to disk
>>> for various reasons like saving process state in case of box failure or
>>> restoration of group of processes on another or same machine later.
>>>
>>> Unlike, let's say, hypervisor C/R style which only needs to freeze guest kernel
>>> and dump more or less raw pages, proposed C/R doesn't require hypervisor.
>>> For that C/R code needs to know about all little and big intimate kernel details.
>>>
>>> The good thing is that not all details needs to be serialized and saved
>>> like, say, readahead state. The bad things is still quite a few things
>>> need to be.
>> Hi Alexey,
>>
>> the last time you posted this, I went through and tried to discern the
>> meaningful differences between yours and Oren's patchsets.  Then I sent some
>> patches to Oren to make his set configurable to act more like yours.  And Oren
>> took them!  But now you resend this patchset with no real changelog, no
>> acknowledgment that Oren's set even exists
> 
> Is this a requirement? Everybody following topic already knows about
> Oren's patchset.

Some people do ack other people's work. See for example patches #1
and #24 in my recent post. You're welcome.

> 
>> - or is much farther along and pretty widely reviewed and tested (which is
>> only because he started earlier and, when we asked for your counterpatches
>> at an earlier stage, you would never reply) - or, most importantly, what
>> it is that you think your patchset does that his does not and cannot.
> 
> There are differences. And they're not small like you're trying to describe
> but pretty big compared the scale of the problem.

I've asked before, and I repeat now: can you enumerate these "big"
scary differences that make it such a "big" problem ?

So far, we identified two main "design" issues -

1) Whether or not allow c/r of sub-container (partial hierarchy)

2) Creation of restarting process hierarchy in kernel or in userspace

As for #1, you are the _only_ one who advocates restricting c/r to
a full container only. I guess you have your reasons, but I'm unsure
what they may be.

On the other hand, there has been a handful of use-cases and opinions
in favor of allowing both capabilities to co-exist. Not the mention
that nearly no additional code is necessary, on the contrary.

As for #2, you didn't even bother to reply to the discussion that I
had started about it. This decision is important to allow future
flexibility of the mechanism, and to address the needs of several
potential users, as seen in that discussion and others. Here, too,
you are the _only_ one that advocates that direction.

And the funniest thing -- *both* decisions can be *easily* overturned
in my patchset. In fact, regarding #2 - either way can be easily done
in it.

So I wonder, what are the "big" issues that bother you so much ?
"if there is a will, there is a way".

> 
>> *Why* are you spending your time on this instead of helping with Oren's set?
> 
> Because we disagree with some core directions Oren chose.
> ANK literally said: "I don't know how to dump live netns".

Eh... and you have it all sorted out ?  (yeah, I do, but not in
this patchset).

> 
> So, partly patchset was created so that absolutely nobody will tell us
> to shut up and show the code.

Oh well ... "the" code meaning "your" code I suppose.

> 
> The other part, is that I looked at Oren patchset, found quite a lot of
> suspicious, broken and unclean places and decided that it'd be faster
> to start from scratch because sending patches will overhaul like 85% of
> the code.

So you actually took the time to read and review. And then you spent
even more time in .... calculating this number !  Feedback appreciated.

If you looked closely you would have seen that we do address your
concerns over time.

> 
> One example, is why CKPT_HDR_CPU and CKPT_RESTART_BLOCK exist at all?
> Should objects in image be only what sharable objects are in kernel
> (expect VMAs, pages and possibly file descriptors)? pt_regs don't exist
> by themselves after all.

A good reason to break it into small pieces is for ease of maintenance
and debugging, as well as in the future easier transition between
incompatible kernel versions. I think it's better than a few-pages-long
single struct. And it encourages more naming of things.

But ... I'm confused ... is this your "big" concern ?  Oh well, if
that's what stands in your way, we could even rework that (~1.3% of
the code ? I reckon...).

> 
> And since you guys showed that just idea of in-kernel checkpointing is not
> rejected outright, it doesn't mean that you can drag every single idea too.
> Because history shows, that once something (especially user-visible,
> like restart syscall semantics) is in kernel it's nearly impossible
> to cut it out, so it's very-very important to get it right from the very
> beginning.
> 

Yes. Let's indeed talk about how to get it "right". Please do
participate in the public discussions and efforts. Working together
would be better for everyone.

> Now here goes second version, with prefixes fixed (kstate_") like Ingo
> suggested and so Linus could look at the code and with C/R code moved
> close to usual code and with more checks added (which you should have
> already!) to not restore null selector in %cs for example.

It is far from perfect. In fact, it's even clearly commented as such,
and exactly there.  It would have been helpful if you pointed that
out in a review, or even - god forbid - sent a patch to improve it.

But it works, and it lets people play with a more-than-a-toy
implementation and provide us with important feedback. Oh, and by
the way, it doesn't require that people use containers to try it out.
Pretty handy, don't you think ?

> 
>> The code really isn't all that different...
> 
>> Maybe you just think that two independently written patchsets will expose
>> more gotchas that we'll need to catch, so you're continuing on this effort
>> under the expectation that eventualy we'll merge the two sets?
> 
> Well, it already exposes. Just print both, and watch for differences.
> 
>> Honestly, I have great respect for your coding abilities.  And if 'voices
>> from on high' tell us to base upon your code, I'd be fine with that, I
>> have no real problems with what I see on yet another cursory look.  But
>> given the amount of collective time that's been spent developing, reviewing,
>> and testing Oren's set, it wouldn't make any sense to just jump.  So
>> I'd still just like to know how you see this proceeding.
> 
> Yes, please, someone decide on "checkpoint semi-live container" issue.

Have you not yet read enough opinion of users that would like to see
this capability ?  What would be enough to convince you ?  And really,
why not ?

Cheers,

Oren.
