From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [user-cr][PATCH 2/2] Add --mount-pty option to mount new devpts
Date: Mon, 15 Feb 2010 14:50:04 -0600
Message-ID: <20100215205003.GA16950@us.ibm.com>
References: <1266224833-10902-1-git-send-email-orenl@cs.columbia.edu>
	<1266224833-10902-2-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1266224833-10902-2-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
> Based on Serge Hallyn's patch:
> 
>   "Trivial patch, and I'm not sure whether we want this or want to do
>   it this way.  But it saves me having to do it during my restart.sh
>   wrapper shell-script."
> 
> Make sure that the old /dev/pts is un-mounted prior to the mount of
> the new one.
> 
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> ---
>  restart.c |   40 ++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 40 insertions(+), 0 deletions(-)
> 
> diff --git a/restart.c b/restart.c
> index f42b456..e3c4a5c 100644
> --- a/restart.c
> +++ b/restart.c
> @@ -53,6 +53,7 @@ static char usage_str[] =
>  "     --signal=SIG       send SIG to root task on SIGINT (default: SIGKILL\n"
>  "                        to container root, SIGINT otherwise)\n"
>  "     --mntns            restart under a private mounts namespace\n"
> +"     --mount-pty        start in a new devpts namespace to supprt ptys\n"
>  "  -w,--wait             wait for root task to termiate (default)\n"
>  "     --show-status      show exit status of root task (implies -w)\n"
>  "     --copy-status      imitate exit status of root task (implies -w)\n"
> @@ -275,6 +276,7 @@ int global_send_sigint = -1;
>  int global_sent_sigint;
> 
>  static int ckpt_remount_proc(void);
> +static int ckpt_remount_devpts(void);
> 
>  static int ckpt_build_tree(struct ckpt_ctx *ctx);
>  static int ckpt_init_tree(struct ckpt_ctx *ctx);
> @@ -342,6 +344,7 @@ struct args {
>  	char *root;
>  	int wait;
>  	int mntns;
> +	int mnt_pty;
>  	int show_status;
>  	int copy_status;
>  	char *freezer;
> @@ -432,6 +435,7 @@ static void parse_args(struct args *args, int argc, char *argv[])
>  		{ "debug",	no_argument,		NULL, 'd' },
>  		{ "warn-pidzero",	no_argument,	NULL, 9 },
>  		{ "fail-pidzero",	no_argument,	NULL, 10 },
> +		{ "mount-pty",	no_argument,		NULL, 12 },
>  		{ NULL,		0,			NULL, 0 }
>  	};
>  	static char optc[] = "hdvkpPwWF:r:i:l:";
> @@ -538,6 +542,9 @@ static void parse_args(struct args *args, int argc, char *argv[])
>  		case 11:
>  			args->mntns = 1;
>  			break;
> +		case 12:
> +			args->mnt_pty = 1;
> +			break;
>  		default:
>  			usage(usage_str);
>  		}
> @@ -591,6 +598,9 @@ static void parse_args(struct args *args, int argc, char *argv[])
>  		printf("Invalid used of both -l/--logfile and --logfile-fd\n");
>  		exit(1);
>  	}
> +
> +	if (args->mnt_pty)
> +		args->mntns = 1;
>  }
> 
>  static void report_exit_status(int status, char *str, int debug)
> @@ -785,6 +795,10 @@ int main(int argc, char *argv[])
>  		exit(1);
>  	}
> 
> +	/* remount /dev/pts ? */
> +	if (args.mnt_pty && ckpt_remount_devpts() < 0)
> +		exit(1);
> +
>  	/* self-restart ends here: */
>  	if (args.self) {
>  		restart(getpid(), STDIN_FILENO, RESTART_TASKSELF, args.logfd);
> @@ -916,6 +930,32 @@ static int ckpt_collect_child(struct ckpt_ctx *ctx)
>  	return ckpt_parse_status(status, mimic, verbose);
>  }
> 
> +static int ckpt_remount_devpts(void)
> +{
> +	struct stat ptystat;
> +
> +	/* make sure /dev/ptmx is a link else we'll just break */
> +	if (lstat("/dev/ptmx", &ptystat) < 0) {
> +		perror("stat /dev/ptmx");
> +		return -1;
> +	}
> +	if ((ptystat.st_mode & S_IFMT) != S_IFLNK) {
> +		ckpt_err("Error: /dev/ptmx must be a link to /dev/pts/ptmx\n");
> +		return -1;
> +	}
> +
> +	if (umount2("/dev/pts", MNT_DETACH) < 0) {
> +		perror("umount -l /dev/pts");
> +		return -1;
> +	}
> +	if (mount("pts", "/dev/pts", "devpts", 0, "newinstance") < 0) {

How about making that

	if (mount("pts", "/dev/pts", "devpts", 0, "ptmxmode=666,newinstance")
				< 0) {

(or take that as another arg if you must)?  Otherwise restarting
non-root-owned tasks not only ends up with tasks not able to create
a new terminal, but you can't externally fix that since the mount
is private...

> +		perror("mount -t devpts -o newinstance");
> +		return -1;
> +	}
> +
> +	return 0;
> +}
> +
>  static int ckpt_close_files(void)
>  {
>  	char fdpath[64], *endp;
> -- 
> 1.6.3.3
