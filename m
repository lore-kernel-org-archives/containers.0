From: "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
Subject: Re: [patch 3/3][NETNS45][V2] remove timewait sockets at cleanup
Date: Fri, 28 Sep 2007 10:47:08 +0400
Message-ID: <46FCA36C.2080207@sw.ru>
References: <20070927110400.409277229@mai.toulouse-stg.fr.ibm.com>
	<20070927111219.179053451@mai.toulouse-stg.fr.ibm.com>
	<46FBAE9B.7030707@sw.ru> <46FBC058.8020003@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46FBC058.8020003-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
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
> local_bh_disable();
> 
> /* Browse the the established hash table */
> for (h = 0; h < (tcp_hashinfo.ehash_size); h++) {
>                struct inet_ehash_bucket *head =
>                        inet_ehash_bucket(&tcp_hashinfo, h);
> restart:
>          write_lock(&head->lock);
>          sk_for_each_safe(sk, node, tmp, &head->twchain) {
>              tw = inet_twsk(sk);
>              if (tw->tw_net != net)
>                  continue;
>              sock_hold(sk);
>              write_unlock(&head->lock);
>              inet_twsk_deschedule(tw, &tcp_death_row);
>              inet_twsk_put(tw);
>              goto restart;
>          }   
> }
> 
> local_bh_enable();

yes :)
