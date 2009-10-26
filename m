From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] user-cr: add --output-fd to write output to a specific fd
Date: Mon, 26 Oct 2009 10:43:05 -0700
Message-ID: <20091026174305.GI31446@count0.beaverton.ibm.com>
References: <1256508801-2426-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1256508801-2426-1-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, Oct 25, 2009 at 06:13:21PM -0400, Oren Laadan wrote:
> This is useful if the user would like redirect the output to
> e.g, a socket or any other already open file descriptor when
> invoking 'checkpoint'.
> 
> Also useful if the user would like to append an existing file.
> 
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> ---
>  checkpoint.c |   47 +++++++++++++++++++++++++++++++++++++++++------
>  1 files changed, 41 insertions(+), 6 deletions(-)
> 
> diff --git a/checkpoint.c b/checkpoint.c
> index c116daf..aef954b 100644
> --- a/checkpoint.c
> +++ b/checkpoint.c
> @@ -32,12 +32,14 @@ static char usage_str[] =
>  "\tOptions:\n"
>  "  -h,--help             print this help message\n"
>  "  -o,--output=FILE      write data to FILE instead of standard output\n"
> +"     --output-fd=FD     write data to file descriptor FD instead of stdout\n"
>  "  -c,--container        require the PID is a container-init\n"
>  "  -v,--verbose          verbose output\n"
>  "";
> 
>  struct args {
>  	char *output;
> +	int outputfd;
>  	int container;
>  	int verbose;
>  };
> @@ -53,17 +55,33 @@ static void usage(char *str)
>  	exit(1);
>  }
> 
> +/* negative retval means error */
> +static int str2num(char *str)
> +{
> +	char *nptr;
> +	int num;
> +
> +	num = strtol(str, &nptr, 10);
> +	if (nptr - str != strlen(str))
> +		num = -1;
> +	return num;
> +}

It'd be nice to see common functions in a shared .o  between
checkpoint and restart. 

Cheers,
	-Matt Helsley
