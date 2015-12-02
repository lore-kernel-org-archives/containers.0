From: "Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 7/8] cgroup: mount cgroupns-root when inside non-init
	cgroupns
Date: Wed, 2 Dec 2015 11:02:39 -0600
Message-ID: <20151202170239.GA21009__9254.20071366734$1449075779$gmane$org@mail.hallyn.com>
References: <1447703505-29672-8-git-send-email-serge@hallyn.com>
	<20151124171610.GS17033@mtj.duckdns.org>
	<20151127051745.GA24521@mail.hallyn.com>
	<20151130150938.GF3535@mtj.duckdns.org>
	<20151201040704.GA31067@mail.hallyn.com>
	<20151201164649.GD12922@mtj.duckdns.org>
	<20151201215853.GA9153@mail.hallyn.com>
	<20151202165312.GB19878@mtj.duckdns.org>
	<20151202165637.GA20840@mail.hallyn.com>
	<20151202165839.GD19878@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20151202165839.GD19878-qYNAdHglDFBN0TnZuCh8vA@public.gmane.org>
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
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, lxc-devel-cunTk1MwBs9qMoObBWhMNEqPaTDuhLve2LY78lusg7I@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Dec 02, 2015 at 11:58:39AM -0500, Tejun Heo wrote:
> On Wed, Dec 02, 2015 at 10:56:37AM -0600, Serge E. Hallyn wrote:
> > Can it be flushed when we know that the cgroup is being pinned by
> > a css_set?  (There's either a task or a cgroup_namespace pinning it
> > or we wouldn't get here)
> 
> Yeap, it can be flushed.  There's no ref coming out of cgroup to the
> vfs objects.

Ok, thanks.  Still seems to me to be more work to actually walk the
path ourselves, but I'll go that route and see what it looks like :)

thanks
-serge
