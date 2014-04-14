From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHSET cgroup/for-3.15] cgroup: implement unified hierarchy
Date: Mon, 14 Apr 2014 14:14:21 -0400
Message-ID: <20140414181421.GC9552@redhat.com>
References: <1395974461-12735-1-git-send-email-tj@kernel.org>
	<20140414154556.GA9552@redhat.com>
	<20140414175236.GB15249@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140414175236.GB15249-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Apr 14, 2014 at 01:52:36PM -0400, Tejun Heo wrote:
> Hello,
> 
> On Mon, Apr 14, 2014 at 11:45:56AM -0400, Vivek Goyal wrote:
> > So this patchset does not *enforce* a single hierarchy? So user space
> > can still mount other hierarchies.
> 
> Nope, nothing is forced.  Controllers may be moved between unified and
> traditional multiple hierarchies.

So is this an intermediate mode before we move to single hiearchy *only*
mode. AFAIK, you had mentioned that we will support legacy multiple
hiearchy mode but single hiearchy is the new default mode.

How does one figure out which one is unified hiearchy (out of multiple
hierarchies). Is there a flag somewhere? Or sane flag will be used to
mark unified hiearchy.

> 
> > How does this work for root's tasks now? Given that task can only be
> > in leaf cgroups, that means tasks can't be in / cgroup (If one wants
> > to create some cgroups). Does that mean / will be empty and init system
> > need to setup things right.
> 
> Root is exempt from the restriction.  Root has always been special
> anyway.

So task and child groups can co-exist in root *only*?

> 
> I'll soon post a document describing the design and restrictions of
> unified hierarchy along with an updated version of this patchset.

That would help a lot in understanding various modes and that in
turn will help with patch reviews too.

Thanks
Vivek
