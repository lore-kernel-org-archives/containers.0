From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Thu, 23 Feb 2012 09:33:48 -0800
Message-ID: <20120223173348.GD22536__10467.5778341063$1330018441$gmane$org@google.com>
References: <20120221211938.GE12236@google.com>
	<4F45F742.1060605@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4F45F742.1060605-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Li.

On Thu, Feb 23, 2012 at 04:22:26PM +0800, Li Zefan wrote:
> > The following is a "best practices" document on using cgroups.
> > 
> >   http://www.freedesktop.org/wiki/Software/systemd/PaxControlGroups
> > 
> > To me, it seems to demonstrate the rather ugly situation that the
> > current cgroup is providing.  Everyone should tip-toe around cgroup
> > hierarchies and nobody has full knowledge or control over them.
> > e.g. base system management (e.g. systemd) can't use freezer or task
> > counter as someone else might want to use it for different hierarchy
> > layout.
> > 
> 
> This issue still exists if we allow a single hierarchy only, right?
> Different cgroup users/applications have to struggle not to step
> on each other's toe.

Oh sure, having single hierarchy doesn't solve that problem but makes
it clear that there's single representation that kernel understands
and deals with.  I think the problem now is that kernel tries to
multiplex multiple users.  Unfortunately, it does that half-way and
badly and I think the nature of the problem doesn't really allow
proper muxed interface at kernel layer.  So, I'm suggesting to let go
of the broken pretense and just have a single unified interfce and let
userland deal with resource allocation policies.

Thanks.

-- 
tejun
