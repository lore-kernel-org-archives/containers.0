From: "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
Subject: Re: [patch 3/3][NETNS45][V2] remove timewait sockets at cleanup
Date: Thu, 27 Sep 2007 17:22:35 +0400
Message-ID: <46FBAE9B.7030707@sw.ru>
References: <20070927110400.409277229@mai.toulouse-stg.fr.ibm.com>
	<20070927111219.179053451@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070927111219.179053451-WECHFHqYCmGD/CxQmPlnQ0FT0OZdM7KVQQ4Iyu8u01E@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Daniel Lezcano wrote:
> From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> 
> Denis Lunev spotted that if we take a reference to the network namespace
> with the timewait sockets, we will need to wait for their expiration to
> have the network namespace freed. This is a waste of time, the timewait
> sockets are for avoiding to receive a duplicate packet from the network,
> if the network namespace is freed, the network stack is removed, so no
> chance to receive any packets from the outside world.
> 
> This patchset remove/destroy the timewait sockets when the
> network namespace is freed.
> 
> Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> ---
>  net/ipv4/tcp.c |   53 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 53 insertions(+)
> 

[...]
This place seems non-trival and broken for me :( May be I am wrong.
> + 		write_lock_bh(&head->lock);
> +
> +		sk_for_each_safe(sk, node, tmp, &head->twchain) {
> +
> +			tw = inet_twsk(sk);
> +			if (tw->tw_net != net)
> +				continue;
> +
> +			/* deschedule the timewait socket */
> +			spin_lock(&tcp_death_row.death_lock);
> +			if (inet_twsk_del_dead_node(tw)) {
> +				inet_twsk_put(tw);
> +				if (--tcp_death_row.tw_count == 0)
> +					del_timer(&tcp_death_row.tw_timer);
There is a call inet_twsk_deschedule which do exactly what we need to

void inet_twsk_deschedule(struct inet_timewait_sock *tw,
                          struct inet_timewait_death_row *twdr)
{
        spin_lock(&twdr->death_lock);
        if (inet_twsk_del_dead_node(tw)) {
                inet_twsk_put(tw);
                if (--twdr->tw_count == 0)
                        del_timer(&twdr->tw_timer);
        }
        spin_unlock(&twdr->death_lock);
        __inet_twsk_kill(tw, twdr->hashinfo);
}

and, from my point of view, your patch [2] is even not needed. We should do

restart:
        write_lock_bh(&head->lock);
        sk_for_each_safe(sk, node, tmp, &head->twchain) {
            tw = inet_twsk(sk);
            if (tw->tw_net != net)
                continue;
            sock_hold(sk);
            write_unlock_bh(&head->lock);

            inet_twsk_deschedule(tw, &tcp_death_row);
            inet_twsk_put(tw);
            goto restart;
        }

This removes serious locking issue. You have introduced dependency
between write_lock_bh(&head->lock); and
spin_lock(&tcp_death_row.death_lock);
This should be at least checked and documented in the headers. I am not
sure that this is correct.

If my approach is correct, your second patch is not needed.

It will also worth to local_bh_enable() at the very beginning and remove
_bh from write_lock.

Regards,
	Den
