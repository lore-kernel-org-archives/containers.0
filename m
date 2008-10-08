From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] User namespaces: fix refcounting
Date: Wed, 8 Oct 2008 15:02:15 -0500
Message-ID: <20081008200215.GA4070@us.ibm.com>
References: <20081008144246.GA26362@us.ibm.com> <27300.1223488403@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <27300.1223488403-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting David Howells (dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > Perhaps the most objectionable part of this to you may be the
> > __task_commit_creds().
> 
> You're right, that looks pretty yuck.  I'm not sure why you need to do this.
> 
> I need to think about it a bit more, but I think you shouldn't be calling
> [__task_]commit_creds() on any task that's not your own.
> 
> In fact, do you need to call commit_creds() on the new task?  No-one else can
> have seen it yet, so RCU can be ignored; and no-one knows about it yet, so
> calling proc_id_connector() is unnecessary.
> 
> The obvious thing to do would be to make copy_creds() handle the user namespace
> copying.

That's a good idea.  Now that won't handle unshare(), but then I'm
tempted to do like CLONE_NEWPID and return -EINVAL on unshare() anyway.

> A couple of quick other comments:
> 
> > @@ -595,6 +595,7 @@ struct user_struct {
> >  	/* Hash table maintenance information */
> >  	struct hlist_node uidhash_node;
> >  	uid_t uid;
> > +	struct user_namespace *user_ns;
> 
> Is asking for a circular dependency.  user_namespace must hold a dependency on
> its the user_struct pointed to by root_user, but root_user holds a ref on
> user_ns.

Thanks it does seem i got confused somewhere.  In fact there is no need
for user_ns to point to its root_user at all.  The root_user will be
pinned by the task,and if that task is the only one in the user_ns and
it does does setuid(500), then there is no reason not to keep root_user
from being freed.

That way we stick with the simple refcounting rules:

        The task pins the user struct.
	The user struct pins its user namespace.
	The user namespace pins the struct user which created it.

> > +	.creator = &root_user,
> 
> Probably means that you should increment the initial usage count on root_user.

Not given the above since the init_user_ns.root_user is going away.

And yet...  Yes, it should be 2, one for the init_user_ns.creator link
and one for the init task pointing to it.

Thanks very much, David!  I'll respin.

-serge
