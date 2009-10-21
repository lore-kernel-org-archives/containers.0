From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 2/4] [RFC] Add c/r support for connected INET sockets
Date: Wed, 21 Oct 2009 12:56:24 -0500
Message-ID: <20091021175624.GA20972@us.ibm.com>
References: <1256072803-3518-1-git-send-email-danms@us.ibm.com> <1256072803-3518-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1256072803-3518-3-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Cc: containers@lists.osdl.org, John Dykstra <jdykstra72@gmail.com>, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting Dan Smith (danms@us.ibm.com):
> This patch adds basic support for C/R of open INET sockets.  I think that
> all the important bits of the TCP and ICSK socket structures is saved,
> but I think there is still some additional IPv6 stuff that needs to be
> handled.
> 
> With this patch applied, the following script can be used to demonstrate
> the functionality:
> 
>   https://lists.linux-foundation.org/pipermail/containers/2009-October/021239.html
> 
> It shows that this enables migration of a sendmail process with open
> connections from one machine to another without dropping.
> 
> We still need comments from the netdev people about what sort of sanity
> checking we need to do on the values in the ckpt_hdr_socket_inet
> structure on restart.
> 
> Note that this still doesn't address lingering sockets yet.
> 
> Changes in v2:
>  - Restore saddr, rcv_saddr, daddr, sport, and dport from the sockaddr
>    structure instead of saving them separately
>  - Fix 'sock' naming in sock_cptrst()
>  - Don't take the queue lock before skb_queue_tail() since it is
>    done for us
>  - Allow "listen only" restore behavior if RESTART_SOCK_LISTENONLY
>    flag is specified on sys_restart()
>  - Pull the implementation of the list of listening sockets back into
>    this patch
>  - Fix dangling printk
>  - Add some comments around the parent/child restore logic
> 
> Cc: netdev@vger.kernel.org
> Cc: Oren Laadan <orenl@librato.com>
> Cc: John Dykstra <jdykstra72@gmail.com>
> Signed-off-by: Dan Smith <danms@us.ibm.com>

fwiw,

Acked-by: Serge Hallyn <serue@us.ibm.com>

except

> +static int sock_inet_restore_addrs(struct inet_sock *inet,
> +				   struct ckpt_hdr_socket_inet *hh)
> +{
> +	inet->daddr = hh->raddr.sin_addr.s_addr;
> +	inet->saddr = hh->laddr.sin_addr.s_addr;
> +	inet->rcv_saddr = inet->saddr;
> +
> +	inet->dport = hh->raddr.sin_port;
> +	inet->sport = hh->laddr.sin_port;

Sorry, I think we've discussed this before but can't recall - does
setting sport here allow an unpriv user to bypass CAP_NET_BIND_SERVICE?

-serge
