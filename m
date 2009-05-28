From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 18/38] C/R: core stuff
Date: Thu, 28 May 2009 15:33:34 -0700
Message-ID: <20090528223334.GB17402@us.ibm.com>
References: <1242968132-1044-1-git-send-email-adobriyan@gmail.com>
	<1242968132-1044-18-git-send-email-adobriyan@gmail.com>
	<20090526131644.GA20920@hallyn.com>
	<20090526193503.GB11909@x200.localdomain>
	<4A1DA8FB.3000306@cs.columbia.edu>
	<20090527221753.GB8321@x200.localdomain>
	<4A1DC270.8080807@cs.columbia.edu>
	<20090528153322.GB18256@x200.localdomain>
	<4A1F0E29.2040506@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A1F0E29.2040506-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, May 28, 2009 at 06:20:25PM -0400, Oren Laadan wrote:
> 
> 
> Alexey Dobriyan wrote:
> > On Wed, May 27, 2009 at 06:45:04PM -0400, Oren Laadan wrote:
> >> Alexey Dobriyan wrote:
> >>> On Wed, May 27, 2009 at 04:56:27PM -0400, Oren Laadan wrote:
> >>>> Alexey Dobriyan wrote:
> >>>>> On Tue, May 26, 2009 at 08:16:44AM -0500, Serge E. Hallyn wrote:
> >>>>>> Quoting Alexey Dobriyan (adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> >>>>>>> Introduction
> >>>>>>> ------------
> >>>>>>> Checkpoint/restart (C/R from now) allows to dump group of processes to disk
> >>>>>>> for various reasons like saving process state in case of box failure or
> >>>>>>> restoration of group of processes on another or same machine later.
> >>>>>>>
> >>>>>>> Unlike, let's say, hypervisor C/R style which only needs to freeze guest kernel
> >>>>>>> and dump more or less raw pages, proposed C/R doesn't require hypervisor.
> >>>>>>> For that C/R code needs to know about all little and big intimate kernel details.
> >>>>>>>
> >>>>>>> The good thing is that not all details needs to be serialized and saved
> >>>>>>> like, say, readahead state. The bad things is still quite a few things
> >>>>>>> need to be.
> >>>>>> Hi Alexey,
> >>>>>>
> >>>>>> the last time you posted this, I went through and tried to discern the
> >>>>>> meaningful differences between yours and Oren's patchsets.  Then I sent some
> >>>>>> patches to Oren to make his set configurable to act more like yours.  And Oren
> >>>>>> took them!  But now you resend this patchset with no real changelog, no
> >>>>>> acknowledgment that Oren's set even exists
> >>>>> Is this a requirement? Everybody following topic already knows about
> >>>>> Oren's patchset.
> >>>> Some people do ack other people's work. See for example patches #1
> >>>> and #24 in my recent post. You're welcome.
> >>>>
> >>>>>> - or is much farther along and pretty widely reviewed and tested (which is
> >>>>>> only because he started earlier and, when we asked for your counterpatches
> >>>>>> at an earlier stage, you would never reply) - or, most importantly, what
> >>>>>> it is that you think your patchset does that his does not and cannot.
> >>>>> There are differences. And they're not small like you're trying to describe
> >>>>> but pretty big compared the scale of the problem.
> >>>> I've asked before, and I repeat now: can you enumerate these "big"
> >>>> scary differences that make it such a "big" problem ?
> >>>>
> >>>> So far, we identified two main "design" issues -
> >>> Why in "? Yes, they are high-level design issues.
> >>>
> >> In quotes, because I argued further on that, although my patchset
> >> takes a stand on both issues, it can be easily reverted _within_
> >> that patchset. Moreover, I argue that they can co-exist.
> >>
> >>>> 1) Whether or not allow c/r of sub-container (partial hierarchy)
> >>>>
> >>>> 2) Creation of restarting process hierarchy in kernel or in userspace
> >>>>
> >>>> As for #1, you are the _only_ one who advocates restricting c/r to
> >>>> a full container only. I guess you have your reasons, but I'm unsure
> >>>> what they may be.
> >>> The reason is that checkpointing half-frozen, half-live container is
> >>> essentially equivalent to live container which adds much complexity
> >>> to code fundamentally preventing kernel from taking coherent snapshot.
> >>>
> >>> In such situations kernel will do its job badly.
> >> In such situation the kernel will do a bad job if the user is asking
> >> for a bad job.
> > 
> > User doesn't even understand why we're discussing this issue so hard.
> > 
> >> Just like checkpointing without snapshotting the file system and expecting
> >> it to always work.
> > 
> > This is different.
> > 
> > Kernel can't do anything about not-synced fs. Because nodoby is
> > advocating that kernel should sync fs. Consequently, screwup in fs sync is
> > clearly user failure. Any (yours, mine) in-kernel C/R has this failure mode,
> > so we skip it and discuss what's left.
> > 
> > Now, kernel CAN do something about tasks and other data structures
> > because it easily controls them.
> > 
> > Your procedure for checkpointing starts with "kill -STOP".
> 
> Wrong. It requires the processes to be frozen.
> 
> > To make anything reliable, you have to ban "kill -CONT" for the duration of
> > checkpointing. Is this done BTW? I don't remember new flags added
> > in task_struct. Or this is going to be skipped on grounds that it's
> > user screwup (potentially oopsable).
> > 
> > That's why, OpenVZ relies on suspend-to-ram freezer solely, because userspace
> > can't arbitrarily send suspend and freeze notifications. We only need to
> > protect against untimely STR unfreeze which only adds code in C/R code
> > not in task_struct.
> 
> Same principle for both patchsets:  tasks may *not* be permitted to
> execute while being checkpointed.
> 
> For this I suggested a CHECKPOINTING freezer state: transition to/from
> this state is done _only_ by sys_checkpoint(), so that checkpointed
> processes cannot be unfrozen. Matt Helseley already posted a patch to
> implement this.

In case it helps, here's the patch and some feedback Oren gave me:

https://lists.linux-foundation.org/pipermail/containers/2009-May/017586.html

Cheers,
	-Matt Helsley
