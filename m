From: Zhu Yanhai <zhu.yanhai-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: How to create simple socket session between host and multiple
	containers.
Date: Wed, 30 Nov 2011 19:07:11 +0800
Message-ID: <CAC8teKUkAHP=_5G1xfzRYJ8oWxOO5adtnDGbJzZ676VH0peckg@mail.gmail.com>
References: <CAHnfO6yWPh1_q2hwqc9N6zLNPse6nOPVxXGOM1E+-vv-WgxLDw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAHnfO6yWPh1_q2hwqc9N6zLNPse6nOPVxXGOM1E+-vv-WgxLDw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: nishant mungse <nishantmungse-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

2011/11/30 nishant mungse <nishantmungse-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
> Hi,
>
> I want to create a session between multiple containers and host system.
> So that session is being created between host and containers, I tried
> writing the socket programming but problem is i don't want to start the
> containers and want to create session between them.

If the containers were not started, who would pull those data in the
other end of
the 'socket' ?

>
> How to create a multiple sessions with host and containers simultaneously?
> Please help me ASAP.
>
>
> Regards,
> Nishant
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
>
