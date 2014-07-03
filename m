From: "chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org" <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [RFC]Pid conversion between pid namespace
Date: Thu, 3 Jul 2014 12:18:33 +0000
Message-ID: <5871495633F38949900D2BF2DC04883E55C374@G08CNEXMBPEKD02.g08.fujitsu.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
To: "Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org)" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, "Serge Hallyn (serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org)" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "Oleg
	Nesterov (oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org)" <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Richard Weinberger
	(richard-/L3Ra7n9ekc@public.gmane.org)" <richard-/L3Ra7n9ekc@public.gmane.org>, "Pavel Emelyanov (xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org)" <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, "Vasily Kulikov (segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org)" <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>, "Gotou, Yasunori" <y-goto-+CUm20s59erQFUHtdCDX3A@public.gmane.org>, "'Daniel
	P. Berrange (berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org)'" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

We had some discussions on how to carry out
pid conversion between pid namespace via:
syscall[1] and procfs[2].

Pavel suggested that a syscall like
(ID, NS1, NS2) into (ID).

Serge suggested that a syscall 
pid_t getnspid(pid_t query_pid, pid_t observer_pid).


Eric and Richard suggested a procfs solution is
more appropriate.

Oleg suggested that we should expand /proc/pid/status
to report this kind of information.

And Richard suggested adding a directory like
/proc/<pidX>/ns/proc/ which would contain everything
from /proc/<pidX inside the namespace>/.

As procfs provided a more user friendly interface,
how about expose all sets of tgid, pid, pgid, sid 
by expanding /proc/PID/status in procfs?
And we could also expose ns hierarchy under /proc,
which could be another reference.

Ex:
    init_pid_ns    ns1         ns2
t1  2
t2   `- 3          1 
t3       `- 4      `- 5        1

We could get in /proc/t3/status:
NSpid: 4 5 1
We knew that pid 1 in container is pid 4 in init ns.

And we could get ns hierarchy under /proc/ns_hierarchy like:
init_ns->ns1->ns2		(as the result of readlink)
         ->ns3
We knew that t3 in ns2, and its hierarchy.

How these ideas looks like?
Any comments would be appreciated.

Thanks,
- Chen


a) syscall
http://lwn.net/Articles/602987/

b) procfs
http://www.spinics.net/lists/kernel/msg1751688.html
