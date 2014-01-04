From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 0/4] x86: Add Cache QoS Monitoring (CQM) support
Date: Sat, 4 Jan 2014 17:50:58 -0500
Message-ID: <20140104225058.GC24306@htj.dyndns.org>
References: <1388781285-18067-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
	<20140104161050.GA24306@htj.dyndns.org>
	<1388875369.9761.25.camel@ppwaskie-mobl.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1388875369.9761.25.camel-29DAm2eTeB2q+SSgkFU3IPooFf0ArEBIu+b9c/7xato@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, "cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

On Sat, Jan 04, 2014 at 10:43:00PM +0000, Waskiewicz Jr, Peter P wrote:
> Simply put, when we want to allocate an RMID for monitoring httpd
> traffic, we can create a new child in the subsystem hierarchy, and
> assign the httpd processes to it.  Then the RMID can be assigned to the
> subsystem, and each process inherits that RMID.  So instead of dealing
> with assigning an RMID to each and every process, we can leverage the
> existing cgroup mechanisms for grouping processes and their children to
> a group, and they inherit the RMID.

Here's one thing that I don't get, possibly because I'm not
understanding the processor feature too well.  Why does the processor
have to be aware of the grouping?  ie. why can't it be done
per-process and then aggregated?  Is there something inherent about
the monitored events which requires such peculiarity?  Or is it that
accessing the stats data is noticieably expensive to do per context
switch?

> Please let me know if this is a better explanation, and gives a better
> picture of why we decided to approach the implementation this way.  Also
> note that this feature, Cache QoS Monitoring, is the first in a series
> of Platform QoS Monitoring features that will be coming.  So this isn't
> a one-off feature, so however this first piece gets accepted, we want to
> make sure it's easy to expand and not impact userspace tools repeatedly
> (if possible).

In general, I'm quite strongly opposed against using cgroup as
arbitrary grouping mechanism for anything other than resource control,
especially given that we're moving away from multiple hierarchies.

Thanks.

-- 
tejun
