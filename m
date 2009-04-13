From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 00/30] C/R OpenVZ/Virtuozzo style
Date: Mon, 13 Apr 2009 11:07:01 -0700
Message-ID: <1239646021.32604.45.camel@nimitz>
References: <20090410023207.GA27788@x200.localdomain>
	<1239340031.24083.21.camel@nimitz>
	<20090413091423.GA19236@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090413091423.GA19236-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
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
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 2009-04-13 at 13:14 +0400, Alexey Dobriyan wrote:
> On Thu, Apr 09, 2009 at 10:07:11PM -0700, Dave Hansen wrote:
> > I'm curious how you see these fitting in with the work that we've been
> > doing with Oren.  Do you mean to just start a discussion or are you
> > really proposing these as an alternative to what Oren has been posting?
> 
> Yes, this is posted as alternative.

I'm sure that you can understand that we've been working on Oren's
patches for a bit and don't want to jump ship on a whim. :)

Do you think we can change Oren's patch sufficiently to meet your needs
here?  Do you think we can change your patch sufficiently to meet Oren's
needs?

> Some design decisions are seen as incorrect from here like:
> * not rejecting checkpoint with possible "leaks" from container

Could you elaborate on this a bit?  This sounds really important, but
I'm having difficulty seeing how your patch addresses this or how Oren's
doesn't.

> * not having CAP_SYS_ADMIN on restart(2)
> * having small (TASK_COMM_LEN) and bigger (objref[1]) image format
>   misdesigns.

The format is certainly still in a huge amount of flux.  I'd be really
happy to see patches fixing these or clarifying them.  I'm planning on
going and looking at your patches in detail right now.  Would you mind
doing a more detailed review of Oren's so that we could use your
expertise to close some of these gaps in the format?

> * doing fork(2)+restart(2) per restarted task and whole orchestration
>   done from userspace/future init task.

Yeah, we've certainly argued plenty about this one amongst ourselves.
I'm personally open to changing this especially if you feel strongly
about it.

> * not seeing bigger picture (note, this is not equivalent to supporting
>   everything at once, nobody is asking for everything at once) wrt shared
>   objects and format and code changes because of that (note again, image
>   format will change, but it's easy to design high level structure which
>   won't change)
> * checking of unsupported features done at wrong place and wrong time
>   and runtime overhead because of that on CR=y kernels.

Yeah, I'm especially worried with respect to the shared objects right
now.  I'm pestering Oren to replace a big chunk of that stuff with other
garbage that I've dreamed up.  I'll go take a look at how you do this in
your patches...  Perhaps it will work even better.

-- Dave
