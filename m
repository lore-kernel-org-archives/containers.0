From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 4/6] cr: checkpoint and restore task credentials
Date: Wed, 20 May 2009 11:35:44 -0400
Message-ID: <4A142350.1060308@cs.columbia.edu>
References: <20090519014446.GA28277@us.ibm.com>
	<20090519014538.GD28312@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090519014538.GD28312-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


Serge -

The 'creator' makes the 'struct user' recursive because to save
an object you need to first save its creator etc. However the
implementation may not call checkpoint_obj() recursively, if
the depth isn't bound a-priory. You probably need to convert
checkpoint_write_user() to do an iterative (loop) implementation
of the recursion...

Oren.


Serge E. Hallyn wrote:
> This patch adds the checkpointing and restart of credentials
> (uids, gids, and capabilities) to Oren's c/r patchset (on top
> of v14).  It goes to great pains to re-use (and define when
> needed) common helpers, in order to make sure that as security
> code is modified, the cr code will be updated.  Some of the
> helpers should still be moved (i.e. _creds() functions should
> be in kernel/cred.c).
> 
> When building the credentials for the restarted process, I
> 1. create a new struct cred as a copy of the running task's
> cred (using prepare_cred())
> 2. always authorize any changes to the new struct cred
> based on the permissions of current_cred() (not the current
> transient state of the new cred).
> 
> While this may mean that certain transient_cred1->transient_cred2
> states are allowed which otherwise wouldn't be allowed, the
> fact remains that current_cred() is allowed to transition to
> transient_cred2.
> 
> The reconstructed creds are applied to the task at the very
> end of the sys_restart call.  This ensures that any objects which
> need to be re-created (file, socket, etc) are re-created using
> the creds of the task calling sys_restart - preventing an unpriv
> user from creating a privileged object, and ensuring that a
> root task can restart a process which had started out privileged,
> created some privileged objects, then dropped its privilege.
> 
> With these patches, the root user can restart checkpoint images
> (created by either hallyn or root) of user hallyn's tasks,
> resulting in a program owned by hallyn.
> 
> Plenty of bugs to be found, no doubt.
> 
> Changelog:
> 	May 18: fix more refcounting: if (userns 5, uid 0) had
> 		no active tasks or child user_namespaces, then
> 		it shouldn't exist at restart or it, its namespace,
> 		and its whole chain of creators will be leaked.
> 	May 14: fix some refcounting:
> 		1. a new user_ns needs a ref to remain pinned
> 		   by its root user
> 		2. current_user_ns needs an extra ref bc objhash
> 		   drops two on restart
> 		3. cred needs a ref for the real credentials bc
> 		   commit_creds eats one ref.
> 	May 13: folded in fix to userns refcounting.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

[...]
