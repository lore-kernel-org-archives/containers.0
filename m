From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: No limitation in physical memory in cgroups
Date: Thu, 21 May 2009 23:18:48 +0800
Message-ID: <20090521151848.GQ4858@balbir.in.ibm.com>
References: <d95d44a20905192252t6cce5169y730a37184075beb9@mail.gmail.com>
	<4A13ABC8.2000907@cn.fujitsu.com>
	<d95d44a20905200335v6aabfc28qa3958e8404965775@mail.gmail.com>
	<20090521085857.d4b82cba.kamezawa.hiroyu@jp.fujitsu.com>
	<d95d44a20905202347y177e9744k1a9817236a102b53@mail.gmail.com>
	<20090521161556.2eca8fd0.kamezawa.hiroyu@jp.fujitsu.com>
	<d95d44a20905210456q13b2334avecb0dc6ff0f0d26@mail.gmail.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <d95d44a20905210456q13b2334avecb0dc6ff0f0d26-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: anqin <anqin.qin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

* anqin <anqin.qin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> [2009-05-21 19:56:56]:

> > right. memcg doesn't prevent malloc or mmap. but controls usage of "physical"
> > memory.
> >
> 
> ok.
> 
> > You need to call memset() or some to use "physical" memory by page fault.
> > malloc just allocates virtual address. (and this program will start to use
> > swap.)
> >
> >
> > BTW, Try
> > # echo 300M > .../memory.memsw.limit_in_bytes
> > If you config CGROUP_MEM_RES_CTRL_SWAP. You can limit mem+swap usage.
> >
> 
> hmm...  is the functionality  one of those in kernel 2.6.29.3?
> I have compiled the kernel after marked with all cgroup-related
> options, including the
> 
> [*] Resource counters
> [*]   Memory Resource Controller for Control Cgroups
>    [*]   Memory Resource Controller Swap Extension (EXPERIMENTAL)
> 
> but I can not find the memory.memsw.limit_in_bytes exists in cgroupfs.
> It seems the only file related to swap is memory.swappiness.
> 
> I grep the created .config file and find the
> 
> CGROUP_MEM_RES_CTRL_SWAP=y
> 
> I have searched the Document/cgroups but found nothing.
> Any idea?

Are you booting with noswapaccount as a boot parameter?

-- 
	Balbir
