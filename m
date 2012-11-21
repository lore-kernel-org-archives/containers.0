From: Zhao Hongjiang <zhaohongjiang37-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH RFC 01/12] userns: Support 9p interacting with multiple
	user namespaces
Date: Wed, 21 Nov 2012 17:20:24 +0800
Message-ID: <50AC9CD8.8020207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 2012/11/20 20:43, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

> diff --git a/fs/9p/v9fs.c b/fs/9p/v9fs.c
> index d934f04..1c750ab 100644
> --- a/fs/9p/v9fs.c
> +++ b/fs/9p/v9fs.c
> @@ -161,7 +161,13 @@ static int v9fs_parse_options(struct v9fs_session_info *v9ses, char *opts)
>  				ret = r;
>  				continue;
>  			}
> -			v9ses->dfltuid = option;
> +			v9ses->dfltuid = make_kuid(&init_user_ns, option);

I think the init_user_ns should be current_user_ns() cause the value is come from userspace
and in kernel we should mapping it to its own user_ns.

Hongjiang

> +			if (!uid_valid(v9ses->dfltuid)) {
> +				p9_debug(P9_DEBUG_ERROR,
> +					 "uid field, but not a uid?\n");
> +				ret = -EINVAL;
> +				continue;
> +			}
>  			break;
>  		case Opt_dfltgid:
>  			r = match_int(&args[0], &option);
> @@ -171,7 +177,13 @@ static int v9fs_parse_options(struct v9fs_session_info *v9ses, char *opts)
>  				ret = r;
>  				continue;
>  			}
> -			v9ses->dfltgid = option;
> +			v9ses->dfltgid = make_kgid(&init_user_ns, option);

And this one.

> +			if (!gid_valid(v9ses->dfltgid)) {
> +				p9_debug(P9_DEBUG_ERROR,
> +					 "gid field, but not a gid?\n");
> +				ret = -EINVAL;
> +				continue;
> +			}
>  			break;
>  		case Opt_afid:
>  			r = match_int(&args[0], &option);
> @@ -248,8 +260,9 @@ static int v9fs_parse_options(struct v9fs_session_info *v9ses, char *opts)
>  			else if (strcmp(s, "client") == 0) {
>  				v9ses->flags |= V9FS_ACCESS_CLIENT;
>  			} else {
> +				uid_t uid;
>  				v9ses->flags |= V9FS_ACCESS_SINGLE;
> -				v9ses->uid = simple_strtoul(s, &e, 10);
> +				uid = simple_strtoul(s, &e, 10);
>  				if (*e != '\0') {
>  					ret = -EINVAL;
>  					pr_info("Unknown access argument %s\n",
> @@ -257,6 +270,13 @@ static int v9fs_parse_options(struct v9fs_session_info *v9ses, char *opts)
>  					kfree(s);
>  					goto free_and_return;
>  				}
> +				v9ses->uid = make_kuid(&init_user_ns, uid);

Also this one.

> +				if (!uid_valid(v9ses->uid)) {
> +					ret = -EINVAL;
> +					pr_info("Uknown uid %s\n", s);
> +					kfree(s);
> +					goto free_and_return;
> +				}
>  			}
>
>  			kfree(s);




.
