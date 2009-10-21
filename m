From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH user-cr] Allow for logfile for kernel debug messages (v2)
Date: Wed, 21 Oct 2009 17:46:40 -0400
Message-ID: <4ADF8140.3010102@librato.com>
References: <20091021210507.GA2098@us.ibm.com>
	<20091021210533.GA2165@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091021210533.GA2165-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


Serge E. Hallyn wrote:
> If unspecified, -1 will be sent for logfd to the kernel, and there
> will be no debug log.   If specified, then checkpoint and restart
> debug msgs will be sent to the logfile.

The new interface will cover error reporting, so when run without '-l'
both 'checkpoint' and 'restart' (unless asked to run extra silently)
need to provide a pipe to the syscall, and if an error occurs, display
pull the error reason from the pipe and print it.

> 
> Logfile is specified using -l LOGFILE or --logfile=LOGFILE, i.e.
> 
> 	checkpoint $pid -o ckpt.out -l ckpt.debug
> 	restart -l rstr.debug -i ckpt.out
> 
> Changelog:
> 	oct 21: take a --logall flag
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint.c |   34 ++++++++++++++++++++++++++++++----
>  restart.c    |   47 +++++++++++++++++++++++++++++++++++++++++------
>  2 files changed, 71 insertions(+), 10 deletions(-)
> 
> diff --git a/checkpoint.c b/checkpoint.c
> index c116daf..553132c 100644
> --- a/checkpoint.c
> +++ b/checkpoint.c
> @@ -32,6 +32,8 @@ static char usage_str[] =
>  "\tOptions:\n"
>  "  -h,--help             print this help message\n"
>  "  -o,--output=FILE      write data to FILE instead of standard output\n"
> +"  -l,--logfile=FILE     write kernel debug data to FILE (default=nowhere)\n"

Can the user ask to append the data to a file ?

Also, I'm thinking of adding --output-fd=FD (and then --logfile-fd=FD)
to allow a user to first create suitable fds and then exec the program
(that will allow to easily redirect input/output without adding endless
options).

> +"  -a,--logall           have kernel output all debug data, not just errors\n"

Maybe use '-d'/'-D', or some --debug-log instead ?

>  "  -c,--container        require the PID is a container-init\n"
>  "  -v,--verbose          verbose output\n"
>  "";
> @@ -40,11 +42,13 @@ struct args {
>  	char *output;
>  	int container;
>  	int verbose;
> +	int logall;
> +	char *logfile;
>  };
>  
> -inline static int checkpoint(pid_t pid, int fd, unsigned long flags)
> +inline static int checkpoint(pid_t pid, int fd, unsigned long flags, int logfd)
>  {
> -	return syscall(__NR_checkpoint, pid, fd, flags);
> +	return syscall(__NR_checkpoint, pid, fd, flags, logfd);
>  }
>  
>  static void usage(char *str)
> @@ -59,10 +63,12 @@ static void parse_args(struct args *args, int argc, char *argv[])
>  		{ "help",	no_argument,		NULL, 'h' },
>  		{ "output",	required_argument,	NULL, 'o' },
>  		{ "container",	no_argument,		NULL, 'c' },
> +		{ "logfile",	required_argument,	NULL, 'l' },
> +		{ "logall",	required_argument,	NULL, 'a' },
>  		{ "verbose",	no_argument,		NULL, 'v' },
>  		{ NULL,		0,			NULL, 0 }
>  	};
> -	static char optc[] = "hvco:";
> +	static char optc[] = "ahvco:l:";
>  
>  	while (1) {
>  		int c = getopt_long(argc, argv, optc, opts, NULL);
> @@ -73,12 +79,18 @@ static void parse_args(struct args *args, int argc, char *argv[])
>  			exit(1);
>  		case 'h':
>  			usage(usage_str);
> +		case 'a':
> +			args->logall = 1;
> +			break;
>  		case 'o':
>  			args->output = optarg;
>  			break;
>  		case 'c':
>  			args->container = 1;
>  			break;
> +		case 'l':
> +			args->logfile = optarg;
> +			break;
>  		case 'v':
>  			args->verbose = 1;
>  			break;
> @@ -94,6 +106,7 @@ int main(int argc, char *argv[])
>  	unsigned long flags = 0;
>  	pid_t pid;
>  	int ret;
> +	int logfd;
>  
>  	memset(&args, 0, sizeof(args));
>  	parse_args(&args, argc, argv);
> @@ -125,8 +138,21 @@ int main(int argc, char *argv[])
>  		if (ret != STDOUT_FILENO)
>  			close(ret);
>  	}
> +	if (args.logfile) {
> +		logfd = open(args.logfile, O_RDWR | O_CREAT, 0600);

What if the file exists -- always overwrite ?

> +		if (logfd < 0) {
> +			perror("open logfile");
> +			exit(1);
> +		}
> +	}

[...]

The comments above also apply to the 'restart' part.

Thanks,

Oren.
