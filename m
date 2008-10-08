From: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] User namespaces: fix refcounting
Date: Wed, 08 Oct 2008 18:53:23 +0100
Message-ID: <27300.1223488403@redhat.com>
References: <20081008144246.GA26362@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081008144246.GA26362-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:

> Perhaps the most objectionable part of this to you may be the
> __task_commit_creds().

You're right, that looks pretty yuck.  I'm not sure why you need to do this.

I need to think about it a bit more, but I think you shouldn't be calling
[__task_]commit_creds() on any task that's not your own.

In fact, do you need to call commit_creds() on the new task?  No-one else can
have seen it yet, so RCU can be ignored; and no-one knows about it yet, so
calling proc_id_connector() is unnecessary.

The obvious thing to do would be to make copy_creds() handle the user namespace
copying.


A couple of quick other comments:

> @@ -595,6 +595,7 @@ struct user_struct {
>  	/* Hash table maintenance information */
>  	struct hlist_node uidhash_node;
>  	uid_t uid;
> +	struct user_namespace *user_ns;

Is asking for a circular dependency.  user_namespace must hold a dependency on
its the user_struct pointed to by root_user, but root_user holds a ref on
user_ns.

> +	.creator = &root_user,

Probably means that you should increment the initial usage count on root_user.

David
