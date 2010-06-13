From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] cred_to_ucred: use the creator of the right namespace
Date: Sun, 13 Jun 2010 05:50:15 -0700
Message-ID: <m1aaqzjdvc.fsf@fess.ebiederm.org>
References: <20100507220248.GA2075@us.ibm.com>
	<20100512073105.GA372@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100512073105.GA372-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Wed\, 12 May 2010 02\:31\:05 -0500")
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:

> Except, while it is *technically* correct, semantically I'm
> not sure that's what we want either.
>
> Assuming again that pid 100 owned by uid 1001 clones a task 200 in a new
> user_ns, which does setresuid(25,25,25).  Now 200 sends SCM_CREDENTIALS
> to 100.  (Again clearly uid 0 was wrong.)  But sending 1001 isn't quite
> right either.  In particular, there is a reason why 100 cloned a new
> user namespace: so the uid passed back perhaps should just be
> overflowuid?
>
> As a concrete example I'll again use the case where a task owned by uid
> 0 in init_user_ns creates a child in new user_ns, with uid 25 there, and
> now the child calls /sbin/reboot.  reboot talks over abstract unix sock to
> init in the parent and sends SCM_CREDENTIALS.  With my patch above, it
> would now send uid 0, and so init would reboot the host.  That this is
> wrong becomes particularly obvious when we consider sending posix caps
> along with uid:  any posix caps which the child has should be N/A to
> the init_user_ns.

I am conflicted I think there is real justification for showing uids
in a child uid namespace as the creator of the uid namespace.  At the
same time I very much agree that it is safer and less dangerous from
an existing security perspective if we don't map the uids to the
creator of the namespace so I have dropped that feature for now.
Thank you for spotting that.

I have extracted the heart of the code and added two functions
to user_namespace.c as that seems to make the most sense for the
moment.  I will send this all to netdev shortly.

> IIUC you coded this originally for use by NFS - would sending
> overflowuid make sense for its use as well?

The first time I thought of mapping I was indeed thinking of NFS.
Either overflowuid or whatever NFS does for the nobody user that
it uses for root squash.

> The existing code is still right in the inverse case - if pid 100
> sends SCM_CREDENTIALS to pid 200, it sends uid 0 which I think always
> makes sense.

Agreed.

Below is what I am currently working with, the essence of my cred_to_ucred
patch, but in a form the code can be used elsewhere.  I have completely
removed the section for children as we that appears dangerous for the moment.

Eric


uid_t user_ns_map_uid(struct user_namespace *to, const struct cred *cred, uid_t uid)
{
	struct user_namespace *tmp;

	if (likely(to == cred->user->user_ns))
		return uid;


	/* Is cred->user the creator of the target user_ns
	 * or the creator of one of it's parents?
	 */
	for ( tmp = to; tmp != &init_user_ns;
	      tmp = tmp->creator->user_ns ) {
		if (cred->user == tmp->creator) {
			return (uid_t)0;
		}
	}

	/* No useful relationship so no mapping */
	return overflowuid;
}

gid_t user_ns_map_gid(struct user_namespace *to, const struct cred *cred, gid_t gid)
{
	struct user_namespace *tmp;

	if (likely(to == cred->user->user_ns))
		return gid;

	/* Is cred->user the creator of the target user_ns
	 * or the creator of one of it's parents?
	 */
	for ( tmp = to; tmp != &init_user_ns;
	      tmp = tmp->creator->user_ns ) {
		if (cred->user == tmp->creator) {
			return (gid_t)0;
		}
	}

	/* No useful relationship so no mapping */
	return overflowgid;
}
