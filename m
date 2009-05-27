From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 18/38] C/R: core stuff
Date: Wed, 27 May 2009 15:40:01 -0700
Message-ID: <20090527154001.86a5abff.akpm__19649.9674734243$1243464109$gmane$org@linux-foundation.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 28 May 2009 02:17:53 +0400
Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> > 1) Whether or not allow c/r of sub-container (partial hierarchy)
> > 
> > 2) Creation of restarting process hierarchy in kernel or in userspace
> > 
> > As for #1, you are the _only_ one who advocates restricting c/r to
> > a full container only. I guess you have your reasons, but I'm unsure
> > what they may be.
> 
> The reason is that checkpointing half-frozen, half-live container is
> essentially equivalent to live container which adds much complexity
> to code fundamentally preventing kernel from taking coherent snapshot.
> 
> In such situations kernel will do its job badly.
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
> 
> This is super-important issue to get right from the beginning.

<pipes up>

yeah, checkpointing a partial hierarchy at this stage sounds like
overreach.  Get full-container working usably first, think about
sub-containers in version 2.

<pipes down again>
