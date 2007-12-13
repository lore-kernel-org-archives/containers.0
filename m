From: Vitaliy Gusev <vgusev-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC][PATCH] Pid namespaces vs locks interaction
Date: Thu, 13 Dec 2007 17:13:56 +0300
Message-ID: <200712131713.56564.vgusev@openvz.org>
References: <200712061411.32159.vgusev@openvz.org>
	<200712122042.41990.vgusev@openvz.org>
	<20071212184225.GA23504@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071212184225.GA23504-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
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
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelyanov <xemul-3ImXcnM4P+0@public.gmane.org>
List-Id: containers.vger.kernel.org

On 12 December 2007 21:42:25 Serge E. Hallyn wrote:
> Ok sorry - by letting this thread sit a few days I lost track of where
> we were.
>
> I see now, so you're saying fl_pid for nfs is not in fact a task pid.
> It's a magically derived unique id.  (And you say it is unique across
> all the nfs clients?)

It is unique for pair client,server.

>
> So does the p in fl_pid stand for something, or could we rename it to
> fl_id or fl_uniqueid?

If fl_pid will be renamed with fl_uniqueid or something, it still need 
accessing from fs/locks.c: cat /proc/locks shows pids which also are NFS  
pids (unique id). 

For example, let's look the /proc/locks in my system (NFS-server) when do 
flock on a NFS client:

1: POSIX  ADVISORY  WRITE 2 08:06:63116 0 EOF
2: POSIX  ADVISORY  WRITE 7047 08:09:1899694 0 EOF
3: FLOCK  ADVISORY  WRITE 3334 08:06:110497 0 EOF
4: FLOCK  ADVISORY  WRITE 3265 08:06:94786 0 EOF
5: POSIX  ADVISORY  WRITE 2582 08:06:110462 0 EOF

It indicates that process with pid 2 has a posix lock. Really it is a NFS 
unique id. Problem can be solved by using pid of lockd.

> Maybe that's too much bother, but so long as we're bothering with a pid
> cleanup at all it seems worth it to me.  On the other hand maybe
> J. Bruce Fields was right and we should accept the fact that the
> flock->fl_pid shouldn't be taken too seriously, and leave it be.

Mix pids from some namespaces is not good. We can store process pid seen from 
init namespace to the flock->fl_pid (instead pid from the current namespace). 
Thus fcntl(F_GETLK,...) and  "cat /proc/locks" will show global pids.   But 
some LTP tests can fail.

>
> -serge
>

-- 
Thank,
Vitaliy Gusev
