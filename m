From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC PATCH 0/4 v2] Inotify limits per usernamespace
Date: Wed, 06 Jul 2016 11:47:33 -0500
Message-ID: <877fcyhfx6.fsf@x220.int.ebiederm.org>
References: <1467207425-22072-1-git-send-email-kernel@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1467207425-22072-1-git-send-email-kernel-6AxghH7DbtA@public.gmane.org> (Nikolay
	Borisov's message of "Wed, 29 Jun 2016 16:37:01 +0300")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Cc: jack-AlSwsSmVLrQ@public.gmane.org, avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, operations-/eCPMmvKun9pLGFMi4vTTA@public.gmane.org, gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org> writes:

> So this is the 2nd incarnation of the inotify-limits per namespace, 
> following the lenghty discussions with Eric Biederman. The core of 
> the series lies in patch 3, as this contains most of the code to 
> implement the new semantics. The major difference is now that 
> inotify limits are going to be accounted per-user/per-namespace. 
>
> Patch 1 adds a __HASHTABLE_INITIALIZER, much in the same way as 
> other kernel constructs have, so that one can use them directly 
> into structure definitions. It's a self-contained patch 
>
> Patch 2 is unchanged from the previous submissions and just 
> renames some defines in various networking files, implementing
> their own hashtable as this creates certain warnings due to 
> hashtable.h inclusion in linux/user_namespace.h. This has already
> been acked-by David Miller. 
>
> Patch 3 is the core, it implements all the necessary changes
> to allow. More information about the implementation in the patch
> changelog. This has been completely changed than in the first
> submission to cope with the requirements that emerged in 
> discussion with Eric Biederman.
>
> Patch 4 is plain conversion, to the new interface inotify code
> structure.
>
> The series has received moderate testing in a KVM guest, using
> the stress-ng to create multiple inotify instances and test
> whether the locking is correct which seems to be the case. I've
> tested with 2/3 level hierarchies of namespaces.

Thanks for getting this out.  I am just starting to look at these
changes. I have been deep in another set of changes and haven't had the
brain cells to start reviewing this before now.

Eric


> Nikolay Borisov (4):
>   hashtable: Add __HASHTABLE_INITIALIZER
>   misc: Rename the HASH_SIZE macro
>   userns/inotify: Initial implementation of inotify per-userns
>   inotify: Convert to using new userns infrastructure
>
>  fs/logfs/dir.c                           |   6 +-
>  fs/notify/inotify/inotify.h              |  25 ++++
>  fs/notify/inotify/inotify_fsnotify.c     |  16 ++-
>  fs/notify/inotify/inotify_user.c         | 240 +++++++++++++++++++++++++++++--
>  include/linux/fsnotify_backend.h         |   3 +
>  include/linux/hashtable.h                |   3 +
>  include/linux/sched.h                    |   4 -
>  include/linux/user_namespace.h           |  10 ++
>  kernel/user.c                            |   5 +
>  kernel/user_namespace.c                  |  22 ++-
>  net/ipv6/ip6_gre.c                       |   8 +-
>  net/ipv6/ip6_tunnel.c                    |  10 +-
>  net/ipv6/ip6_vti.c                       |  10 +-
>  net/ipv6/sit.c                           |  10 +-
>  security/keys/encrypted-keys/encrypted.c |  32 ++---
>  15 files changed, 345 insertions(+), 59 deletions(-)
