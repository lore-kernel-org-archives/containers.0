From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 00/11] track files for checkpointability
Date: Fri, 06 Mar 2009 08:46:05 -0800
Message-ID: <1236357965.10626.51.camel__46314.3208100975$1236358115$gmane$org@nimitz>
References: <20090305163857.0C18F3FD@kernel>
	<20090305174037.GA2274@x200.localdomain>
	<1236280567.22399.99.camel@nimitz>
	<20090305210840.GA2499@x200.localdomain>
	<1236288427.22399.122.camel@nimitz>
	<20090305220044.GA2819@x200.localdomain>
	<1236291865.22399.139.camel@nimitz> <20090306143425.GA31250@us.ibm.com>
	<1236354509.10626.29.camel@nimitz> <20090306162337.GA3040@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090306162337.GA3040-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 2009-03-06 at 10:23 -0600, Serge E. Hallyn wrote:
> Which imo is fine, but my question is whether that leaves any actual
> value in the persistent per-resource uncheckpointable flag.

OK, let's take a look back at this discussion a little bit and how we
got here.

Ingo quotes:
> Yeah, per resource it should be. That's per task in the normal 
> case - except for threaded workloads where it's shared by 
> threads.

> Uncheckpointable should be a one-way flag anyway. We want this 
> to become usable, so uncheckpointable functionality should be as 
> painful as possible, to make sure it's getting fixed ...

> Is there any automated test that could discover C/R breakage via 
> brute force? All that matters in such cases is to get the "you 
> broke stuff" information as soon as possible. If it comes at an 
> early stage developers can generally just fix stuff.

You add these things together and you get what I posted.  My patch is:
1. per resource
2. has a one way flag
3. Gives messages to developers at an early stage (dmesg) and lets them
   explore it more thoroughly (/proc)

But, these "early stage" messages are completely opposed to an approach
that uses sys_checkpoint() in some form (like with a -1 fd as an
argument).

Think of it like lockdep.  We *could* have designed lockdep to simply
give us a nice message whenever we do an a/b b/a deadlock.  That would
be helpful.  Or, we could design it to record all lock acquisitions that
didn't deadlock to see if they ever possibly deadlock.  (We did the
second one, btw).  That gave an early, useful, warning that developers
could fix before we encounter an actual problem.  I'm advocating such a
mechanism for c/r.  

-- Dave
