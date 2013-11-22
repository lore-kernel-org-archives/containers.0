From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [Suggestion] kernel: cgroup: mount failure in LTP
	cgroup_regression_test.sh
Date: Fri, 22 Nov 2013 00:49:20 -0500
Message-ID: <20131122054920.GA32700__15584.7013149925$1385099377$gmane$org@mtj.dyndns.org>
References: <527C9D9B.8090802@asianux.com>
	<20131120173549.GO28946@htj.dyndns.org>
	<528D6E19.4080100@gmail.com> <528D89AA.6080102@gmail.com>
	<551116969.38084288.1385021094494.JavaMail.root@redhat.com>
	<20131121152645.GB3352@htj.dyndns.org>
	<1639659702.38807133.1385075581222.JavaMail.root@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1639659702.38807133.1385075581222.JavaMail.root-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jan Stancek <jstancek-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Chen Gang <gang.chen.5i5j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Garrett Cooper <yanegomi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, mitani-Czb31pHLG9l3+QwDJ9on6Q@public.gmane.org, chris-8NJIiSa5LzA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gaowanlong-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

On Thu, Nov 21, 2013 at 06:13:01PM -0500, Jan Stancek wrote:
> I believe the test always respected this requirement. Problem we see
> is because of initial state of the system. Test appears to expect
> that it is able to mount cgroups freely, but they are already in use.
> 
> > Would it be possible to update LTP accordingly?
> 
> I'm not sure the test can do anything (other than not run at all).
> 
> Other option is to setup system in a way where cgroups are not in use
> prior to running this test, though this may not be possible with systemd.

You can tell systemd to not mount any controllers.

Thanks.

-- 
tejun
