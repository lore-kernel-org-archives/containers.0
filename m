From: Yasunori Goto <y-goto-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC]Pid conversion between pid namespace
Date: Fri, 04 Jul 2014 14:34:30 +0900
Message-ID: <20140704143422.6B90.E1E9C6FF@jp.fujitsu.com>
References: <5871495633F38949900D2BF2DC04883E55C374@G08CNEXMBPEKD02.g08.fujitsu.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5871495633F38949900D2BF2DC04883E55C374-ZEd+hNNJ6a5ZYpXjqAkB5jz3u5zwRJJDAzI0kPv9QBlmR6Xm/wNWPw@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: =?SHIFT_JIS?B?IkNoZW4sIEhhbnhpYW8vPyD61ui6Ig==?= <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: "Richard Weinberger (richard-/L3Ra7n9ekc@public.gmane.org)" <richard-/L3Ra7n9ekc@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Serge Hallyn (serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org)" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "Oleg Nesterov (oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org)" <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org)" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, "Vasily Kulikov (segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org)" <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Chen-san,

I would like to recommend that you summarize pros/cons for all ideas so far.

For example,

---------
A) make new system call for transrate 

   A-1) systemcall(ID, NS1, NS2) into (ID).
     pros: 
        - foo
        - baa

     cons: 
        - hoge
        - hogehogehoge

   A-2) pid_t getnspid(pid_t query_pid, pid_t observer_pid) 
      (ditto)


B) make/change proc file/directories
   B-1) expand /proc/pid/status
       (ditto)
   
   B-2) /proc/<pidX>/ns/proc/ which would contain everything
         from /proc/<pidX inside the namespace>/.
       (ditto)


------

Please make clear what is the good/bad point of each opinion by the above,
  - Is it hard to keep compatiblity?
  - Is it hard to understand for administorator/programmer?
  - Is it difficult to show for "nested containers"?
  - Is userland tool necessary?
  - any other problems?

I hope it will be good discussion by the above.

Thanks,

> Hi,
> 
> We had some discussions on how to carry out
> pid conversion between pid namespace via:
> syscall[1] and procfs[2].
> 
> Pavel suggested that a syscall like
> (ID, NS1, NS2) into (ID).
> 
> Serge suggested that a syscall 
> pid_t getnspid(pid_t query_pid, pid_t observer_pid).
> 
> 
> Eric and Richard suggested a procfs solution is
> more appropriate.
> 
> Oleg suggested that we should expand /proc/pid/status
> to report this kind of information.
> 
> And Richard suggested adding a directory like
> /proc/<pidX>/ns/proc/ which would contain everything
> from /proc/<pidX inside the namespace>/.
> 
> As procfs provided a more user friendly interface,
> how about expose all sets of tgid, pid, pgid, sid 
> by expanding /proc/PID/status in procfs?
> And we could also expose ns hierarchy under /proc,
> which could be another reference.
> 
> Ex:
>     init_pid_ns    ns1         ns2
> t1  2
> t2   `- 3          1 
> t3       `- 4      `- 5        1
> 
> We could get in /proc/t3/status:
> NSpid: 4 5 1
> We knew that pid 1 in container is pid 4 in init ns.
> 
> And we could get ns hierarchy under /proc/ns_hierarchy like:
> init_ns->ns1->ns2		(as the result of readlink)
>          ->ns3
> We knew that t3 in ns2, and its hierarchy.
> 
> How these ideas looks like?
> Any comments would be appreciated.
> 
> Thanks,
> - Chen
> 
> 
> a) syscall
> http://lwn.net/Articles/602987/
> 
> b) procfs
> http://www.spinics.net/lists/kernel/msg1751688.html
> 

-- 
Yasunori Goto <y-goto-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
