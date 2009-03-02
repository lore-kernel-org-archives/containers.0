From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 8/8] check files for checkpointability
Date: Mon, 02 Mar 2009 08:27:31 -0800
Message-ID: <1236011251.26788.450.camel__36390.0541481145$1236045979$gmane$org@nimitz>
References: <20090227203425.F3B51176@kernel>
	<20090227203435.98735E54@kernel> <20090302133754.GA8033@us.ibm.com>
	<20090302095917.6cfeda55@thinkcentre.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090302095917.6cfeda55-4v5LP+xe+1byhTdZtsIeww@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2009-03-02 at 09:59 -0600, Nathan Lynch wrote:
> On Mon, 2 Mar 2009 07:37:54 -0600
> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> > So on a practical note, Ingo's scheme appears to be paying off.  In
> > order for any program's files_struct to be checkpointable right now,
> > it must be statically compiled, else ld.so (I assume) looks up
> > /proc/$$/status.  So since proc is not checkpointable, the result
> > is irreversibly non-checkpointable.
> > 
> > So...  does it make sense to mark proc as checkpointable?  Do we
> > reasonably assume that the same procfile will be available at
> > restart?
> 
> With respect to /proc/$x/* where $x is the pid the restarted task wants,
> is that not a chicken-and-egg problem?

Do you mean that we have to go look into /proc to figure out which task
we want before we can checkpoint it?  That makes the process *doing* the
checkpoint uncheckpointable, but no the process being examined.

Anyway, I'll fix /proc.  It is pretty important.

-- Dave
