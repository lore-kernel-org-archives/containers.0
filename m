From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCHSET] cgroup, memcg: introduce sane_behavior mount option
Date: Mon, 15 Apr 2013 07:46:33 -0700
Message-ID: <20130415144633.GD13662__13948.1001104743$1366037201$gmane$org@dhcp22.suse.cz>
References: <1365808259-31073-1-git-send-email-tj@kernel.org>
	<20130415031754.GG3050@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130415031754.GG3050-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun 14-04-13 20:17:54, Tejun Heo wrote:
> On Fri, Apr 12, 2013 at 04:10:55PM -0700, Tejun Heo wrote:
> > To make progress, those behaviors need to go but we can't simply drop
> > or change the crazies as those are directly visible to userland.  This
> > patchset implements a mount option - sane_behavior - which turns on
> > new saner behaviors, so that we can keep providing the old behaviors
> > while and after transitioning to saner ones.
> 
> Applied 1-3 to cgroup/for-3.10.  Michal, I left the last memcg one
> out.  Please let me know how you wanna route it.

You can route it via your tree as it seems like the simplest way.

Thanks!
-- 
Michal Hocko
SUSE Labs
