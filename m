From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH lxc 1/2] lxc-unshare: accept multiple -s options
Date: Tue, 18 May 2010 17:49:46 +0200
Message-ID: <4BF2B71A.8020906@fr.ibm.com>
References: <20100513193412.GA15433@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100513193412.GA15433-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 05/13/2010 09:34 PM, Serge E. Hallyn wrote:
> (also remove -f from usage as it is not actually supported)
>
> Signed-off-by: Serge E. Hallyn<serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>   src/lxc/lxc_unshare.c |   28 ++++++++++++++++++++++++++--
>   1 files changed, 26 insertions(+), 2 deletions(-)
>
> diff --git a/src/lxc/lxc_unshare.c b/src/lxc/lxc_unshare.c
> index 10654f7..8db1cb7 100644
> --- a/src/lxc/lxc_unshare.c
> +++ b/src/lxc/lxc_unshare.c
> @@ -48,7 +48,7 @@ void usage(char *cmd)
>   	fprintf(stderr, "\t -s flags: Ored list of flags to unshare:\n" \
>   			"\t           MOUNT, PID, UTSNAME, IPC, USER, NETWORK\n");
>   	fprintf(stderr, "\t -u<id>  : new id to be set if -s USER is specified\n");
> -	fprintf(stderr, "\t if -f or -s PID is specified,<command>  is mandatory)\n");
> +	fprintf(stderr, "\t if -s PID is specified,<command>  is mandatory)\n");
>   	_exit(1);
>   }
>
> @@ -154,6 +154,29 @@ static int do_start(void *arg)
>   	return 1;
>   }
>
> +void extend_namespaces(char **n, char *optarg)
> +{
> +	char *namespaces = *n;
> +	int cont = 0, newlen = strlen(optarg) + 1; /* +1 for trailing \0 */
> +
> +	if (namespaces) {
> +		cont = 1;
> +		newlen += strlen(namespaces) + 1; /* +1 for '|' */
> +	}
> +
> +	namespaces = realloc(namespaces, newlen);
> +	if (!namespaces) {
> +		perror("realloc");
> +		exit(1);
> +	}
> +	if (cont)
> +		sprintf(namespaces+strlen(namespaces), "|%s", optarg);
> +	else
> +		sprintf(namespaces, "%s", optarg);
> +	namespaces[newlen-1] = '\0';
> +	*n = namespaces;
> +}
> +
>   int main(int argc, char *argv[])
>   {
>   	int opt, status;
> @@ -174,7 +197,8 @@ int main(int argc, char *argv[])
>   	while ((opt = getopt(argc, argv, "s:u:")) != -1) {
>   		switch (opt) {
>   		case 's':
> -			namespaces = optarg;
> +			extend_namespaces(&namespaces, optarg);
> +			printf("namespaces is %s\n", namespaces);
>   			break;
>   		case 'u':
>   			uid = lookup_user(optarg);

Hi Serge,

Sorry for the delay.

Is it possible to just kill the "Ored" option format and have only 
multiple "-s" options ? That will simplificate the code a lot.

Thanks
   -- Daniel
