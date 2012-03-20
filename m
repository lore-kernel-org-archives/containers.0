From: "Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 03/10] cgroup: implement cgroup_add_cftypes() and friends
Date: Tue, 20 Mar 2012 14:22:02 +0530
Message-ID: <877gyfu025.fsf@linux.vnet.ibm.com>
References: <1331940963-15756-1-git-send-email-tj@kernel.org>
	<1331940963-15756-4-git-send-email-tj@kernel.org>User-Agent:
	Notmuch/0.11.1+346~g13d19c3 (http://notmuchmail.org)
	Emacs/23.3.1 (x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1331940963-15756-4-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> writes:

> Currently, cgroup directories are populated by subsys->populate()
> callback explicitly creating files on each cgroup creation.  This
> level of flexibility isn't needed or desirable.  It provides largely
> unused flexibility which call for abuses while severely limiting what
> the core layer can do through the lack of structure and conventions.
>
> Per each cgroup file type, the only distinction that cgroup users is
> making is whether a cgroup is root or not, which can easily be
> expressed with flags.
>
> This patch introduces cgroup_add_cftypes() and its wrapper macros -
> CGROUP_SUBSYS_CFTYPES[_COND]().  These deal with cftypes instead of
> individual files - controllers indicate that certain types of files
> exist for certain subsystem.  Newly added CFTYPE_*_ON_ROOT flags
> indicate whether a cftype should be excluded or created only on the
> root cgroup.
>
> cgroup_add_cftypes() can be called any time whether the target
> subsystem is currently attached or not.  cgroup core will create files
> on the existing cgroups as necessary.  CGROUP_SUBSYS_CFTYPES[_COND]()
> are convenience macros controllers so that cftypes can be declared to
> belong to certain cgroup.  The COND variant is useful for cases where
> certain files are dependent on boot time parameter.
>
> Further patches will convert the existing users and remove the file
> based interface.  Note that this interface allows dynamic addition of
> files to an active controller.  This will be used for sub-controller
> modularity and unified hierarchy in the longer term.
>
> This patch implements the new mechanism but doesn't apply it to any
> user.
>

.....

> +/*
> + * Declare cftype array @cfts for cgroup subsys @ss if @cond is %true.
> + * Useful if the files are dependent on boot time parameter.
> + */
> +#define CGROUP_SUBSYS_CFTYPES_COND(ss, cfts, cond)			\
> +	static int __init __cgroup_cfts_init_##ss_##cfts(void)		\
> +	{								\
> +		if ((cond))						\
> +			WARN_ON(cgroup_add_cftypes(&ss, cfts));		\
> +		return 0;						\
> +	}								\
> +	fs_initcall(__cgroup_cfts_init_##ss_##cfts);
> +

Instead of using CGROUP_SUBSYS_CFTYPES_COND, are you ok if other
subsystem called cgroup_add_cftypes ?. I am looking at how this will
impact http://article.gmane.org/gmane.linux.kernel.mm/75470 . With
HugeTLB we cannot do the above. 

-aneesh
