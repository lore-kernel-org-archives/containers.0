From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH v7 3/7] fs/posix_acl: Document that get_acl respects
	ACL_DONT_CACHE
Date: Mon, 26 Feb 2018 17:13:59 -0800
Message-ID: <CA+55aFySgJyR6JLcS9HLC9wEpWU1isdyTkchHxZHbJWsh7HFpg@mail.gmail.com>
References: <87po4rz4ui.fsf_-_@xmission.com>
	<20180226235302.12708-3-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20180226235302.12708-3-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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

On Mon, Feb 26, 2018 at 3:52 PM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>
> Additionaly update the comment above the call to get_acl itself and
> remove the wrong information that an implementation of get_acl can
> prevent caching by calling forget_cached_acl.

This part is just confusing.

First off, that comment is correct: a filesystem _can_ prevent the
returning of cached data by just calling forget_cached_acl().

Note that there are two different cases: saying that you _never_ want
to cache things (ACL_DONT_CACHE) and saying that there _currently_ is
no cached data (ACL_NOT_CACHED).

forget_cached_acl() just removes the current cache.

You're just replacing one case of "no cached" information with the other.

Just explain the two cases, don't try to muddy the waters even more..

PLUS you are just confusing things entirely. That whole new comment of yours:

+        * ACL_DONT_CACHE is treated as another task updating the acl and
+        * remains set.

is just garbage.

The code is very clear - it will only replace a ACL_NOT_CACHED entry.
The code is clear:

        if (cmpxchg(p, ACL_NOT_CACHED, sentinel) != ACL_NOT_CACHED)
                /* fall through */ ;

this is basically just an atomic "if *p == ACL_NOT_CACHED then replace
it with 'sentinel'".

Your comment does not add any clarity at all, and only confuses
things. It has nothing to do with "treated as another task updating
the acl".

The fact is, ACL_DONT_CACHE is treated as if the cache is simply
already filled - it's just filled with "no cache".

So the only thing special is ACL_NOT_CACHED, which is the only thing
we will try to _replace_.

So NAK on this patch entirely. It's just adding confusion, not adding
clarifications.

                Linus
