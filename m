From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: PHYS type lxc not working
Date: Wed, 7 Jul 2010 15:33:44 -0700
Message-ID: <20100707223344.GA3129__17247.4397616044$1278546362$gmane$org@count0.beaverton.ibm.com>
References: <AANLkTino_Vt88QmLt8o4nzLmex2NwBSxkO4bSRBbS-UD@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTino_Vt88QmLt8o4nzLmex2NwBSxkO4bSRBbS-UD-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sabdar <sabdar-ETsMpvZGyKJdeDdKuUvyIgC/G2K4zDHf@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Jul 05, 2010 at 10:09:21AM +0530, Sabdar wrote:
>    Hi all,
>         I want to use the below configuration in lxc, but the problem is the
> physical interface is not getting release after i stop the container like it
> happens in macvlan type.The interface gets disappear from host and i can
> restore that only if i reboot my system,
> 
> lxc.utsname = gamma
> lxc.network.type = phys
> lxc.network.flags = up
> lxc.network.link = eth0
> lxc.network.name = eth0
> lxc.network.ipv4 = 192.168.10.1
> 
> My kernel version :- linux-2.6.33

Have you tried 2.6.35-rc4? It has Eric's sysfs and netns tagging
patches which enhance support for using physical interfaces.

Cc'ing lxc-users (which is probably a better place to ask)

> Lxc version :- 0.6.5

lxc 0.7.1 is also out.

I'm sorry, I know this isn't much help in figuring out the
exact nature of the problem. Hopefully Cc'ing lxc-users will help.

Cheers,
	-Matt Helsley
