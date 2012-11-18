From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCHSET cgroup/for-3.8] netcls_cgroup: implement hierarchy
	support
Date: Sun, 18 Nov 2012 06:25:34 -0800
Message-ID: <20121118142534.GF7306__29973.9142567434$1353248757$gmane$org@mtj.dyndns.org>
References: <1353123062-23193-1-git-send-email-tj@kernel.org>
	<20121117.220421.1904738911212014470.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121117.220421.1904738911212014470.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, tgraf-G/eBtMaohhA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

On Sat, Nov 17, 2012 at 10:04:21PM -0500, David Miller wrote:
> > This patchset implements proper hierarchy support for netcls_cgroup.
> > Pretty simliar to the netprio one[3].  Simpler as each cgroup has
> > single config value instead of array of them.
> > 
> > This patchset contains the following three patches.
> > 
> >  0001-netcls_cgroup-introduce-netcls_mutex.patch
> >  0002-netcls_cgroup-introduce-cgroup_cls_state-is_local.patch
> >  0003-netcls_cgroup-implement-proper-hierarchy-support.patch
> > 
> > This patchset is on top of
> 
> I guess you therefore want to put it through your cgroup tree?

Yeap.

> Acked-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

Great, I forgot to cc you on netprio_cgroup changes.  It's similar to
this one but larger partly because the configuration is per
cgroup-netdev pair.  Would it be okay to route the following through
the cgroup tree?

  https://lkml.org/lkml/2012/11/16/514

Thanks.

-- 
tejun
