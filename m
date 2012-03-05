From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 00/10] cgroups: Task counter subsystem v8
Date: Mon, 5 Mar 2012 04:21:33 +0100
Message-ID: <20120305032130.GD18143__11118.2074099363$1330917711$gmane$org@somewhere.redhat.com>
References: <1328067470-5980-1-git-send-email-fweisbec@gmail.com>
	<20120201163126.GA19837@google.com>
	<20120201184959.GH6731@somewhere.redhat.com>
	<20120201115107.93e11471.akpm@linux-foundation.org>
	<20120202145000.GC9071@somewhere.redhat.com>
	<4F4FFDE4.8050908@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4F4FFDE4.8050908-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>, Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>, Glauber Costa <glommer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, Daniel J Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Ulli Horlacher <framstag-otB+qtk3XKcL63KmMnjC+CEWGD4kr0XT@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Papp =?iso-8859-1?Q?Tam=E1s?= <tompos-Rh2PkUZwdwxYmEVqv0PRRg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Mar 01, 2012 at 11:53:24PM +0100, Daniel Lezcano wrote:
> On 02/02/2012 03:50 PM, Frederic Weisbecker wrote:
> >On Wed, Feb 01, 2012 at 11:51:07AM -0800, Andrew Morton wrote:
> >>On Wed, 1 Feb 2012 19:50:01 +0100
> >>Frederic Weisbecker<fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>  wrote:
> >>
> >>>On Wed, Feb 01, 2012 at 08:31:26AM -0800, Tejun Heo wrote:
> >>>>On Wed, Feb 01, 2012 at 04:37:40AM +0100, Frederic Weisbecker wrote:
> >>>>>Changes In this version:
> >>>>>
> >>>>>- Split 32/64 bits version of res_counter_write_u64() [1/10]
> >>>>>   Courtesy of Kirill A. Shutemov
> >>>>>
> >>>>>- Added Kirill's ack [8/10]
> >>>>>
> >>>>>- Added selftests [9/10], [10/10]
> >>>>>
> >>>>>Please consider for merging. At least two users want this feature:
> >>>>Has there been further discussion about this approach?  IIRC, we
> >>>>weren't sure whether this should be merged.
> >>>The doubts I have noticed were:
> >>>
> >>>Q: Can't we rather focus on a global solution to fight forkbombs?
> >>>
> >>>If we can find a reliable solution that works in any case and that
> >>>prevent from any forkbomb to impact the rest of the system then it
> >>>may be an acceptable solution. But I'm not aware of such feature.
> >>>
> >>>Besides, another point in having this task counter is that we
> >>>have a per container limit. Assuming all containers are running under
> >>>the same user, we can protect against a container starving all others
> >>>with a massive amount of processes close to the NR_PROC rlimit.
> >>>
> >>>Q: Can/should we implement a limitation on the number of "fork" as well?
> >>>    (as in https://lkml.org/lkml/2011/11/3/233 )
> >>>
> >>>I'm still not sure about why such a thing is needed. Is it really something we
> >>>want? Why can't the task counter be used instead?
> >>>
> >>>I need more details from the author of this patch. But I doubt we can merge
> >>>both subsystems, they have pretty different semantics.
> >>What I struggle with is "is this feature useful enough to warrant
> >>merging it"?
> >The reason why I've been working on it is because we need this feature
> >(at least) for LXC.
> 
> This feature is a recurrent request from the users of LXC. Recently,
> a container administrator complained an user was able to crash the
> entire host from a container.
> 
> http://sourceforge.net/mailarchive/message.php?msg_id=28915923
> 
> This feature is really useful to make the containers secure.

Time for me to try to wake up again this discussion.
Andrew, Tejun, Li, as you can see we don't lack the users
for this feature.

If you think we should solve our security problems on containers
by following another direction, please tell us so we know where to
go and we can move forward.

Otherwise please consider the task counter for merging.

Thanks.
