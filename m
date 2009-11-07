From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [v11][PATCH 9/9] Document clone_with_pids() syscall
Date: Fri, 6 Nov 2009 18:26:12 -0800
Message-ID: <20091107022612.GA18039__15622.5946768702$1257560777$gmane$org@suka>
References: <20091105053053.GA11289@us.ibm.com>
	<20091105054204.GI16142@us.ibm.com>
	<20091106183936.GA32531@us.ibm.com>
	<20091106201814.GA26614@count0.beaverton.ibm.com>
	<20091106214529.GB26614@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091106214529.GB26614-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: arnd-r2nGTMty4D4@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Matt Helsley [matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
| > If userspace passes an array with n pids and there are k namespace levels
| > then clone_with_pids() makes sure that the kernel sees a pid array like:
| > 
| > index	  0     ... k - (n + 1)        ...          k - 1
| > 	+-----------------------+-------------------------+
| > pid_t	| 0 ..................0 | <copied from userspace> |
| > 	+-----------------------+-------------------------+
| 
| (diagram assumes n != k. If n == k then pids[0] is the pid desired
| in the initial namespace..)

True.

Also I was not sure if we should prevent choosing pids in ancestor containers.
since a process is not even supposed to know of ancestor namespaces. Is there
a need for choosing pids in those namespaces.

| 
| > 
| > So even though the order is different from choosepid() the calling
| > task still doesn't need to know its pidns level. Of course, just
| > like choosepid(), n <= k or userspace will get EINVAL.
| 
| Forgot to mention that I prefer the way choosepid orders the pids.
| It's not inspired by the way that the kernel implements pid namespaces
| and has more to do with the way userspace sees things (IMHO).

Hmm, In general we C/R a descendant container. So the way userspace
sees it at that point is "what are the pids of this process in my current
and in any descendant namespaces". IOW, the pid of container from which
we checkpoint seems more interesting first - right ?  If so, the pids[]
are better ordered from older namespace to younger namespace ?

| I don't know if it makes more sense to change clone_with_pids() or have
| [e]glibc wrappers swap the array contents.
| 
| Cheers,
| 	-Matt Helsley
| _______________________________________________
| Containers mailing list
| Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
| https://lists.linux-foundation.org/mailman/listinfo/containers
