From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.11 1/3] cgroup: mark "tasks" cgroup file as
	insane
Date: Fri, 7 Jun 2013 13:05:19 -0700
Message-ID: <20130607200519.GB14781@mtj.dyndns.org>
References: <20130604021302.GH29989@mtj.dyndns.org>
	<20130604111556.GA4963@redhat.com>
	<20130604201947.GE14916@htj.dyndns.org>
	<20130606092055.GF30217@redhat.com>
	<20130606211410.GF5045@htj.dyndns.org>
	<20130607051040.GA1364@tango.0pointer.de>
	<20130607093050.GA10742@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130607093050.GA10742-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kay.sievers-tD+1rO4QERM@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Daniel.

On Fri, Jun 07, 2013 at 10:30:50AM +0100, Daniel P. Berrange wrote:
> > Uhm. So I don't think we will support two ways to set this up for long
> > in systemd (if at all). And even if we did, the distributions would pick
> > one or the other as default, and if you are unlucky, then you couldn't
> > run libvirt on it without reconfiguration and rebooting to get the other
> > cgroup setup logic...
> 
> Yep, that's exactly what concerns me. If systemd introduced the option

I don't think you two are speaking about the same problem.  Lennart is
saying that backward compat option won't stay for long and you're
worrying about the method to enable compatibility mode.

> for a new style setup, then it would almost certainly be adopted by
> default by Fedora (otherwise there's no point adding it). At which
> point libvirt is doomed. We can't require people to reconfigure systemd
> and reboot to use virt.

Yeah, it's cumbersome, but if it's pressing we can make the release of
controllers from unified hierarchy dynamic I suppose.  I'll think more
about it.

Thanks.

-- 
tejun
