From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v7 3/7] fs/posix_acl: Document that get_acl respects
	ACL_DONT_CACHE
Date: Mon, 26 Feb 2018 21:14:52 -0600
Message-ID: <87tvu3qg2b.fsf@xmission.com>
References: <87po4rz4ui.fsf_-_@xmission.com>
	<20180226235302.12708-3-ebiederm@xmission.com>
	<CA+55aFySgJyR6JLcS9HLC9wEpWU1isdyTkchHxZHbJWsh7HFpg@mail.gmail.com>
	<87r2p7rvn5.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87r2p7rvn5.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Mon, 26 Feb 2018 20:53:02 -0600")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman) writes:

2> So the purpose for having a patch in the first place is that
> 2a3a2a3f3524 ("ovl: don't cache acl on overlay layer")
> which addded ACL_DONT_CACHED did not result in any comment updates
> to get_acl.
>
> Which mean that if you read the comments in get_acl() that you
> don't even think of ACL_DONT_CACHED.
>
> Which means that this comment:
> 	/*
> 	 * If the ACL isn't being read yet, set our sentinel.  Otherwise, the
> 	 * current value of the ACL will not be ACL_NOT_CACHED and so our own
> 	 * sentinel will not be set; another task will update the cache.  We
> 	 * could wait for that other task to complete its job, but it's easier
> 	 * to just call ->get_acl to fetch the ACL ourself.  (This is going to
> 	 * be an unlikely race.)
> 	 */
>
> Which presumes the only reason the acl could be anything other
> ACL_NOT_CACHED is because get_acl() is already being called upon it in
> another task.
>
> I wanted something to mention ACL_DONT_CACHED so someone would at least
> think about that case if they ever step up to modify the code.
>
> The code is perfectly clear, the comment is not.   That scares me.
>
> And I had to read the code about a dozen times before I realized the
> ACL_DONT_CACHED case even exists.   Not useful when I am need to use
> that to preserve historical fuse semantics.
>
> So something is missing here even if my wording does not improve things.
>
>
>
> Then we get this comment:
> 	/*
> 	 * Normally, the ACL returned by ->get_acl will be cached.
> 	 * A filesystem can prevent that by calling
> 	 * forget_cached_acl(inode, type) in ->get_acl.
> 	 */
>
> Which was added in b8a7a3a66747 ("posix_acl: Inode acl caching fixes")
> That comment is and always has been rubbish.
>
> I don't have a clue what it is trying to say but it is not something
> a person can use to write filesystem code with.
>
>
> Truths:
> - forget_cached_acl(inode, type) can be used to invalidate the acl
>   cache.
>
> - Calling forget_cached_acl from within the filesystems ->get_acl
>   method won't prevent a cached value from being returend because
>   ->get_acl will be set.
>
> - Calling forget_cached_acl from within the filesystems ->get_acl
>   method won't prevent a returned value from being cached
>   because it the caching happens after ->get_acl returns.

Sigh.  Yes it will because we set the special sentinel value,
and forget_cached_acl will replace the sentinel value with
ACL_NOT_CACHED.

It is a terribly brittle and racy thing to do, and it probably won't
work to say cache this acl but not this one on a case by case bases
in ->get_acl.

As such I believe that usage of forget_cached_acl should be subsumed by
using ACL_NOT_CACHED.  If not we should really come up with a different
helper function name to call from ->get_acl.  Preferably one that does
"cmpxchng(p, sentinel, ACL_NOT_CACHED)" so that we remove the races.


> - Setting inode->i_acl = ACL_DONT_CACHE is the only way to prevent
>   a value from ->get_acl from being cached.
>   
>
> In summary I only care about two things.
> 1) ACL_NOT_CACHED being mentioned somewhere in get_acl so people looking
>    at the code, and people updating the code will have a hint that they
>    need to consider that case.
>
> 2) That misleading completely bogus comment being removed/fixed.
>
>
> And yes I agree the code is clear.  The comments are not.
>
>
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
>          *
>          * If the filesystem doesn't have a get_acl() function at all, we'll
>          * just create the negative cache entry.
>
> Eric
