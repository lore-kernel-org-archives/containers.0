From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [Workman-devel] cgroup: status-quo and userland efforts
Date: Tue, 23 Jul 2013 16:48:16 +0200
Message-ID: <20130723144816.GK8677__29302.9165048667$1374590912$gmane$org@dhcp22.suse.cz>
References: <1372311907.5871.78.camel@marge.simpson.net>
	<20130627180143.GD5599@mtj.dyndns.org>
	<1372391198.5989.110.camel@marge.simpson.net>
	<20130628040930.GC2500@htj.dyndns.org>
	<1372394950.5989.128.camel@marge.simpson.net>
	<20130628050138.GD2500@htj.dyndns.org>
	<20130628150513.GD5125@dhcp22.suse.cz>
	<20130628180155.GD16483@redhat.com>
	<20130630183838.GB23731@dhcp22.suse.cz>
	<20130715184940.GG27338@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130715184940.GG27338-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>, Mike Galbraith <bitbucket-BGeptl67XyCzQB+pC5nmwQ@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, lpoetter <lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "dhaval.giani" <dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, workman-devel <workman-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon 15-07-13 14:49:40, Vivek Goyal wrote:
> On Sun, Jun 30, 2013 at 08:38:38PM +0200, Michal Hocko wrote:
> > On Fri 28-06-13 14:01:55, Vivek Goyal wrote:
> > > On Fri, Jun 28, 2013 at 05:05:13PM +0200, Michal Hocko wrote:
> > [...]
> > > > OK, so libcgroup's rules daemon will still work and place my tasks in
> > > > appropriate cgroups?
> > > 
> > > Do you use that daemon in practice?
> > 
> > I am not but my users do. And that is why I care.
> 
> Michael, 
> 
> would you have more details of how those users are exactly using
> rules engine daemon.

The most common usage is uid and exec names.

> To me rulesengined processed 3 kinds of rules.
> 
> - uid based
> - gid based
> - exec file path based
> 
> uid/gid based rule exection can be taken care by pam_cgroup module too.
> So I think one should not need cgrulesengined for that.

I am not familiar with pam_cgroup much but it is a part of libcgroup
package, right?

> I am curious what kind of exec rules are useful. Any placement of
> services one can do using systemd. So only executables we are left
> to manage are which are not services. 

Yes, those are usually backup processes which should not disrupt the
regular server workload.

uid ones are used to keep a leash on local users of the machine but i do
not have many details as I usually do not have access to those machines.
All I see are complains when something explodes ;)
-- 
Michal Hocko
SUSE Labs
