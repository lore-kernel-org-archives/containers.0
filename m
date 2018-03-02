From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v7 5/7] fuse: Simplfiy the posix acl handling logic.
Date: Fri, 02 Mar 2018 15:49:56 -0600
Message-ID: <87fu5i9mgr.fsf@xmission.com>
References: <87po4rz4ui.fsf_-_@xmission.com>
	<20180226235302.12708-5-ebiederm@xmission.com>
	<CAOssrKeWvYpgj4_cgsRBL_kTOHyRS-9_mfO9JHP-JahgqFnfHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAOssrKeWvYpgj4_cgsRBL_kTOHyRS-9_mfO9JHP-JahgqFnfHQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Miklos Szeredi's message of "Tue, 27 Feb 2018 10:00:25 +0100")
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> On Tue, Feb 27, 2018 at 12:53 AM, Eric W. Biederman
> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>> Rename the fuse connection flag posix_acl to cached_posix_acl as that
>> is what it actually means.  That fuse will cache and operate on the
>> cached value of the posix acl.
>>
>> When fc->cached_posix_acl is not set, set ACL_DONT_CACHE on the inode
>> so that get_acl and friends won't cache the acl values even if they
>> are called.
>>
>> Replace forget_all_cached_acls with fuse_forget_cached_acls.  This
>> wrapper only takes effect when cached_posix_acl is true to prevent
>> losing the nocache or noxattr status in when posix acls are not
>> cached.
>
> Shouldn't forget_cached_acl() be taught about ACL_DONT_CACHE?  I think
> it makes sense to generally not clear ACL_DONT_CACHE, since it's not
> an actual acl value that needs forgetting.

After stopping to make certain I understand the issues, I don't think
it makes sense to teach forget_cached_acl about ACL_DONT_CACHE.

If you are fogetting a cached attribute ACL_DONT_CACHE simply doesn't
make sense.

Further it makes sense to cache a negative result for fuse when
!fc->no_getxattr.  Even if you would ordinarily not cache posix acls.

So I think the better plan is to teach the posix acl code how to not
cache results on a case by case basis.  As I did in my rfc patch I
posted a little earlier today.  That works with forget_cached_acl and it
supports local reasoning.  Further while the performance might not be as
good as ACL_DONT_CACHE I don't think that matters as always going to the
fuse server to get acls is almost certainly going to dominate the acl
costs.

Eric
