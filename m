From: "Ian jonhson" <jonhson.ian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: container userspace tools
Date: Sat, 13 Dec 2008 16:20:47 +0800
Message-ID: <8f34198c0812130020p43a25b69l6ad13a433bc59a65@mail.gmail.com>
References: <48F5DB43.70003@fr.ibm.com>
	<8f34198c0810250406s4f1c9337ha2bccc10faed1948@mail.gmail.com>
	<49031A54.70806@fr.ibm.com>
	<8f34198c0812112333k6c1474f3hb67e963b39a0d0d6@mail.gmail.com>
	<20081212081238.GA4365@balbir.in.ibm.com>
	<8f34198c0812120106k390a1097ub31905cd2bc44676@mail.gmail.com>
	<20081212091829.GB4365@balbir.in.ibm.com>
	<8f34198c0812120202t39582a27k47c98b88246f18ce@mail.gmail.com>
	<20081212142529.GD4365@balbir.in.ibm.com>
	<8f34198c0812130018j27b5ee34r15eed114013dfba4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <8f34198c0812130018j27b5ee34r15eed114013dfba4-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

>
> There is only the directory of 4507 in <cgroup mount point>, not exist
> the 4506. I print the stuff as follows:
>
> $ ls memory.*
> memory.failcnt      memory.limit_in_bytes      memory.stat
> memory.force_empty  memory.max_usage_in_bytes  memory.usage_in_bytes
>
> $ cat memory.failcnt
> 0
>
> $ cat memory.force_empty
> cat: memory.force_empty: Invalid argument
>
> $ cat memory.limit_in_bytes
> 9223372036854775807
>
> $ cat memory.max_usage_in_bytes
> 1236992
>
> $ cat memory.stat
> cache 0
> rss 851968
> pgpgin 879
> pgpgout 671
> active 851968
> inactive 0
>
>

Sorry for missing the last one:

$ cat memory.usage_in_bytes
856064
