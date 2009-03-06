From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 00/11] track files for checkpointability
Date: Fri, 06 Mar 2009 11:42:04 -0800
Message-ID: <1236368524.10626.96.camel__7058.91319453276$1236368760$gmane$org@nimitz>
References: <20090305174037.GA2274@x200.localdomain>
	<1236280567.22399.99.camel@nimitz>
	<20090305210840.GA2499@x200.localdomain>
	<1236288427.22399.122.camel@nimitz>
	<20090305220044.GA2819@x200.localdomain>
	<1236291865.22399.139.camel@nimitz> <20090306143425.GA31250@us.ibm.com>
	<1236354509.10626.29.camel@nimitz> <20090306162337.GA3040@us.ibm.com>
	<1236357965.10626.51.camel@nimitz> <20090306182451.GA6307@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090306182451.GA6307-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 2009-03-06 at 12:24 -0600, Serge E. Hallyn wrote:
> > But, these "early stage" messages are completely opposed to an approach
> > that uses sys_checkpoint() in some form (like with a -1 fd as an
> > argument).
> 
> Well I disagree with that.  The 'early stage' messages could be seen as
> either:
> 
>         1. a short-term way to prioritize resources to support
>         or
>         2. a long-term way to catch new resources introduced
>         without checkpoint/restart support
> 
> I don't believe 2. would work.  I think 1. would work, but that we
> risk imposing permanent code changes to support a temporary goal.

I should be a bit more clear.  My goal (and I think Ingo's) here is to
come up with a mechanism that will make the checkpoint feature less
likely to break once we merge it into the tree.  I'm looking for a tool
that people can utilize, even if they don't necessarily care about
checkpoint/restart.

If we *completely* depend on sys_checkpoint() as the interface for
determining if we are checkpointable, we don't have such a tool.  We
have a tool that the checkpoint/restart developers and probably some
testers can and certainly will use.  This is still very, very useful.
But, it probably won't ever generate a bug report from anyone who
doesn't specifically care about c/r.

As far as detecting *new* resources.  Well, crap.  I don't think our
little ->may_checkpoint flags can do that.  My little f_op trick will
help and is better than nothing.  But, as you noted, it is far from
perfect because we'll probably have people just copying the generic*
functions into new code.

-- Dave
