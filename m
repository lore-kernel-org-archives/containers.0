From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Checkpoint/restart (was Re: [PATCH 0/4] - v2 -  Object
	creation with a specified id)
Date: Tue, 22 Apr 2008 14:51:42 -0500
Message-ID: <20080422195142.GA22145@sergelap.austin.ibm.com>
References: <20080418054459.891481000@bull.net>
	<20080422193612.GA15835@martell.zuzino.mipt.ru>
	<1208890580.17117.14.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1208890580.17117.14.camel-FpcvD5N4B9G9xGwK5P7XA+TW4wlIGRCZ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, nick-dnCCA748QAperShJXdIFYw@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nadia.Derbey-6ktuUTfB/bM@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Dave Hansen (dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> On Tue, 2008-04-22 at 23:36 +0400, Alexey Dobriyan wrote:
> > On Fri, Apr 18, 2008 at 07:44:59AM +0200, Nadia.Derbey-6ktuUTfB/bM@public.gmane.org wrote:
> > >    . echo "LONG XX" > /proc/self/task/<my_tid>/next_id
> > >      next object to be created will have an id set to XX
> > >    . echo "LONG<n> X0 ... X<n-1>" > /proc/self/task/<my_tid>/next_id
> > >      next object to be created will have its ids set to XX0, ... X<n-1>
> > >      This is particularly useful for processes that may have several ids if
> > >      they belong to nested namespaces.
> > 
> > Can we answer the following questions before merging this patch:
> > 
> > a) should mainline kernel have checkpoint/restart feature at all
> > b) if yes, should it be done from kernel- or userspace?
> > 
> > Until agreement will be "yes/from userspace" such patches don't make
> > sense in mainline.
> 
> What do you mean by "from kernel" or "from userspace"?  Userspace has to
> be involved somewhere, right?  It at least need to open() the checkpoint
> file and pass it into the kernel.  		

Well let's start by answering a) :

	I vote yes  :-)

As for b), good question.  Except as Dave points out I think it's pretty
unlikely that we'll end up with "sys_checkpoint(checkpoint_dirnam)"
and "sys_restart(checkpointed_dirnam)".  Anything more user-space
driven will likely require userspace to set ids on resources, right?

But yes, we have to completely answer b) before this patch goes in, no
doubt about that.

Alexey, are you advocating for a completely kernel-driven approach, or
just making sure we come to a decision?

thanks,
-serge
