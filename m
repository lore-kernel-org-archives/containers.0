From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH -cryo 1/1] Correctly close the semundo procfile after
	restarting the undo list
Date: Mon, 30 Jun 2008 09:52:09 -0500
Message-ID: <20080630145209.GA14837@us.ibm.com>
References: <20080630083821.916524000@bull.net>
	<20080630083841.136024000@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080630083841.136024000-6ktuUTfB/bM@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nadia.Derbey-6ktuUTfB/bM@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Nadia.Derbey-6ktuUTfB/bM@public.gmane.org (Nadia.Derbey-6ktuUTfB/bM@public.gmane.org):
> [ PATCH 01/01 ]
> 
> This is a trivial patch that correctly closes the semundo file after restoring
> the semundo list.
> 
> Signed-off-by: Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>
> 
> ---
>  cr.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: cryo-001/cr.c
> ===================================================================
> --- cryo-001.orig/cr.c	2008-06-27 17:25:57.000000000 +0200
> +++ cryo-001/cr.c	2008-06-30 11:15:41.000000000 +0200
> @@ -1447,7 +1447,7 @@ static int restore_semundo(int fd, pid_t
> 
>  	Free(semid);
>  	Free(semadj);
> -	PT_CLOSE(pid, fd);
> +	PT_CLOSE(pid, procfd);
>  	return ret;
>  }

Applied to git tree, thanks.

-serge
