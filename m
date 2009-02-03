From: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: cgroup mount point
Date: Tue, 3 Feb 2009 10:24:16 +0000
Message-ID: <20090203102416.GA8886__29914.9600476541$1233656906$gmane$org@redhat.com>
References: <20090202200013.GU3643@vespa.holoscopio.com>
	<1233606371.15779.32.camel@radis.liafa.jussieu.fr>
	<20090202205246.GA28593@glandium.org>
	<20090202214153.GV3643@vespa.holoscopio.com>
Reply-To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090202214153.GV3643-StA3NKSgq9XYLCA8tIpKU1aTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: debian-devel-0aAXYlwwYIJuHlm7Suoebg@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Feb 02, 2009 at 07:41:53PM -0200, Thadeu Lima de Souza Cascardo wrote:
> On Mon, Feb 02, 2009 at 09:52:46PM +0100, Mike Hommey wrote:
> > On Mon, Feb 02, 2009 at 09:26:11PM +0100, Julien Cristau wrote:
> > > On Mon, 2009-02-02 at 18:00 -0200, Thadeu Lima de Souza Cascardo wrote:
> > > > Hello,
> > > > 
> > > > Some software I intend to package work with the new cgroup feature in
> > > > Linux. I would like to open a discussion about what would be the better
> > > > place to mount it and how/when to mount it.
> > > 
> > > What do other distros use?
> > 
> > Even better: what do the kernel folks want to do?
> > 
> > Mike
> 
> From what I've seen, most of them are in the same phases as Debian, or,
> perhaps, behind. Fedora seems to plan that for Fedora 11, and they have
> some support in libvirt.

libvirt is not going to impose any policy for mount points, nor mount
anything itself. When we use cgroups, libvirt just looks up the mount
table to find out where the admin or distro has put the mount points
for each cgroups controller.

I've also not done anything in default Fedora install to automatically
setup cgroups, since doing that hits the hard-to-answer question of
whether to mount all controllers in one, or a separate mount per
controller, or a hybrid.

> So, we have some more options now: /cgroups, /containers, /dev/cpuset,
> /dev/cpuctl, /opt/cgroup, /opt/cpuset.

Putting new mount points in / is not really acceptable, so that rules
out the first two. /opt is just totally wrong, since that is intended
for add on software packages. /dev/ feels a little odd, since it is
not really device nodes, but perhaps that doesn't matter. So my pref
would be something in /dev/cgroups or /sys/cgroups

I also think 'cgroups' is a better name than 'containers', since 
'containers' is refering to just one specific use case.

Regards,
Daniel
-- 
|: Red Hat, Engineering, London   -o-   http://people.redhat.com/berrange/ :|
|: http://libvirt.org  -o-  http://virt-manager.org  -o-  http://ovirt.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: GnuPG: 7D3B9505  -o-  F3C9 553F A1DA 4AC2 5648 23C1 B3DF F742 7D3B 9505 :|
