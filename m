From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: Re: [PATCH 33/33] Enable netfilter in netns
Date: Thu, 02 Oct 2008 11:12:08 +0200
Message-ID: <48E49068.5070305__38733.1584738151$1222939226$gmane$org@trash.net>
References: <48C01046.2070704@trash.net>
	<1220842990-30500-33-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1220842990-30500-33-git-send-email-adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Alexey Dobriyan wrote:
> >From kernel perspective, allow entrance in nf_hook_slow().
>
> Stuff which uses nf_register_hook/nf_register_hooks, but otherwise not netns-ready:
>
> 	DECnet netfilter
> 	ipt_CLUSTERIP
> 	nf_nat_standalone.c together with XFRM (?)
> 	IPVS
> 	several individual match modules (like hashlimit)
> 	ctnetlink
> 	NOTRACK
> 	all sorts of queueing and reporting to userspace
> 	L3 and L4 protocol sysctls, bridge sysctls
> 	probably something else
>
> Anyway critical mass has been achieved, there is no reason to hide netfilter any longer.
>
> >From userspace perspective, allow to manipulate all sorts of                                                                                                                                                                                   
> iptables/ip6tables/arptables rules.
>   

Applied. thanks Alexey.

Is there an easy way to test all this stuff?
