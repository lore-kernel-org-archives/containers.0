From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] Replace Paul Menage with Tejun Heo as cgroups maintainer
Date: Mon, 14 Nov 2011 17:36:55 -0800
Message-ID: <20111115013655.GH30922@google.com>
References: <1321320612-57855-1-git-send-email-paul@paulmenage.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1321320612-57855-1-git-send-email-paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

(cc'ing akpm, Ingo and Frederic)

On Mon, Nov 14, 2011 at 05:30:12PM -0800, Paul Menage wrote:
> As is probably painfully obvious, I don't have time to be a cgroups
> maintainer.  Rather than have me continue to hope that I'll magically
> find more spare time, instead Tejun has kindly agreed to take over the
> role, along with Li Zefan.
> 
> Signed-off-by: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
> ---
> 
> Tejun, Li - can I get your acks before I send this on to mainline?

Sure,

 Acked-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

I'll set up cgroup korg git tree and do standard for-next / for-fixes
branch management.  I won't be committing patches unless co-acked by
Li Zefan.

If anyone objects / has better ideas, please speak up.

Thank you.

>  MAINTAINERS |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 4808256..055b7f6 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -1926,7 +1926,7 @@ S:	Maintained
>  F:	drivers/connector/
>  
>  CONTROL GROUPS (CGROUPS)
> -M:	Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
> +M:	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>  M:	Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
>  L:	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
>  S:	Maintained
> -- 
> 1.7.5.4
> 

-- 
tejun
