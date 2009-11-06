From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [v11][PATCH 9/9] Document clone_with_pids() syscall
Date: Fri, 6 Nov 2009 13:45:29 -0800
Message-ID: <20091106214529.GB26614__4080.1199189902$1257544348$gmane$org@count0.beaverton.ibm.com>
References: <20091105053053.GA11289@us.ibm.com>
	<20091105054204.GI16142@us.ibm.com>
	<20091106183936.GA32531@us.ibm.com>
	<20091106201814.GA26614@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091106201814.GA26614-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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

On Fri, Nov 06, 2009 at 12:18:14PM -0800, Matt Helsley wrote:
> On Fri, Nov 06, 2009 at 12:39:36PM -0600, Serge E. Hallyn wrote:
> > Quoting Sukadev Bhattiprolu (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> > ...
> > > +	If a pid in the @pids list is non-zero, the kernel tries to assign
> > > +	the specified pid in that namespace.  If that pid is already in use
> > > +	by another process, the system call fails (see EBUSY below).
> > > +
> > > +	The order of pids in @pids is oldest in pids[0] to youngest pid
> > > +	namespace in pids[nr_pids-1]. If the number of pids specified in the
> > 
> > In the sys_choosepid() discussion, Matt suggested it would be more
> > user-friendly to have the pid for the youngest pidns be pids[0].
> > That way the user doesn't have to know their pidns depth.
> 
> As far as I could see, Suka's solution also does not require knowing
> the pidns depth (aka level). He made it so that copy_from_user()
> adjusts its destination using the discrepancy between the number of
> pids passed and the number of levels.
> 
> If userspace passes an array with n pids and there are k namespace levels
> then clone_with_pids() makes sure that the kernel sees a pid array like:
> 
> index	  0     ... k - (n + 1)        ...          k - 1
> 	+-----------------------+-------------------------+
> pid_t	| 0 ..................0 | <copied from userspace> |
> 	+-----------------------+-------------------------+

(diagram assumes n != k. If n == k then pids[0] is the pid desired
in the initial namespace..)

> 
> So even though the order is different from choosepid() the calling
> task still doesn't need to know its pidns level. Of course, just
> like choosepid(), n <= k or userspace will get EINVAL.

Forgot to mention that I prefer the way choosepid orders the pids.
It's not inspired by the way that the kernel implements pid namespaces
and has more to do with the way userspace sees things (IMHO). I don't
know if it makes more sense to change clone_with_pids() or have
[e]glibc wrappers swap the array contents.

Cheers,
	-Matt Helsley
