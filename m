From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH v7 3/7] fs/posix_acl: Document that get_acl respects
	ACL_DONT_CACHE
Date: Mon, 26 Feb 2018 19:36:48 -0800
Message-ID: <CA+55aFz+=zyuAcM3J5PfNNXqErf2x595eP=7tY_-p_L2ryr0rg@mail.gmail.com>
References: <87po4rz4ui.fsf_-_@xmission.com>
	<20180226235302.12708-3-ebiederm@xmission.com>
	<CA+55aFySgJyR6JLcS9HLC9wEpWU1isdyTkchHxZHbJWsh7HFpg@mail.gmail.com>
	<87r2p7rvn5.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87r2p7rvn5.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Feb 26, 2018 at 6:53 PM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>
> So the purpose for having a patch in the first place is that
> 2a3a2a3f3524 ("ovl: don't cache acl on overlay layer")
> which addded ACL_DONT_CACHED did not result in any comment updates
> to get_acl.

I'm not opposed to just updating the comments.

I just think your updates were somewhat misleading.

> Which mean that if you read the comments in get_acl() that you
> don't even think of ACL_DONT_CACHED.

Right. By all means add a comment about ACL_DONT_CACHE disabling the
cache entirely.

But don't _remove_ the other valid way to flush the cache, and don't
make that comment above cmpxchg() be even more confusing than the code
is.

> Does this look better as a comment updating patch?
>
> diff --git a/fs/posix_acl.c b/fs/posix_acl.c
> index 2fd0fde16fe1..5453094b8828 100644
> --- a/fs/posix_acl.c
> +++ b/fs/posix_acl.c
> @@ -98,6 +98,11 @@ struct posix_acl *get_acl(struct inode *inode, int type)
>         struct posix_acl **p;
>         struct posix_acl *acl;
>
> +       /*
> +        * To avoid caching the result of ->get_acl
> +        * set inode->i_acl = inode->i_default_acl = ACL_DONT_CACHE;
> +        */
> +
>         /*
>          * The sentinel is used to detect when another operation like
>          * set_cached_acl() or forget_cached_acl() races with get_acl().
> @@ -126,9 +131,7 @@ struct posix_acl *get_acl(struct inode *inode, int type)
>                 /* fall through */ ;
>
>         /*
> -        * Normally, the ACL returned by ->get_acl will be cached.
> -        * A filesystem can prevent that by calling
> -        * forget_cached_acl(inode, type) in ->get_acl.
> +        * The ACL returned by ->get_acl will be cached.

Why do you hate forget_cached_acl()?

It's perfectly valid too. Don't remove that comment. Maybe reword it
to talk not about "preventing", but about "invalidating the cache".

But the old comment that you remove isn't _wrong_, it's just that the
"preventing" from returning the cached state with forget_cached_acl()
is just a one-time thing.

So forget_cached_acl() exists, and it works, and it does exactly what
its name says. It is a perfectly valid way to prevent the current
entry from being used in the future.

See? I object to you removing that, and trying to make it be like
ACL_DONT_CACHE is the *onyl* way to not cache something.

Because honestly, that's what your comment updates do. They take the
comments about _one_ case, and switch it over to be about the _othger_
case.

But dammit, there are _two_ ways to not cache things.

"Fixing" the comment to talk about one and removing the other isn't a
fix. It's just a stupid change that now has the problem the other way
around!

So fix the comment to really just talk about both things.

First: talk about how to avoid caching entirely (ACL_DONT_CACHE).
Then, talk about how to invalidate the cache once it has been
instantiated (forget_cached_acl()).

Don't do this idiotic "remove the valid comment just because you
happened to care about the _other_ case"


              Linus
