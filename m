From: Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH/RFC] user_ns: fix missing limiting of user_ns counts
Date: Fri, 28 Dec 2012 23:04:35 +0400
Message-ID: <20121228190435.GA8690@cachalot>
References: <20121228175627.GA7683@cachalot>
	<20121228184334.GZ4939@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121228184334.GZ4939-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Dec 28, 2012 at 18:43 +0000, Al Viro wrote:
> On Fri, Dec 28, 2012 at 09:56:27PM +0400, Vasily Kulikov wrote:
> > The included patch is a basic fix for both or them.  Both values are
> > hardcoded here to 100 max depth and 1000 max in total.  I'm not sure how
> > better to make them configurable.  Looks like it needs some sysctl value
> > like kernel.max_user_ns_per_user, but also something more configurable
> > like new rlimit'ish limit may be created for user_ns needs.  E.g. in
> > case root wants one user to contain hundreds of private containers
> > (container owner user), but he doesn't want anybody to fill the kernel
> > with hundreds of containers multiplied by number of system users (equals
> > to thousands).
> 
> I'm sorry, but this is not a solution.  Kernel is not x86-only; there are
> architectures with far bigger minimal stack frame size.  E.g. on sparc64
> every fucking stack frame is at least 176 bytes.  So your 100 calls deep
> call chain will happily overflow the damn stack all by itself - kernel
> stack on sparc64 is 16Kb total, including struct thread_info living there.

Understood.  How to properly fix it then?  Looks like there are quite
many kernel structures which may reference other structures which
indirectly reference each other via kref, IOW it is not user_ns specific
issue.  With unprivileged user_ns the way it should be freed must be
somehow changed.

Thanks,

-- 
Vasily Kulikov
http://www.openwall.com - bringing security into open computing environments
