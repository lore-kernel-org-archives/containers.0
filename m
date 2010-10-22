From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 5/7] cgroups: Make freezer subsystem bindable
Date: Fri, 22 Oct 2010 14:57:08 -0700
Message-ID: <20101022215708.GM10119__27486.3617182293$1287785038$gmane$org@count0.beaverton.ibm.com>
References: <4CC146A4.9090505@cn.fujitsu.com> <4CC1473D.9070201@cn.fujitsu.com>
	<20101022205755.GJ10119@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20101022205755.GJ10119-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "akpm >> Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Oct 22, 2010 at 01:57:55PM -0700, Matt Helsley wrote:
> On Fri, Oct 22, 2010 at 04:11:41PM +0800, Li Zefan wrote:
> > To make it bindable, we need to thaw all processes when unbinding
> > the freezer subsystem from a cgroup hierarchy.
> > 
> > Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> 
> Based on experience using cgroups and questions we've fielded in the
> past on IRC I'd say users will really appreciate this.
> 
> We're planning to use the freezer in checkpoint/restart. Since
> checkpoint requires the tasks to remain frozen for the duration of
> the syscall we add a kernel-internal freezer subsystem interface
> which prevents the cgroup from thawing. So we'll need some way to
> "block" unbinding for that as well.

And in case you're curious here are the portions of the checkpoint/restart
tree which implement the above:

http://www.linux-cr.org/git/?p=linux-cr.git;a=commitdiff;h=a584c1c6b729a544c76cbb173ce62ffb6575b1d3
http://www.linux-cr.org/git/?p=linux-cr.git;a=commitdiff;h=34869146ecd662352c0024e0769ec77e643fb1e1

Cheers,
	-Matt Helsley
