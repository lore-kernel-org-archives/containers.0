From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch] cgroups: save space for the terminator
Date: Sun, 11 Jul 2010 19:10:22 -0500
Message-ID: <20100712001022.GA6832__49379.0108398118$1278893419$gmane$org@hallyn.com>
References: <20100710105429.GW19184@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100710105429.GW19184@bicker>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Dan Carpenter (error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> The original code didn't leave enough space for a NULL terminator.
> These strings are copied with strcpy() into fixed length buffers in
> cgroup_root_from_opts().
>  
> Signed-off-by: Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Hmm, yes - the fact that kstrndup() allocs len+1 probably threw off
the author of these original lines.  Thanks for spotting this!

Acked-by: Serge E. Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>


> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 3ac6f5b..a942820 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -1102,7 +1102,7 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
>  			if (opts->release_agent)
>  				return -EINVAL;
>  			opts->release_agent =
> -				kstrndup(token + 14, PATH_MAX, GFP_KERNEL);
> +				kstrndup(token + 14, PATH_MAX - 1, GFP_KERNEL);
>  			if (!opts->release_agent)
>  				return -ENOMEM;
>  		} else if (!strncmp(token, "name=", 5)) {
> @@ -1123,7 +1123,7 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
>  			if (opts->name)
>  				return -EINVAL;
>  			opts->name = kstrndup(name,
> -					      MAX_CGROUP_ROOT_NAMELEN,
> +					      MAX_CGROUP_ROOT_NAMELEN - 1,
>  					      GFP_KERNEL);
>  			if (!opts->name)
>  				return -ENOMEM;
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
