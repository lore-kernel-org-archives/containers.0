From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: Re: [PATCH 2/3] Supply network namespace to rpcbind.
Date: Wed, 6 Apr 2011 03:57:43 +0300
Message-ID: <20110406005743.GB27844__34107.0937844508$1302051505$gmane$org@shutemov.name>
References: <4D94319F.8040005@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D94319F.8040005-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Kir Kolyshkin <kir-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Tim Spriggs <tims-DAzCR1AAk2Rg9hUCZPvPmw@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Mar 31, 2011 at 02:47:43AM -0500, Rob Landley wrote:
> From: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> 
> The sunrpc code already has some support for network namespaces,
> but rpcb_create() is still using init_net.  Its arguments include
> a sockaddr and a port, but not a struct net *.  Add one, and
> pass in the value from rpc_xprt when calling it.
> 
> Signed-off-by: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>

Acked-by: Kirill A. Shutemov <kas-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

BTW, it seems conflicts with my rpc_pipefs patchset. I'll rebase my
patchset, if your patches will be merged first.

> ---
> 
>  net/sunrpc/rpcb_clnt.c |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
> index c652e4c..25bb8f9 100644
> --- a/net/sunrpc/rpcb_clnt.c
> +++ b/net/sunrpc/rpcb_clnt.c
> @@ -223,10 +223,11 @@ out:
>  }
>  
>  static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
> -				    size_t salen, int proto, u32 version)
> +				    size_t salen, int proto, struct net *net,
> +				    u32 version)
>  {
>  	struct rpc_create_args args = {
> -		.net		= &init_net,
> +		.net		= net,
>  		.protocol	= proto,
>  		.address	= srvaddr,
>  		.addrsize	= salen,
> @@ -591,7 +592,7 @@ void rpcb_getport_async(struct rpc_task *task)
>  		task->tk_pid, __func__, bind_version);
>  
>  	rpcb_clnt = rpcb_create(clnt->cl_server, sap, salen, xprt->prot,
> -				bind_version);
> +				xprt->xprt_net, bind_version);
>  	if (IS_ERR(rpcb_clnt)) {
>  		status = PTR_ERR(rpcb_clnt);
>  		dprintk("RPC: %5u %s: rpcb_create failed, error %ld\n",
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers

-- 
 Kirill A. Shutemov
