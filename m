From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH] flexible array implementation v3
Date: Thu, 23 Jul 2009 09:02:17 -0700
Message-ID: <1248364937.24021.725.camel@nimitz>
References: <20090722175345.7154C2F2@kernel> <4A68855C.1060702@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A68855C.1060702-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: vda.linux-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 2009-07-23 at 11:44 -0400, Oren Laadan wrote:
> Probably premature, but -- I wonder if it's worth adding interfaces to:
> 
> * copy a range of elements at once (perhaps to/from regular array ?
> or userspace ? -- depending on potential users)

I can see this making some sense, especially if you're dumping a bunch
of stuff out to userspace and don't want to worry about page boundaries,
etc...  Or, if you have a ton of stuff to copy and some of the
flex_array overhead is getting in the way.  I'm not opposed to it, but I
think I'd want to see a user first to make sure I got the implementation
right.

> * (macro ?) iterate through elements (better have it ready for users
> of flex_array before, than convert their code later on)

I've thought about this, but I don't think there's much advantage to
doing it.  It obfuscates things without any real gain in simplicity.  We
have LIST_FOR_EACH() because containerof() and some of the typing is a
little non-obvious.  But, here, I think it's mostly dummy-proof:

We need a 'tmp' variable here because unlike list traversal, there's no
position implied in the variables.  So, we're looking at (with a new
macro):

	int tmp;
	FA_FOR_EACH(fa, var, tmp)
		foo(var);

vs.

	int i;
	for (i = 0; i < fa->total_nr_elements; i++)
		foo(flex_array_get(fa, i));

The macro *looks* cleaner, but I don't think it really buys us much.

-- Dave
