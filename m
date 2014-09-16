From: "Chen, Hanxiao" <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: RE: [RFC PATCH 0/3] ns, procfs: pid conversion between ns and
	showing pidns hierarchy
Date: Tue, 16 Sep 2014 09:06:58 +0000
Message-ID: <5871495633F38949900D2BF2DC04883E5ACF79@G08CNEXMBPEKD02.g08.fujitsu.local>
References: <1409740200-26461-1-git-send-email-chenhanxiao@cn.fujitsu.com>
	<20140912221852.GA18234@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140912221852.GA18234-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
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
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Richard Weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

> -----Original Message-----
> From: Serge E. Hallyn [mailto:serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org]
> 
> Hi,
> 
> so the below is just 30 mins worth of playing around, will hang if you give
> it bad pids, and requires privilege, but shows how to get pid conversion
> in some cases.  Basically it gives you what I had previously suggested
> for the query_pid syscall before.
> 
Thanks for teaching me of how ucred could be used for this case.

> In general, usage is
> 
> translatepid reporter_pid dest_pid query_pid
> 
> where reporter_pid and dest_pid are pids in your pidns.  It will assume
> query_pid is a valid pid in reporter_pid's pidns, and return the pid of
> the same process in dest_pid's namespace.
> 
> In particular,
> 
> if a process in a container (say pid 1, pid 24444 in the host pidns)
> reports something about another process (say pid 262) in the container,
> and you have a shell (pid 1092) on the host, you can figure out the pid
> for 262 in your host pidns using
> 
> translatepid $$ 24444 262
> 
> or to figure out what pid 25152 on the host is knows as in the
> container,
> 
> translatepid 24444 $$ 25152
> 
It's very easy to use:)

> I wonder whether this is enough to give you all you need.  While it
> won't be super-fast, you could use and ppid info to figure out who
> is pid 1, etc.

Yes, functionally it's very good.
But for the cases of utilizes like sosreport, ps,
it's a bit of slow.

So the procfs still has its advantages.
And also, I think the pidns hierarchy is needed.
I'll send the v2 ns hierarchy patch soon.

Thanks,
- Chen
