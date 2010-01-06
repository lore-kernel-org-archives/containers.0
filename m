From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] RFC: taking a crack at targeted capabilities
Date: Wed, 6 Jan 2010 11:30:56 -0600
Message-ID: <20100106173056.GC15784@us.ibm.com>
References: <20100106062809.GA17064@us.ibm.com>
	<m13a2j2q7c.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m13a2j2q7c.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> 
> > So i was thinking about how to safely but incrementally introduce
> > targeted capabilities - which we decided was a prereq to making VFS
> > handle user namespaces - and the following seemed doable.  My main
> > motivations were (in order):
> >
> >         1. don't make any unconverted capable() checks unsafe
> >         2. minimize performance impact on non-container case
> >         3. minimize performance impact on containers
> >
> > This patch adds a per-task inherited securebit SECURE_CONTAINERIZED.
> > The capable() call is considered unconverted.  Therefore any call
> > to capable() by a task which is SECURE_CONTAINERIZED returns -EPERM.
> >
> > A new syscall capable_to() is the container-aware version of capable().
> >
> > int capable_to(int cap, enum ns_type type, void *src, void *dest);
> >
> > meaning a task which owns 'src' wants 'cap' access to an object
> > in namespace 'dest'.
> >
> > In a case like setting hostname, there is no way to try to set the
> > hostname in another container, so the check is converted in this patch to
> >
> >         capable_to(CAP_SYS_ADMIN, NS_TYPE_NONE, NULL, NULL);
> >
> > capable_to() will act like the old capable(), meaning grant permission
> > if CAP_SYS_ADMIN is in pE.
> >
> > The check for sending a signal depends on a user namespace, so I
> > converted an instance to
> >
> >         capable_to(CAP_KILL, NS_TYPE_USERNS, current_userns(),
> >                         target->user_ns);
> >
> > The NS_TYPE_USERNS check checks whether target->userns is the same
> > as or a descendent of target->user_ns.  If not, then -EPERM is
> > returned even if the task has CAP_KILL.
> >
> > To test, compile a program (call it 'containerize_cap') that does
> >
> > 	prctl(PR_SET_SECUREBITS, 1 << 6 | 1 << 7);
> > 	execl("/bin/bash", "bash", NULL);
> >
> > Run that in a container (say, do 'ns_exec -cmpuU /bin/bash' and
> > run screen there).  Notice you can set hostname, but you can't
> > for instance read user's directories which don't have world write
> > perms, and can't mount.  You can also kill processes which are
> > either in your own or a child user namespace, but not in a parent
> > user namespace.
> >
> > Purely for discussion.  Comments?
> 
> This looks like a good start of discussion, and you have
> choosen two good examples.
> 
> I believe your check for ancestor user namespaces is actually
> too liberal, I can't quite follow it but it looks like any
> process in an ancestor user namespace has all rights over
> a child, which would let fred kill joe's processes..

But that's only if fred has CAP_KILL in a user namespace which is
ancestor to joe's process.  Only fred's processes in a child
userns should have CAP_KILL.

> I think we can use a much simpler definition, based on the core
> concept that we are making the capabilities namespace relative,
> thus we need to pass in which namespace we want the capability for.
> 
> 	/* Put in kernel/capability.c */
> 	int capable(int cap)
> 	{
> 	        return capable_to(&init_user_ns, cap);
> 	}
> 	
> 	int capable_to(struct user_namespace *ns, int cap)
> 	{
> 	        if (unlikely(!cap_valid(cap))) {
> 			printk(KERN_CRIT "capable() called with invalid cap=%u\n", cap);
> 			BUG();
> 	        }
> 	        
> 	        if (security_capable(ns, cap) == 0) {
> 	        	current->flags |= PF_SUPERPRIV;
> 	                return 1;
> 	        }
> 	        return 0;
> 	}
> 	
> 	/* Put in security/common_cap.c */
> 	int cap_capable(struct task_struct *tsk, const cred *cred,
> 	    		struct user_namespace *targ_ns, int targ_cap, int audit)
> 	{
> 	        struct user_namespace *curr_ns = cred->user->user_ns
> 	
> 	        for (;;) {
> 	        	/* Do we have the necessary capabilities? */
> 		        if (targ_ns == curr_ns)
> 				return cap_raised(cred->cap_effective, cap) ? 0 : -EPERM;
> 	
> 			/* The creator of the user namespace has all caps. */
> 			if (targ_ns->creator == cred->user)
> 				return 0;
> 	
> 			/* Have we tried all of the parent namespaces? */
> 			if (targ_ns == &init_user_ns)
> 				return -EPERM;
> 	
> 			/* If you have the capability in a parent user ns you have it
> 	                 * in the over all children user namespaces as well, so see
> 	                 * if this process has the capability in the parent user
> 	                 * namespace.
> 	                 */
> 			targ_ns = targ_ns->creator->user_ns;
> 		}
> 	
> 	        /* We never get here */
> 		return -EPERM;                
> 	}
> 
> 
> The example in check_kill_permission simply becomes:
> 	capable_to(tcred->user->user_ns, CAP_KILL);
> 
> While the check in hostname remains unchanged until we convert teach
> the userns to unshare without privilege.  At which point the check should
> become.
> 	capable_to(utsname()->creator->user_ns, CAP_SYS_ADMIN);
> 
> Which matters because we can set the hostname through /proc/sys....

Oh, right.  However, utsname doesn't have a creator, and we won't always
want to use user namespaces to authorize.  For instance, for CAP_NET_ADMIN
we'll want to compare the net_ns.  That's why i had the switch inside
capable_to() based on ns type.

-serge
