From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 2/2] Prevent container-inits from using CLONE_PARENT
Date: Thu, 18 Jun 2009 15:40:06 -0700
Message-ID: <20090618224006.GB14063@us.ibm.com>
References: <20090618024743.GA31515@us.ibm.com>
	<20090618025103.GB31672@us.ibm.com>
	<m18wjqkz2i.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m18wjqkz2i.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman [ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org] wrote:
| Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:
| 
| > Prevent container-inits from using CLONE_PARENT
| >
| > If a container-init creates a sibling (using CLONE_PARENT), pid namespace
| > semantics become complicated:
| >
| > 	- the "active pid namespace" of the sibling will be the descendant
| > 	  container, but its not obvious if that is correct.
| 
| It is correct the sibling must not change pid namespaces.  You are not
| allowed to escape out of a pid namespace.
| 
| > 	- if container-init exits, it will terminate the sibling, but again
| > 	  its not clear if that is the correct behavior.
| 
| Again correct because the container-init is the child reaper for the pid namespace.
| No reaper no namespace.
| 
| > 	- the sibling exists in both parent and child containers while current
| > 	  pid namespace semantics assume that only container-init can exist
| > 	  in both parent/child containers.
| 
| All tasks in the container also exist in the parent container.
| What assumption are you talking about?

You are right, thats not really different for CLONE_PARENT.

| 
| > 	- the parent of the sibling is not a descendant of container-init
| > 	  (while pid namespaces assume that all processes in the container
| > 	  are descendants of the container-init)
| 
| User space assumes that certainly.    What part of the pid namespace
| code makes such an assumption?

I was referring only to user-space view.

| 
| > 	- When the sibling dies, the SIGCHLD is sent to its parent (if
| > 	  alive), i.e the signal escapes the container to a parent container.
| > 	  (if the parent of the sibling exits, the container-init then becomes
| > 	  the reaper of the sibling).
| 
| Yes.
| 
| > To keep pid namespace semantics simple, prevent container-inits from using
| > CLONE_PARENT at least until we have a better understanding of CLONE_PARENT
| > and pid-namespace interactions.
| 
| The only argument that I can see that carries any weight is that unix
| semantics fundamentally assume a process tree.  Allowing init to use
| CLONE_PARENT creates a multi-rooted process tree.

Right.

| 
| At which point the is_global_init check is foolish.

Well, I was trying to disable CLONE_PARENT just with pid namespaces,
Disabling CLONE_PARENT for global init seemed independent of namespaces
and there was recent talk of potential users of CLONE_PARENT so I am
not sure if there is an init that uses the old threading model !

I don't have convincing reason besides "lets enable when uses/semanitcs
for CLONE_PARENT with pid namespaces are clear".




| 
| Eric
| 
| 
| > Untested, RFC patch :-)
| >
| > Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
| > ---
| >  kernel/fork.c |    8 ++++++++
| >  1 file changed, 8 insertions(+)
| >
| > Index: linux-mmotm/kernel/fork.c
| > ===================================================================
| > --- linux-mmotm.orig/kernel/fork.c	2009-06-17 18:23:23.000000000 -0700
| > +++ linux-mmotm/kernel/fork.c	2009-06-17 19:17:54.000000000 -0700
| > @@ -974,6 +974,14 @@ static struct task_struct *copy_process(
| >  	if ((clone_flags & CLONE_SIGHAND) && !(clone_flags & CLONE_VM))
| >  		return ERR_PTR(-EINVAL);
| >  
| > +	/*
| > +	 * To keep pid namespace semantics simple, prevent container-inits
| > +	 * from creating siblings.
| > +	 */
| > +	if ((clone_flags & CLONE_PARENT) &&
| > +			is_container_init(current) && !is_global_init(current))
| > +		return ERR_PTR(-EINVAL);
| > +
| >  	retval = security_task_create(clone_flags);
| >  	if (retval)
| >  		goto fork_out;
