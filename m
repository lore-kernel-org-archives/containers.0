From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Add O_TRUNC when creating cryo file
Date: Tue, 24 Jun 2008 18:03:34 -0500
Message-ID: <20080624230334.GB18699@us.ibm.com>
References: <20080624224957.GA22681@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080624224957.GA22681-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> >From 9b4dff531586c8dd0b0c75b17ef9ea3e5efc4d0e Mon Sep 17 00:00:00 2001
> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Date: Tue, 24 Jun 2008 15:42:55 -0700
> Subject: [PATCH] Add O_TRUNC when creating cryo file
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Thanks, applied.

-serge

> ---
>  cr.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/cr.c b/cr.c
> index 96a2ea0..b688229 100644
> --- a/cr.c
> +++ b/cr.c
> @@ -1966,7 +1966,7 @@ int main(int argc, char **argv)
>  		case 'l':	mode = ch; break;
>  		case 's':	cr_mode |= CR_STOP; break;
>  		case 'm':	cr_mode |= CR_MMAP; break;
> -		case 'p':	mode = ch; fd = 1; perm = O_WRONLY|O_CREAT; pid = (pid_t)atoi(optarg); break;
> +		case 'p':	mode = ch; fd = 1; perm = O_WRONLY|O_CREAT|O_TRUNC; pid = (pid_t)atoi(optarg); break;
>  		case 'r':	mode = ch; break;
>  		case 'f':	strncpy(filename, optarg, sizeof(filename)); break;
>  		default:	usage(); exit(1);
> -- 
> 1.5.2.5
