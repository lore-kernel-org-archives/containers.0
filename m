From: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Subject: Re: [patch 0/4] [RFC] Another proportional weight IO controller
Date: Wed, 19 Nov 2008 08:09:22 +0100
Message-ID: <4923BBA2.1070609@unimore.it>
References: <20081113.180558.519459540419535699.ryov@valinux.co.jp>	
	<af41c7c40811131041t1b8491b6la5574ebe75f89000@mail.gmail.com>	
	<20081113214642.GG7542@redhat.com>	
	<af41c7c40811131457w472e4a86tb5344cc1d3d366fb@mail.gmail.com>	
	<20081114160525.GE24624@redhat.com>	
	<e98e18940811141444u5947b806v27fac453ed1e8a5@mail.gmail.com>	
	<20081117142309.GA15564@redhat.com>
	<4922224A.5030502@cn.fujitsu.com>	
	<e98e18940811172101na345b6bh5c73f9e657aac5a7@mail.gmail.com>	
	<20081118120508.GD15268@gandalf.sssup.it>
	<e98e18940811181433o4bb5a147i1e0b9c1baf495ae2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <e98e18940811181433o4bb5a147i1e0b9c1baf495ae2-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Nauman Rafique ha scritto:
>
>
> I think "time only budget" vs "sector budget" is dependent on the
> definition of fairness: do you want to be fair in the time that is
> given to each cgroup or fair in total number of sectors transferred.
> And the appropriate definition of fairness depends on how/where the IO
> scheduler is used. ...
>
>   
Just a general note: as Fabio already said, switching back to time 
budgets in BFQ would be (conceptually) straightforward.
However, we will never get fairness in bandwidth distribution if we work 
(only) in the time domain.



-- 
-----------------------------------------------------------
| Paolo Valente              |                            |
| Algogroup                  |                            |
| Dip. Ing. Informazione     | tel:   +39 059 2056318     |
| Via Vignolese 905/b	     | fax:   +39 059 2056199     |
| 41100 Modena               | 				  |
|     home:  http://algo.ing.unimo.it/people/paolo/       |
-----------------------------------------------------------
