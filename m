From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cred_to_ucred: use the creator of the right namespace
Date: Wed, 12 May 2010 02:31:05 -0500
Message-ID: <20100512073105.GA372@us.ibm.com>
References: <20100507220248.GA2075@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100507220248.GA2075-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Hey Eric,
> 
> I ported a subset of your nsfd-v5 patchset to current git (took no
> tweaking at all) and tested the received values of SCM_CREDENTIALS
> ancillary msgs.  You'd asked me if it looked right before and I said
> it did, but in fact there is a little bug, fixed by the below patch.
> 
> thanks,
> -serge
> 
> From c99daef4d7927bf002b493039c86e3de70d7b8b1 Mon Sep 17 00:00:00 2001
> From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Date: Fri, 7 May 2010 17:35:50 -0400
> Subject: [PATCH 1/1] cred_to_ucred: use the creator of the right namespace
> 
> If cred->creator->user_ns == current->user_ns, then it is the
> cred->creator>uid, not the current->user_ns->creator->uid which
> we are interested in.
> 
> Tested with SCM_CREDENTIALS test program.  Without this patch,
> if uid 1001 clones a task with clone(CLONE_NEWUSER), which
> then does setresuid(25,25,25) and sends a SCM_CREDENTIALS msg
> back to the parent, then the parent gets uid 0 and gid overflowgid.
> The reason is that we were returning the uid of the creator of
> the *parent*'s userns.
> 
> With this patch, the uid, gid, and pid are all correct.

Except, while it is *technically* correct, semantically I'm
not sure that's what we want either.

Assuming again that pid 100 owned by uid 1001 clones a task 200 in a new
user_ns, which does setresuid(25,25,25).  Now 200 sends SCM_CREDENTIALS
to 100.  (Again clearly uid 0 was wrong.)  But sending 1001 isn't quite
right either.  In particular, there is a reason why 100 cloned a new
user namespace: so the uid passed back perhaps should just be
overflowuid?

As a concrete example I'll again use the case where a task owned by uid
0 in init_user_ns creates a child in new user_ns, with uid 25 there, and
now the child calls /sbin/reboot.  reboot talks over abstract unix sock to
init in the parent and sends SCM_CREDENTIALS.  With my patch above, it
would now send uid 0, and so init would reboot the host.  That this is
wrong becomes particularly obvious when we consider sending posix caps
along with uid:  any posix caps which the child has should be N/A to
the init_user_ns.

IIUC you coded this originally for use by NFS - would sending
overflowuid make sense for its use as well?

The existing code is still right in the inverse case - if pid 100
sends SCM_CREDENTIALS to pid 200, it sends uid 0 which I think always
makes sense.

-serge
