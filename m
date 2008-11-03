From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [BIG RFC] Filesystem-based checkpoint
Date: Mon, 03 Nov 2008 09:23:19 -0800
Message-ID: <1225732999.12673.442.camel@nimitz>
References: <1225219047.12673.182.camel@nimitz>
	<m163n9y7yb.fsf@frodo.ebiederm.org> <1225411757.12673.383.camel@nimitz>
	<m1k5bpwj8j.fsf@frodo.ebiederm.org> <1225462902.12673.398.camel@nimitz>
	<m1r65wpjx2.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1r65wpjx2.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
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

On Fri, 2008-10-31 at 13:51 -0700, Eric W. Biederman wrote:
> Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:
> > Eric, you were saying that my interface had way too many "dangerous
> > syscalls".  How does this relate to user namespaces and creating objects
> > with particular ids?  Surely if the true problem with my suggested
> > approach has to do with creating empty namespaces, the same problem
> > exists with the sys_checkpoint() approach.
...
> In a sys_restore() scenario at the very start you can check to make
> certain that the reference count for the namespaces is 1 and that they
> are empty.  Which means there is no chance of confusing user space.
> 
> With fork_and_set_child_pid() what is a simple cheap one time check
> becomes an expensive painful one, if you can even implement it at all.
> 
> The difference is that with a bunch of small pieces you loose atomicity. 

I think we're just trading trade-offs here. :)

I believe your suggestion is simply to constrain the problem.  If we put
extra restrictions on sys_restart() to ensure that its job is simpler
then some of the implementation problems just go away.  That's
definitely a good approach.

In this case you are saying that, during a call to sys_restart(), we
should ensure that the task doing the restoring holds the only reference
to those namespaces.  If it does, that means that there can't possibly
be any security implications because no one else can possibly even *see*
those namespaces.  This is a laudable goal, but I'm not sure it works in
practice without more code.

The problem is that we can't possibly use refcounts (at least the ones
we have today) alone.  For instance, with the pid namespace, we would
have 1 ref for the 'init' process doing the sys_restore() call and then
a possible second refcount for /proc.  Perhaps we could differentiate
references to namespaces that instantiate objects inside the namespaces
from purely references to the namespace *itself*.

Rather than offering a solution for the filesystem-based approach, I'll
venture this: whatever I come up with will be extra code to glue things
back together, to detect when namespaces are "fresh" and able to be
scribbled into.  

Anyway, it's obvious that you and Oren don't like my approach just as
much as I don't like the syscalls.  So, I'll just drop it for now.  But,
please do keep it in the back of your minds in case it applies
somewhere.

-- Dave
