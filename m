From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v14-rc3][PATCH 36/36] Stub implementation of IPC
	namespace c/r
Date: Mon, 13 Apr 2009 09:10:22 -0500
Message-ID: <20090413141022.GA13007@us.ibm.com>
References: <1239107264-21775-1-git-send-email-orenl@cs.columbia.edu>
	<1239107264-21775-37-git-send-email-orenl@cs.columbia.edu>
	<20090409212939.GD5115@us.ibm.com>
	<49E163FC.4080306@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49E163FC.4080306-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> 
> Serge E. Hallyn wrote:
> > Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> >> From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> >>
> >> Changes:
> >>  - Update to match UTS changes
> >>
> >> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> >> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> > 
> > Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > 
> > However...
> > 
> >> +	if (!!ipc_ns ^ !(flags & CLONE_NEWIPC))
> >> +		return -EINVAL;
> > 
> > Every time I see this I have to think about whether it is right or not.
> > I'm not sure whether it's worth commenting (at each such meme) that
> > CLONE_NEWIPC only needed to be set the first time we ran across that
> > ipcns, or whether it's indicative that there is a simpler way the code
> > could be done.  But if it just took me a twice-over to see that it's
> > right, when I'd already confirmed that with the CLONE_NEWUTS version
> > last week, then a fresh reviewer will be cursing your name...
> 
> This is a consistency check: ensure that the state of the objhash as
> reflected in the value of ipc_ns is consistent with the flags.

I know what it is, but coding it this way is inconsiderate to everyone
trying to review the code.  The mind doesn't do well with 'not' to begin
with, and you've got three of them plus and xor here in one line, in
the flow of a function.  (Sure, you can argue !! is not two nots :)
So while you're trying to read the flow of the function you always stop
there.  That impedes review.

(I'm not trying to be criticial or beat a dead horse, just trying to
explain precisely what it is that is hard to review - since in the end
the person reviewing the code when there's a subtle bug in 2 years is
the one the code should be designed for)

> I'll add a comment.

Thanks.  But actually I think it's better if you move that into an
appropriately named little static inline helper (commented).  Then the
reader can verify it once separately, and then ignore how it works while
verifying the surrounding code.  Not just here but, other places where
you do this.

thanks,
-serge
