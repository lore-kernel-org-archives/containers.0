From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC PATCH 0/4 v3] Inotify limits per usernamespace
Date: Tue, 19 Jul 2016 19:41:07 -0500
Message-ID: <87vb01dtuk.fsf@x220.int.ebiederm.org>
References: <1468412053-30130-1-git-send-email-kernel@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1468412053-30130-1-git-send-email-kernel-6AxghH7DbtA@public.gmane.org> (Nikolay
	Borisov's message of "Wed, 13 Jul 2016 15:14:09 +0300")
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, operations-/eCPMmvKun9pLGFMi4vTTA@public.gmane.org
List-Id: containers.vger.kernel.org

Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org> writes:

> Hello Eric, 
>
> Another day, another version...
>
> So this is version 3 of the patches initially posted at [1]. 
> Version 2 can be fount at [2]
>
> So I reworked the way the state for namespaces are created and
> the code is indeed a lot cleaner and easier to understand. I've 
> also moved from using uid and instead always work with kuids. 
> Finally I reworked the hashtable to be a global one and indexed by 
> the kuid value. With this I believe I have adressed all your points 
> in your previous review. 
>
> I still haven't tackled the issue with the semantics of the sysctls. 
> But judging from your last reply about being content with just setting
> the limit at the top-level I believe the way to fix this would be 
> make a custom proc handler that writes to the variable in the 
> current userns. Opinions?

So first let me say thank you for this.  It was a very good starting
point for my thinking on other sysctls.

I have been proceeding on another track I will post in just a minute
that addresses some different sysctls.  Those I know how to pick a
reasonable sanity check limit on a per user system wide basis and not a
per user basis so I don't have any per user limits.   Otherwise it is
pretty much the same case as here.

Please take a look at those patches on how to address creating per user
namespace sysctls.

After those patches settle I will be willing to look at these more.

Eric



> [1] http://thread.gmane.org/gmane.linux.kernel/2232000
> [2] https://lists.linuxfoundation.org/pipermail/containers/2016-June/037019.html
>
> Nikolay Borisov (4):
>   hashtable: Add __HASHTABLE_INITIALIZER
>   misc: Rename the HASH_SIZE macro
>   userns/inotify: Initial implementation of inotify per-userns
>   inotify: Convert to using new userns infrastructure
>
>  fs/logfs/dir.c                           |   6 +-
>  fs/notify/inotify/inotify.h              |   2 +
>  fs/notify/inotify/inotify_fsnotify.c     |  14 +++-
>  fs/notify/inotify/inotify_user.c         | 136 +++++++++++++++++++++++++++----
>  include/linux/fsnotify_backend.h         |   4 +-
>  include/linux/hashtable.h                |   3 +
>  include/linux/sched.h                    |   4 -
>  include/linux/user_namespace.h           |  45 ++++++++++
>  kernel/user_namespace.c                  | 106 +++++++++++++++++++++++-
>  net/ipv6/ip6_gre.c                       |   8 +-
>  net/ipv6/ip6_tunnel.c                    |  10 +--
>  net/ipv6/ip6_vti.c                       |  10 +--
>  net/ipv6/sit.c                           |  10 +--
>  security/keys/encrypted-keys/encrypted.c |  32 ++++----
>  14 files changed, 327 insertions(+), 63 deletions(-)
