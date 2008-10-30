From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 4/6] add SO_NSID and SO_NETNS socket options
Date: Thu, 30 Oct 2008 16:02:33 -0700
Message-ID: <m1bpx1znxy.fsf@frodo.ebiederm.org>
References: <20081030130917.GD17665@thomson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081030130917.GD17665-L+G57L1VLRbR7s880joybQ@public.gmane.org> (Vivien Chappelier's message
	of "Thu, 30 Oct 2008 14:09:17 +0100")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivien Chappelier <vivien.chappelier-L+G57L1VLRbR7s880joybQ@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org


> +	case SO_NSID:
> +		if (!capable(CAP_NET_ADMIN)) {
> +			ret = -EPERM;
> +		} else {
> +			struct net *old_net, *new_net;
> +
> +			ret = -EINVAL;
> +			new_net = get_net_ns_by_id(val);
> +			if (new_net) {
> +				ret = 0;
> +				old_net = sock_net(sk);
> +				sock_net_set(sk, get_net(new_net));
> +				put_net(old_net);
> +			}
> +		}

Ouch.  This is incomplete.  We can't perform this transformation on a bound socket.
And I don't see anything that would prevent that. 

Eric
