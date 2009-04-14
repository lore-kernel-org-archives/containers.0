From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: "partial" container checkpoint
Date: Tue, 14 Apr 2009 09:37:03 -0700
Message-ID: <1239727023.32604.69.camel__40986.7793707692$1239728259$gmane$org@nimitz>
References: <20090410023539.GK27788@x200.localdomain>
	<20090413214701.GA24509@us.ibm.com> <49E424A3.60606@cs.columbia.edu>
	<20090414152951.GA7703@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090414152951.GA7703-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2009-04-14 at 10:29 -0500, Serge E. Hallyn wrote:
> I think the perceived need for it comes, as above, from the pure
> checkpoint-a-whole-container-only view.  So long as you will
> checkpoint/restore a whole container, then you'll end up doing
> something requiring privilege anyway.  But that is not all of
> the use cases.

Yeah, there are certainly a lot of shades of gray here.  I've been
talking to some HPC guys in the last couple of days.  They certainly
have a need for checkpoint/restart, but much less of a need for doing
entire containers.  

It also occurs to me that we have the potential to pull some
long-out-of-tree users back in.  VMADump users, for instance:

	http://bproc.sourceforge.net/c268.html

If we could do *just* a selective checkpoint of a single process's VMAs,
the bproc users could probably use sys_checkpoint() in some way.  That's
*way* less than an entire container, but it would be really useful to
some people.   

-- Dave
