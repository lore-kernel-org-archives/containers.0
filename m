From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC][v7][PATCH 0/9] Implement clone2() system call
Date: Wed, 30 Sep 2009 09:34:43 +0400
Message-ID: <20090930053443.GA1010__21056.3566921794$1254288944$gmane$org@x200>
References: <20090924165548.GA16586@us.ibm.com> <20090924175542.GA27678@x200>
	<20090924183556.GA31356@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090924183556.GA31356-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: arnd-r2nGTMty4D4@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Sep 24, 2009 at 01:35:56PM -0500, Serge E. Hallyn wrote:
> Quoting Alexey Dobriyan (adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> > I don't like this even more.
> > 
> > Pid namespaces are hierarchical _and_ anonymous, so simply
> > set of numbers doesn't describe the final object.
> > 
> > struct pid isn't special, it's just another invariant if you like
> > as far as C/R is concerned, but system call is made special wrt pids.
> > 
> > What will be in an image? I hope "struct kstate_image_pid" with several
> 
> Sure pid namespaces are anonymous, but we will give each an 'objref'
> valid only for a checkpoint image, and store the relationship between
> pid namespaces based on those objrefs.  Basically the same way that user
> structs and hierarchical user namespaces are handled right now.

OK, that's certainly doable.

You're commiting yourself to creation of tasks in userspace if this goes in. :-\
Which can let you into putting wrong kind of relations into image.
IIRC, clone_flags were in image (still?), but tomorrow kernel will get
new way to acquire, say, uts_ns, which, in theory, can't be described by
a set of consecutive clones, so, you'll have to fixup something in kernel.

> > numbers and with references to such object from other places, so it
> > seems natural to do alloc_pid() with needed numbers and that attach new
> > shiny pid to where needed. But this clone_pid is only for task_struct's pids.
