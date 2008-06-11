From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [GIT PATCH] actually check va randomization
Date: Wed, 11 Jun 2008 14:52:19 -0500
Message-ID: <20080611195219.GB14392@us.ibm.com>
References: <48173CE1.7050503@fr.ibm.com> <481ECA42.5060603@bull.net>
	<20080609130429.GA16297@us.ibm.com> <484D4612.9000901@bull.net>
	<20080609152336.GA27878@us.ibm.com>
	<484E1BD3.40401@ozlabs.au.ibm.com>
	<20080610181756.GB13817@us.ibm.com>
	<484F0DC7.5080209@ozlabs.au.ibm.com>
	<1213141919.7261.21.camel@nimitz>
	<20080611183551.GA32012@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080611183551.GA32012-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: kathys <kathys-QcUrd9fbWu1x7SfHBjqd8AC/G2K4zDHf@public.gmane.org>, Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Dave Hansen [dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org] wrote:
> | Rather than just documenting this in the readme, actually spit
> | out a warning on it.
> 
> Why not just bail out ?  Its mostly unreliable at that point anyway.
> Besides, the warning can get buried in lot of other output.
> ---
> >From 84d005031a8a17bdca62dc541c296a3bea74658c Mon Sep 17 00:00:00 2001
> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Date: Wed, 11 Jun 2008 11:22:17 -0700
> Subject: [PATCH] cryo currently requires randomize_va_space to be 0. Fail if it is not.
> 
> ---
>  cr.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/cr.c b/cr.c
> index db3ada0..217c5e7 100644
> --- a/cr.c
> +++ b/cr.c
> @@ -1464,6 +1464,7 @@ void check_for_va_randomize(void)
>  		return;
>  	fprintf(stderr, "WARNING: %s is set to: %d\n", VA_RANDOM_FILE, enabled);
>  	fprintf(stderr, "         Please set to 0 to make cryo more reliable\n");
> +	exit(1);
>  }
> 
>  void usage(void)

Oh...  Thanks, Suka, I'd just done the same thing using an ERROR().

thanks,
-serge
