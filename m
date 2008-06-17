From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH][cryo] Read/print contents of fifo
Date: Tue, 17 Jun 2008 17:31:22 -0500
Message-ID: <20080617223122.GD26942@us.ibm.com>
References: <20080617213040.GC11826@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080617213040.GC11826-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> 
> >From 0f5b3ea20238e0704a71252a3d495ca0db61e1dc Mon Sep 17 00:00:00 2001
> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Date: Sat, 14 Jun 2008 11:45:00 -0700
> Subject: [RFC][PATCH] Read/print contents of fifo.
> 
> To test that checkpoint/restart of pipes is working, read
> one byte at a time from the pipe and write to stdout.
> 
> After checkpoint, both the checkpointed application and the
> restarted application should continue reading from the checkpoint.
> 
> The '-e' option to the program, tests with an empty pipe.
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Thanks, will apply to the git tree tonight.

-serge

> ---
>  tests/pipe.c |   32 ++++++++++++++++++++++++++++----
>  1 files changed, 28 insertions(+), 4 deletions(-)
> 
> diff --git a/tests/pipe.c b/tests/pipe.c
> index cc3cdfd..0812cb3 100644
> --- a/tests/pipe.c
> +++ b/tests/pipe.c
> @@ -3,25 +3,49 @@
>  #include <unistd.h>
>  #include <stdlib.h>
>  #include <string.h>
> +#include <errno.h>
> +#include <sys/fcntl.h>
> 
> -int main()
> +int main(int argc, char *argv[])
>  {
>  	int i = 0;
> +	int rc;
>  	int fds[2];
> +	int c;
> +	int empty;
>  	char *buf = "abcdefghijklmnopqrstuvwxyz";
> 
> +	/*
> +	 * -e: test with an empty pipe
> +	 */
> +	empty = 0;
> +	if (argc > 1 && strcmp(argv[1], "-e") == 0)
> +		empty = 1;
> +
>  	if (pipe(fds) < 0) {
>  		perror("pipe()");
>  		exit(1);
>  	}
> 
> -	write(fds[1], buf, strlen(buf));
> +	if (!empty)
> +		write(fds[1], buf, strlen(buf));
> 
> +	if (fcntl(fds[0], F_SETFL, O_NONBLOCK) < 0) {
> +		perror("fcntl()");
> +		exit(1);
> +	}
>  	printf("Running as %d\n", getpid());
>  	while (i<100) {
>  		sleep(1);
> -		if (i%5 == 0)
> -			printf("i is %d (pid %d)\n", i, getpid());
> +		if (i%5 == 0) {
> +			c = errno = 0;
> +			rc = read(fds[0], &c, 1);
> +			if (rc != 1) {
> +				perror("read() failed");
> +			}
> +			printf("i is %d (pid %d), c is %c\n", i, getpid(), c);
> +
> +		}
>  		i++;
>  	}
>  }
> -- 
> 1.5.2.5
