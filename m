From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCHSET] cgroup: cftype based file interface
Date: Mon, 19 Mar 2012 14:22:44 +0400
Message-ID: <4F6708F4.4000604__47883.1567256295$1332152663$gmane$org@parallels.com>
References: <1331940963-15756-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1331940963-15756-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 03/17/2012 03:35 AM, Tejun Heo wrote:
> Hello, guys.
>
> This patch replaces cgroup file interface with cftype based one which
> allows dynamic additions and removals of cftype arrays whether the
> target subsystem is attached or not.

Great

> This can be used to make subsys
> rebinding via remount work properly but I intentionally avoided doing
> that at the moment.
>
> This makes cgroup population simpler for controllers and will be used
> to allow controllers to be more dynamic.  e.g. blkio subsys has
> sub-policies which may come and go while blkio subsys is attached and
> it currently uses fixed set of files which stays blank if not in use.
> This will also be useful for implementing unified hierarchy.
>
> This patchset contains the following patches.
>
>   0001-cgroup-move-cgroup_clear_directory-call-out-of-cgrou.patch
>   0002-cgroup-build-list-of-all-cgroups-under-a-given-cgrou.patch
>   0003-cgroup-implement-cgroup_add_cftypes-and-friends.patch
>   0004-cgroup-merge-cft_release_agent-cftype-array-into-the.patch
>   0005-cgroup-convert-all-non-memcg-controllers-to-the-new-.patch
>   0006-cgroup-convert-memcg-controller-to-the-new-cftype-in.patch
>   0007-cgroup-remove-cgroup_add_file-s.patch
>   0008-cgroup-relocate-__d_cgrp-and-__d_cft.patch
>   0009-cgroup-introduce-struct-cfent.patch
>   0010-cgroup-implement-cgroup_rm_cftypes.patch
>
> and is on top of
>
>    cgroup/for-3.4 3ce3230a0cff484e5130153f244d4fb8a56b3a8b
> + [1] cgroup: deprecate remount option changes mount option
>
> and is also available in the following git branch.
>
>   git://git.kernel.org/pub/scm/linux/kernel/git/tj/misc.git cgroup-cftype
>
> Glauber, can you please try to move net kmem stuff out of
> ->populate().  If ->create() doesn't work for whatever reason, can you
> please explain it to me so that we can find a proper solution?

The main reason is twofold:

It first had to do with the order in which registerings take place at 
the kernel. But this matter most for the root cgroup. For the children, 
it should be all initialized anyway. So we can special case whatever is 
needed.

Another point was not to bloat the socket structures with more function 
calls, for populate and create. But we can possibly be able to store 
some data ourselves, and figure it out.

How should I do it? Do you want me to provide a patch ontop of your tree ?
