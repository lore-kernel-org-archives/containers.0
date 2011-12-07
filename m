From: Davidlohr Bueso <dave-mXXj517/zsQ@public.gmane.org>
Subject: Re: [PATCH] resource cgroups: remove bogus cast
Date: Wed, 07 Dec 2011 13:15:32 +0100
Message-ID: <1323260132.3318.0.camel__40258.7093798958$1323260619$gmane$org@offbook>
References: <1323119621.3244.1.camel@offbook>
Reply-To: dave-mXXj517/zsQ@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1323119621.3244.1.camel@offbook>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

ping?

On Mon, 2011-12-05 at 22:13 +0100, Davidlohr Bueso wrote:
> From: Davidlohr Bueso <dave-mXXj517/zsQ@public.gmane.org>
> 
> The memparse() function already accepts const char * as the parsing string.
> 
> Signed-off-by: Davidlohr Bueso <dave-mXXj517/zsQ@public.gmane.org>
> ---
>  kernel/res_counter.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
> index 34683ef..6d269cc 100644
> --- a/kernel/res_counter.c
> +++ b/kernel/res_counter.c
> @@ -159,8 +159,7 @@ int res_counter_memparse_write_strategy(const char *buf,
>  		return 0;
>  	}
>  
> -	/* FIXME - make memparse() take const char* args */
> -	*res = memparse((char *)buf, &end);
> +	*res = memparse(buf, &end);
>  	if (*end != '\0')
>  		return -EINVAL;
>  
