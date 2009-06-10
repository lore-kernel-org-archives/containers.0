From: Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
Subject: Re: [PATCH 09/10] cr: restore LSM credentials
Date: Wed, 10 Jun 2009 09:54:02 -0400
Message-ID: <1244642042.20265.143.camel@localhost.localdomain>
References: <20090610014412.GA5628@us.ibm.com>
	<20090610014637.GH5658@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090610014637.GH5658-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, SELinux <selinux-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Andrew Morgan <morgan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2009-06-09 at 20:46 -0500, Serge E. Hallyn wrote:
> Checkpoint and restore task and ipc struct ->security info.
> (files->f_security yet to be done).
> 
> LSM contexts (a string representation of obj->security) are
> checkpointed as shared objects before any object referencing
> it.  The object's checkpoint header struct has a reference
> (h->sec_ref) to the shared object.  A NULL ->security is indicated
> by h->sec_ref = -1.
> 
> At checkpoint time, for each obj->security to be checkpointed,
> the LSM will be asked (once) to convert it to a string, in memory
> which the checkpoint subsystem will kfree.  At restart time,
> the LSM will first return some meaningful token given the
> checkpointed string.  That token will be passed to per-object-type
> restore functions (task_restore_context(), shm_restore_security(),
> etc) where the LSM can determine based on the object type, the
> caller, and the token, whether to allow the object restore, and
> what value to actually assign to ->security.  In smack, the
> token is the actual imported label.  In SELinux, it is a temporary
> pointer to the sid which the checkpointed context referred to.

Possibly I misunderstand, but it appears that you have a single
security_context_to_str() hook that tries to take an arbitrary
->security pointer for any object type.  I don't believe that is safe,
as each object type may have its own security structure.

There are already LSM hooks to obtain secids for objects (task, ipc,
inode, sock), and to convert between secid and secctx strings for use by
the audit subsystem and networking subsystem.  Why can't you just use
those hooks for getting the secids and then converting them to secctx
strings later?

> In smack, the checkpointed labels are used for both tasks and
> ipc objects so long as the task calling sys_restart() has
> CAP_MAC_ADMIN.  Otherwise, if the checkpointed label is different
> from current_security(), -EPERM is returned.
> 
> The basics of SELinux support are there (enough to demonstrate working
> c/r with SELinux enforcing), but there will need to be new object
> permissions for restore, so the precise nature of those needs to be
> discussed.  For instance, do we want to define process:restore
> and ipc_msg_msg:restore, in which case
>         allow root_t user_t:process restore
> would mean that root_t may restart a task and label it user_t?

I think so, yes.

> Since we are potentially skipping several allowed domain transitions
> (resulting in an illegal short-cut domain transition or type creation),
> I have a fear that the only sane way to proceed would be to have
> one all-powerful domain, checkpoint_restore_t, which can effectively
> transition to any domain it wants to by (ab)using the checkpoint
> image.
> 
> Or, perhaps we can define intermediate domains...  So if we want
> user_t to be able to restart a server of type X_t, then we create
> a X_restore_t type, allow user_t to transition to it using a
> program which does sys_restart(), which in turn may transition to
> X_t?

Different domains will make sense for different use cases.  As long as
the mechanism doesn't prevent us from crafting more limited privilege
restore domains in policy, it shouldn't be a problem.

-- 
Stephen Smalley
National Security Agency
