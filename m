From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v8 1/6] fs/posix_acl: Update the comments and support
	lightweight cache skipping
Date: Mon, 05 Mar 2018 07:53:46 -0600
Message-ID: <87lgf639xx.fsf@xmission.com>
References: <87r2p287i8.fsf_-_@xmission.com>
	<20180302215919.27207-1-ebiederm@xmission.com>
	<CAOssrKf0cuxx1YLiwFJHSnzMOOoejjWWibs98Mb5KSXVSSXfOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAOssrKf0cuxx1YLiwFJHSnzMOOoejjWWibs98Mb5KSXVSSXfOg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Miklos Szeredi's message of "Mon, 5 Mar 2018 10:53:41 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> On Fri, Mar 2, 2018 at 10:59 PM, Eric W. Biederman
> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>> The code has been missing a way for a ->get_acl method to not cache
>> a return value without risking invalidating a cached value
>> that was set while get_acl() was returning.
>>
>> Add that support by implementing to_uncachable_acl, to_cachable_acl,
>> is_uncacheable_acl, and dealing with uncachable acls in get_acl().
>
> I don't like the pointer magic here.  Can't the uncachable bit just be
> added to struct posix_acl?
>
>  AFAICS that can be done even without increasing the size of that
> struct (e.g. by unioning it with the rcu_head).

Except that would:
- add a possible cache line miss.
- make it unusable for overlayfs.

I am after very light-weight semantics that say don't cache this return
value but don't have any effects elsewhere.

We are already playing pointer magic games in this code.  This just uses
those games for the last piece of information to keep the logic clean.

I see two possible implementation alternatives:
- Make get_acl return a struct that returns the acl and cachability flag
- Add a helper that does"cmpxchg(p, sentinel, ACL_NOT_CACHED)".
  Such a heleper function seems like a waste, it does side effect magic
  which is never particularly pleasant, and it is more code to execute
  in practice.  Though honestly it is my second choice.

  void dont_cache_my_return_acl(struct inode *inode, int type)
  {
    	/* Valid only inside ->get_acl implementations */
        struct posix_acl **p = get_acl_type(inode, type);
        struct posix_acl *sentinel = uncached_acl_sentinel(current);
        cmpxchg(p, sentinel, ACL_NOT_CACHED);
  }
  EXPORT_SYMBOL(dont_cache_my_return_acl);

  It is just a few instructions more so I guess it isn't that bad.
  Especially for something that is not a common case.

Do you think you could live with dont_cache_my_return_acl?

Otherwise I think I will respin this patch set without the acl
unification.  There is plenty of evidence what it will look like
now.  We can deal with the rest of the patches.  Then we can come back
to exactly what acl unification in fuse should look like.

Eric
