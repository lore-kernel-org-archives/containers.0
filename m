From: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v9 0/4] fuse: mounts from non-init user namespaces
Date: Tue, 20 Mar 2018 17:25:06 +0100
Message-ID: <CAOssrKebhX-nm06RAwep8HUUV4QpsAa=ZOgxdRyP=WF9p-=4Tw__0.0259992249951324$1521562996$gmane$org@mail.gmail.com>
References: <cover.1512741134.git.dongsu@kinvolk.io>
	<878tbmf5vl.fsf@xmission.com>
	<87po4rz4ui.fsf_-_@xmission.com> <87r2p287i8.fsf_-_@xmission.com>
	<87ina6ntx0.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87ina6ntx0.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Mar 8, 2018 at 10:23 PM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>
> This patchset builds on the work by Donsu Park and Seth Forshee and is
> reduced to the set of patches that just affect fuse.  The non-fuse
> vfs patches are far enough along we can ignore them except possibly for the
> question of when does FS_USERNS_MOUNT get set in fuse_fs_type.
>
> Fuse with a block device has been left as an exercise for a later time.
>
> Since v5 I changed the core of this patchset around as the previous
> patches were showing signs of bitrot.  Some important explanations were
> missing, some important functionality was missing, and xattr handling
> was completely absent.
>
> Since v6 I have:
> - Removed the failure case from fuse_get_req_nofail_nopages that I
>   added.
> - Updated fuse to always to use posix_acl_access_xattr_handler, and
>   posix_acl_default_xattr_handler, by teaching fuse to set
>   ACL_DONT_CACHE when FUSE_POSIX_ACL is not set.
>
> Since v7 I have:
> - Rethought and reworked how I am unifying the cached and the non-cached
>   posix acl case so the code is cleaner and simpler.
>   - I have dropped enhancements to caching negative acls when
>     fc->no_getxattr is set.
>   - Removed the need to wrap forget_all_cached_acls in fuse.
> - Reorder the patches so the posix acl work comes first
>
> Since v8 I have:
> - Dropped and postponed the unification of the uncached and the cached
>   posix acls case.  The code is not hard but tricky enough it needs
>   to be considered on it's own on it's own merits.
>
> Miklos can you take a look and see what you think?
>
> Miklos if you could pick these up I would appreciate it.  If not I can
> merge these through the userns tree.

Thank you Eric for moving this along.  Patches pushed to:

  git://git.kernel.org/pub/scm/linux/kernel/git/mszeredi/fuse.git for-next

I did just one modification to "fuse: Fail all requests with invalid
uids or gids": instead of zeroing out the context for the nofail case,
continue to use the "_munged" variants. I don't think this hurts and
is better for backward compatibility (I guess the only relevant use
would be for debugging output, but we don't want to regress even for
that if not necessary).

Thanks,
Miklos
