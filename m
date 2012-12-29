From: Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH/RFC] user_ns: fix missing limiting of user_ns counts
Date: Sat, 29 Dec 2012 09:22:34 +0400
Message-ID: <20121229052234.GA4153@cachalot>
References: <20121228175627.GA7683@cachalot>
 <87wqw15wqb.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87wqw15wqb.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Dec 28, 2012 at 20:05 -0800, Eric W. Biederman wrote:
> Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org> writes:
> 
> > Currently there is completely no limiting in number of user namespaces
> > created by unprivileged users.  One can freely create thousands of
> > user_ns'es and exhaust kernel memory without even bumping in
> > RLIMIT_NPROC or similar.
> 
> First for a proper sense of scale it will take roughly 14,000 to consume
> a megabyte.  So it will take hundreds of millions of user namespaces to
> eat up all of kernel memory.

Yes, but you can freely create *any* number of nested userns by a loop:

    for() {
        unshare()
        write to /proc/self/{u,g}id_map
    }

> > The code needs several checks.  First, noone should be able to create
> > user_ns of arbitrary depth.  Besides kernel stack overflow one could
> > create too big depth to DoS processes belonging to other users by
> > forcing them to loop a long time in cap_capable called from some
> > ns_capable() (e.g. in case one does smth like "ls -R /proc").
> 
> Where do you get a ns_capable call from "ls -R /proc" ?

E.g. if procfs is mounted with hidepid=2 then ls does
ptrace_may_access() check. 

Thanks,

-- 
Vasily Kulikov
http://www.openwall.com - bringing security into open computing environments
