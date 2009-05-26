From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 18/38] C/R: core stuff
Date: Tue, 26 May 2009 23:35:03 +0400
Message-ID: <20090526193503.GB11909__349.196667275642$1243366606$gmane$org@x200.localdomain>
References: <1242968132-1044-1-git-send-email-adobriyan@gmail.com>
	<1242968132-1044-18-git-send-email-adobriyan@gmail.com>
	<20090526131644.GA20920@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090526131644.GA20920-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, May 26, 2009 at 08:16:44AM -0500, Serge E. Hallyn wrote:
> Quoting Alexey Dobriyan (adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> > Introduction
> > ------------
> > Checkpoint/restart (C/R from now) allows to dump group of processes to disk
> > for various reasons like saving process state in case of box failure or
> > restoration of group of processes on another or same machine later.
> > 
> > Unlike, let's say, hypervisor C/R style which only needs to freeze guest kernel
> > and dump more or less raw pages, proposed C/R doesn't require hypervisor.
> > For that C/R code needs to know about all little and big intimate kernel details.
> > 
> > The good thing is that not all details needs to be serialized and saved
> > like, say, readahead state. The bad things is still quite a few things
> > need to be.
> 
> Hi Alexey,
> 
> the last time you posted this, I went through and tried to discern the
> meaningful differences between yours and Oren's patchsets.  Then I sent some
> patches to Oren to make his set configurable to act more like yours.  And Oren
> took them!  But now you resend this patchset with no real changelog, no
> acknowledgment that Oren's set even exists

Is this a requirement? Everybody following topic already knows about
Oren's patchset.

> - or is much farther along and pretty widely reviewed and tested (which is
> only because he started earlier and, when we asked for your counterpatches
> at an earlier stage, you would never reply) - or, most importantly, what
> it is that you think your patchset does that his does not and cannot.

There are differences. And they're not small like you're trying to describe
but pretty big compared the scale of the problem.

> *Why* are you spending your time on this instead of helping with Oren's set?

Because we disagree with some core directions Oren chose.
ANK literally said: "I don't know how to dump live netns".

So, partly patchset was created so that absolutely nobody will tell us
to shut up and show the code.

The other part, is that I looked at Oren patchset, found quite a lot of
suspicious, broken and unclean places and decided that it'd be faster
to start from scratch because sending patches will overhaul like 85% of
the code.

One example, is why CKPT_HDR_CPU and CKPT_RESTART_BLOCK exist at all?
Should objects in image be only what sharable objects are in kernel
(expect VMAs, pages and possibly file descriptors)? pt_regs don't exist
by themselves after all.

And since you guys showed that just idea of in-kernel checkpointing is not
rejected outright, it doesn't mean that you can drag every single idea too.
Because history shows, that once something (especially user-visible,
like restart syscall semantics) is in kernel it's nearly impossible
to cut it out, so it's very-very important to get it right from the very
beginning.

Now here goes second version, with prefixes fixed (kstate_") like Ingo
suggested and so Linus could look at the code and with C/R code moved
close to usual code and with more checks added (which you should have
already!) to not restore null selector in %cs for example.

> The code really isn't all that different...

> Maybe you just think that two independently written patchsets will expose
> more gotchas that we'll need to catch, so you're continuing on this effort
> under the expectation that eventualy we'll merge the two sets?

Well, it already exposes. Just print both, and watch for differences.

> Honestly, I have great respect for your coding abilities.  And if 'voices
> from on high' tell us to base upon your code, I'd be fine with that, I
> have no real problems with what I see on yet another cursory look.  But
> given the amount of collective time that's been spent developing, reviewing,
> and testing Oren's set, it wouldn't make any sense to just jump.  So
> I'd still just like to know how you see this proceeding.

Yes, please, someone decide on "checkpoint semi-live container" issue.
