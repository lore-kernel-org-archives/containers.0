From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: Where can I play the memory control (with -mm)
Date: Thu, 18 Dec 2008 12:52:00 +0900
Message-ID: <20081218125200.28d64eae.kamezawa.hiroyu@jp.fujitsu.com>
References: <8f34198c0812171929i6e26fdb4uc5862d102bb4fc41@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <8f34198c0812171929i6e26fdb4uc5862d102bb4fc41-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ian jonhson <jonhson.ian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 18 Dec 2008 11:29:06 +0800
"Ian jonhson" <jonhson.ian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> Hi Balbin,
> 
> I am very interested in the memory control of container,
> but I don't know where I can find the patches to push the
> functionalities and how to use the codes via some example
> or use cases.
> 
Because it has much relationship with global memory managenet,
it's mainatained in -mm kernel.
http://marc.info/?l=linux-mm-commits&r=1&w=2
http://userweb.kernel.org/~akpm/mmotm/

> Could you give me some advices?
> 
See Documentaion/controllers/memory.txt and 
    Documentaion/controllers/memcg_test.txt
If not enough, please advice me to improve above 2.

Relatead source code is
  mm/memcontrol.c
  mm/page_cgroup.c
  include/linux/memcontrol.h
  include/linux/page_cgroup.h

Regards,
-Kame


> Thanks,
> 
> Ian
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
