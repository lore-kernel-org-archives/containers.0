From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: Re: [PATCH v2 7/6] netns ct: final netns tweaks
Date: Thu, 02 Oct 2008 10:11:22 +0200
Message-ID: <48E4822A.4070302__49072.0607842833$1222935323$gmane$org@trash.net>
References: <48C01046.2070704@trash.net>
	<1220842990-30500-17-git-send-email-adobriyan@gmail.com>
	<48C623CA.9060803@trash.net>
	<20080909073245.GA7307@x200.localdomain>
	<48C62B1C.7070104@trash.net>
	<20080913105509.GG7440@x200.localdomain>
	<20080926235901.GA10489@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080926235901.GA10489-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
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
> Add init_net checks to not remove kmem_caches twice and so on.
>
> Refactor functions to split code which should be executed only for
> init_net into one place.
>
> ip_ct_attach and ip_ct_destroy assignments remain separate, because
> they're separate stages in setup and teardown.
>
> NOTE: NOTRACK code is in for-every-net part. It will be made per-netns
> after we decidce how to do it correctly.

Also applied. thanks.
