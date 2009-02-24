From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Banning checkpoint (was: Re: What can OpenVZ do?)
Date: Tue, 24 Feb 2009 09:43:51 -0600
Message-ID: <20090224154351.GD17294__49927.1295535893$1235490885$gmane$org@us.ibm.com>
References: <20090218003217.GB25856@elte.hu> <1234917639.4816.12.camel@nimitz>
	<20090218051123.GA9367@x200.localdomain>
	<20090218181644.GD19995@elte.hu> <1234992447.26788.12.camel@nimitz>
	<20090218231545.GA17524@elte.hu>
	<20090219190637.GA4846@x200.localdomain>
	<1235070714.26788.56.camel@nimitz>
	<20090224044752.GB3202@x200.localdomain>
	<1235452285.26788.226.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1235452285.26788.226.camel@nimitz>
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
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Dave Hansen (dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> On Tue, 2009-02-24 at 07:47 +0300, Alexey Dobriyan wrote:
> > > I think what I posted is a decent compromise.  It gets you those
> > > warnings at runtime and is a one-way trip for any given process.  But,
> > > it does detect in certain cases (fork() and unshare(FILES)) when it is
> > > safe to make the trip back to the "I'm checkpointable" state again.
> > 
> > "Checkpointable" is not even per-process property.
> > 
> > Imagine, set of SAs (struct xfrm_state) and SPDs (struct xfrm_policy).
> > They are a) per-netns, b) persistent.
> > 
> > You can hook into socketcalls to mark process as uncheckpointable,
> > but since SAs and SPDs are persistent, original process already exited.
> > You're going to walk every process with same netns as SA adder and mark
> > it as uncheckpointable. Definitely doable, but ugly, isn't it?
> > 
> > Same for iptable rules.
> > 
> > "Checkpointable" is container property, OK?
> 
> Ideally, I completely agree.
> 
> But, we don't currently have a concept of a true container in the
> kernel.  Do you have any suggestions for any current objects that we
> could use in its place for a while?

I think the main point is that it makes the concept of marking a task as
uncheckpointable unworkable.  So at sys_checkpoint() time or when we cat
/proc/$$/checkpointable, we can check for all of the uncheckpointable
state of both $$ and its container (including whether $$ is a container
init).  But we can't expect that (to use Alexey's example) when one task
in a netns does a certain sys_socketcall, all tasks in the container
will be marked uncheckpointable.  Or at least we don't want to.

Which means task->uncheckpointable can't be the big stick which I think
you were hoping it would be.

-serge
