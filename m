From: "Chen, Hanxiao" <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: RE: [RESEND][PATCH 0/2v5] ns,	procfs: pid conversion between ns and
	showing pidns hierarchy
Date: Tue, 28 Oct 2014 09:10:00 +0000
Message-ID: <5871495633F38949900D2BF2DC04883E606120@G08CNEXMBPEKD02.g08.fujitsu.local>
References: <1414145745-30293-1-git-send-email-chenhanxiao@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1414145745-30293-1-git-send-email-chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Content-Language: zh-CN
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: Richard Weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Mateusz Guzik <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org



> -----Original Message-----
> From: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> [mailto:containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org] On Behalf Of Chen
> Hanxiao
> Sent: Friday, October 24, 2014 6:16 PM
> To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org; linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: Richard Weinberger; Serge Hallyn; Oleg Nesterov; Mateusz Guzik; David Howells;
> Eric W. Biederman
> Subject: [RESEND][PATCH 0/2v5] ns, procfs: pid conversion between ns and showing
> pidns hierarchy
> 
> This series will expose pid inside containers
> via procfs.
> Also show the hierarchy of pid namespcae.
> Then we could know how pid looks inside a container
> and their ns relationships.
> 
> 1. helpful for nested container check/restore
> From /proc/PID/ns/pid, we could know whether two pid lived
> in the same ns.
> From this patch, we could know whether two pid had relationship
> between each other.
> 
> 2. used for pid translation from container
> Ex:
>      init_pid_ns    ns1         ns2
>  t1  2
>  t2   `- 3          1
>  t3   `- 4          3
>  t4       `- 5      `- 5        1
>  t5       `- 6      `- 8        3
> 
> It could solve problems like: we see a pid 3 goes wrong
> in container's log, what is its pid on hosts:
> a) inside container:
> # readlink /proc/3/ns/pid
> pid:[4026532388]
> 
> b) on host:
> # cat /proc/pidns_hierarchy
> 14918 16263
> 16581
> Then we could easily find /proc/16263/ns/pid->4026532388.
> On host, we knew that reported pid 3 is in level 2,
>    and its parental pid ns is from pid 14918.
> 
> c) on host, check child of 16263, grep it from status:
> NSpid:  16268   8       3
> 
> We knew that pid 16268 is pid 3 reported by container.
> 

Hi,

Any comments?

Thanks,
- Chen
