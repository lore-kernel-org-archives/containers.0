From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [BIG RFC] Filesystem-based checkpoint
Date: Fri, 31 Oct 2008 07:21:42 -0700
Message-ID: <1225462902.12673.398.camel@nimitz>
References: <1225219047.12673.182.camel@nimitz>
	<m163n9y7yb.fsf@frodo.ebiederm.org> <1225411757.12673.383.camel@nimitz>
	<m1k5bpwj8j.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1k5bpwj8j.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2008-10-30 at 20:12 -0700, Eric W. Biederman wrote:
> Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:
> >> > System calls in Linux are fast.  Doing lots of them is not a problem.
> >> > If it becomes one, we can always export a condensed version of this
> >> > format next to the expanded one, kinda like ftrace does.  Atomicity with
> >> > this approach is also not a problem.  The system call in this approach
> >> > doesn't return until the checkpoint is completely written out.
> >> 
> >> Extra copies for something (memory) you want to transfer quickly
> >> and efficiently is a problem.
> >
> > That's definitely true.  But, as I said, this approach isn't bound to
> > copying everything.  We have the flexibility to choose what we do.
> 
> With a file descriptor I can push the data onto a network socket and
> the receiving process is on another computer.  0 copies, 0 trips
> to user space.  I'm not certain how you would achieve that with filesystem
> approach.

for sys_checkpoint() does:
	1. copy from task_struct (or whatever kernel struct) into buffer
	2. run vfs_write() with that buffer and the user fd
	3. fd target reads from that buffer

The fs approach would:
	1. user calls read()
	2. fs fills data in directly into *userspace* buffer
	3. user does sendfile, etc...

See?  sys_checkpoint() *does* a copy.  It just does it into a kernel
buffer.  That's why we need to call vfs_write().

> I'm saying inspecting another process is a very racy operation so something
> we need to be especially careful with. 

No disagreement from me on that one.  

> >> Ultimately the question is how do you do checkpoint restore and I just
> >> don't see that happening with a filesystem interface.  Way way way too many
> >> dangerous syscalls that are only needed for one thing.
> >
> > I completely understand what you're saying here.  But, could you
> > distinguish how this differs from the current way that sys_checkpoint()
> > does it?  Surely, the checkpoint format is an ABI.  It is a complex ABI
> > with many, many constituent structures.  This is an ABI with many, many,
> > ways of reading simple data.  Seems like just slicing up the problem
> > differently to me.
> 
> I was thinking about restore.  Creating objects with a certain id can
> easily be a security risk if you are not creating the namespace those
> objects live in at the same time.  There is currently the downside
> that we can't create namespaces as unprivileged users ( The
> implementation of suid is so annoying). But the general concept still
> applies, and if we ever get the uid namespace correct we will be able
> to create namespaces as unprivileged users.

Eric, you were saying that my interface had way too many "dangerous
syscalls".  How does this relate to user namespaces and creating objects
with particular ids?  Surely if the true problem with my suggested
approach has to do with creating empty namespaces, the same problem
exists with the sys_checkpoint() approach.

-- Dave
