From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 10/30] cr: core stuff
Date: Tue, 14 Apr 2009 10:29:51 -0500
Message-ID: <20090414152951.GA7703__31564.0652938329$1239726607$gmane$org@us.ibm.com>
References: <20090410023539.GK27788@x200.localdomain>
	<20090413214701.GA24509@us.ibm.com>
	<49E424A3.60606@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49E424A3.60606-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> 
> Hi,
> 
> Serge E. Hallyn wrote:
> > Quoting Alexey Dobriyan (adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> > 
> > Hi Alexey,
> > 
> > as far as I can see, the main differences between this patch and the
> > equivalent in Oren's tree are:
> > 
> > 1. kernel auto-selects container init to freeze
> 
> Actually, this eliminates the possibility to checkpoint a subtree of
> tasks, which (under some obvious constraints) can be a handy feature.

Yes, I agree.  As Dave pointed out on irc yesterday, this patch shows a
very definate whole-container-only point of view which is worth
discussing.

> > 2. kernel freezes tasks
> 
> IMHO better to do it in userspace - that way userspace can accomplish
> other tasks while tasks are frozen, such as snapshot the filesystem,
> or block/unblock the network.

That's a good point.

> Is there a good argument to do it kernel ?

Convenience?  I guess you don't have to worry about getting your
checkpoint job into a cgroup by itself ahead of time.

> > 3. no objhash taking references
> > 4. no hbuf
> > 5. always require CAP_SYS_ADMIN
> 
> I'm now convinced (thanks, Serge!) that it's better not to require
> this unless we strictly have to.

:)  Cool.

I think the perceived need for it comes, as above, from the pure
checkpoint-a-whole-container-only view.  So long as you will
checkpoint/restore a whole container, then you'll end up doing
something requiring privilege anyway.  But that is not all of
the use cases.

-serge
