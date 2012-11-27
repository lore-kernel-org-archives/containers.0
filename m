From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Mapping between host & container PIDs ?
Date: Tue, 27 Nov 2012 15:49:31 -0600
Message-ID: <87y5hmhg2c.fsf@xmission.com>
References: <20121127101555.GE24370@redhat.com>
	<20121127133609.GC3727@sergelap> <20121127134759.GL24370@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121127134759.GL24370-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (Daniel P. Berrange's message
	of "Tue, 27 Nov 2012 13:47:59 +0000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

"Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> Thinking about it more generally, this isn't really a container specific
> problem, but rather an issue with the kill() syscall. It is the same
> general class of problem as you see checking file permissions for example,
> which is why you would use fstat() instead of stat() in many cases. It
> might call for a way to get a FD associated with a pid (eg the /proc/$pid
> dir handle) and then be able to kill() via that FD. eg something like
>
>
>   dirfd = open("/proc/$pid", O_RDONLY);
>
>   exefd = openat(dirfd, "exe", O_RDONLY);
>   ...check it is the exe you think it is...
>
>   cgroupfd = openat(dirfd, "cgroups", O_RDONLY);
>   ...check the process is where you expect it to be...
>
>   fkill(dirfd, SIG_KILL)
>
> that's probably a whole can of worms though, so I think i'll just
> restrict myself to killing processes based on the container's view
> of the PID for now.

Yes that is the general solution.  It is very reasonable to have a proc
file that you can write to that will send a signal to it's process.

I keep thinking it will be worth implementing one of these days.

Eric
