From: Jan Stancek <jstancek-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Suggestion] kernel: cgroup: mount failure in LTP
	cgroup_regression_test.sh
Date: Thu, 21 Nov 2013 18:13:01 -0500 (EST)
Message-ID: <1639659702.38807133.1385075581222.JavaMail.root@redhat.com>
References: <527C9D9B.8090802@asianux.com>
	<20131120173549.GO28946@htj.dyndns.org>
	<528D6E19.4080100@gmail.com> <528D89AA.6080102@gmail.com>
	<551116969.38084288.1385021094494.JavaMail.root@redhat.com>
	<20131121152645.GB3352@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20131121152645.GB3352-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Chen Gang <gang.chen.5i5j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Garrett Cooper <yanegomi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, mitani-Czb31pHLG9l3+QwDJ9on6Q@public.gmane.org, chris-8NJIiSa5LzA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gaowanlong-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
List-Id: containers.vger.kernel.org





----- Original Message -----
> From: "Tejun Heo" <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> To: "Jan Stancek" <jstancek-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: "Chen Gang" <gang.chen.5i5j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "Garrett Cooper" <yanegomi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, gaowanlong-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org,
> chris-8NJIiSa5LzA@public.gmane.org, mitani-Czb31pHLG9l3+QwDJ9on6Q@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, "Li Zefan" <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
> containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Sent: Thursday, 21 November, 2013 4:26:45 PM
> Subject: Re: [Suggestion] kernel: cgroup: mount failure in LTP cgroup_regression_test.sh
> 
> Hello, Jan.
> 
> On Thu, Nov 21, 2013 at 03:04:54AM -0500, Jan Stancek wrote:
> > it looks like those 2 subsystems are already mounted by systemd,
> > each in different hierarchy:
> > 
> > >   cpuacct	4	35	1
> > >   freezer	5	4	1
> > 
> > from Documentation/cgroups/cgroups.txt:
> > "If an active hierarchy with exactly the same set of subsystems already
> > exists, it will be reused for the new mount. If no existing hierarchy
> > matches, and any of the requested subsystems are in use in an existing
> > hierarchy, the mount will fail with -EBUSY. Otherwise, a new hierarchy
> > is activated, associated with the requested subsystems."
> 
> Ah, cgroup now requires that those recycled mounts to have matching
> options.  This is an intended behavior change because previously we
> could end up with mounts which have actual options which differ from
> what was specified by mount, which can be misleading at the very
> least.

I believe the test always respected this requirement. Problem we see
is because of initial state of the system. Test appears to expect
that it is able to mount cgroups freely, but they are already in use.

> Would it be possible to update LTP accordingly?

I'm not sure the test can do anything (other than not run at all).

Other option is to setup system in a way where cgroups are not in use
prior to running this test, though this may not be possible with systemd.

Regards,
Jan

> 
> Thanks.
> 
> --
> tejun
> 
