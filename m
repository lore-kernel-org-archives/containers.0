From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH] cgroup: don't show pid list on tasks/procs in ascending
	order
Date: Tue, 15 Jan 2013 00:34:12 -0600
Message-ID: <20130115063412.GA25338__39676.5330493965$1358231681$gmane$org@sergelap>
References: <50F4E902.20202@oracle.com> <20130115062507.GA21358@sergelap>
	<50F4F76D.2050409@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <50F4F76D.2050409-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jeff Liu <jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Jeff Liu (jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org):
> On 01/15/2013 02:25 PM, Serge Hallyn wrote:
> > Quoting Jeff Liu (jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org):
> >> Hello,
> >>
> >> Currently, the pid list shown on cgroup->procs & tasks is in ascending order.  However, this list is not
> >> guaranteed to be sorted according to the following records mentioned at Documentation/cgroups/cgroups.txt.
> >>
> >>  - tasks: list of tasks (by PID) attached to that cgroup.  This list
> >>    is not guaranteed to be sorted. 
> >>  - cgroup.procs: list of thread group IDs in the cgroup.  This list is
> >>    not guaranteed to be sorted or free of duplicate TGIDs, and userspace
> >>    should sort/uniquify the list if this property is required.
> >>
> >> This patch remove the sorting function to make the default behavior of pid list be consistent with
> >> the document.

...

I've gotta say, as someone who tends to play with those files by hand, I
don't mind not having to type | sort | uniq every time.

-serge
