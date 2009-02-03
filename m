From: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: cgroup mount point
Date: Tue, 3 Feb 2009 13:26:08 +0000
Message-ID: <20090203132608.GA15613__3423.03410075164$1233667793$gmane$org@redhat.com>
References: <20090202200013.GU3643@vespa.holoscopio.com>
	<1233606371.15779.32.camel@radis.liafa.jussieu.fr>
	<20090202205246.GA28593@glandium.org>
	<20090202214153.GV3643@vespa.holoscopio.com>
	<20090203102416.GA8886@redhat.com>
	<20090203123028.GA3788@vespa.holoscopio.com>
Reply-To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090203123028.GA3788-StA3NKSgq9XYLCA8tIpKU1aTQe2KTcn/@public.gmane.org>
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

On Tue, Feb 03, 2009 at 10:30:28AM -0200, Thadeu Lima de Souza Cascardo wrote:
> Sorry. I didn't mean to imply that libvirt or Fedora did anything in
> respect to the mountpoint themselves. But that they are supporting or
> planning to support cgroups. And I think that one time we will need to
> sort the problem of the mountpoint, either let the applications mount it
> (in this case, libvirt) or the system do it (Fedora install, Debian
> initscripts, et al).
>
> I have some experience with lxc tools from http://lxc.sf.net/ and these
> tools also look up the mountpoint at /proc/mounts. So it is up to the
> system or the user to mount it.

That's good. We settled on letting mount points be OS / admin defined
in libvirt, because we felt libvirt shouldn't try to impose a mount
policy on a resource that will have many users & we are able to work
with whatever mount hierarchy the admin / OS decided to setup.

> > Putting new mount points in / is not really acceptable, so that rules
> > out the first two. /opt is just totally wrong, since that is intended
> > for add on software packages. /dev/ feels a little odd, since it is
> > not really device nodes, but perhaps that doesn't matter. So my pref
> > would be something in /dev/cgroups or /sys/cgroups
> 
> My suggestions were /proc/cgroup, /sys/cgroup, /cgroup or /dev/cgroup. I
> sent the problems with the former two, and the rationale for the latter
> two in a previous message.
> 
> I agree that /opt/ is not the place for it (and that's the one I called
> 'funny'). I've head some people telling that /dev/ is for devices, but I
> can't see a problem (/dev/log is a socket and it is there, the FHS
> refers to special files).
> 
> /proc/ and /sys/ are two good options if the kernel does not put anything
> else there. /proc/cgroups already exist, for example.
> 
> Could you please give your rationale why / is not really acceptable?
 
Just a general preference is to not continually add more ad-hoc top 
level directories to /, when there are other places in the filesystem
hierarchy that are available, such as /sys or /proc. 

> > I also think 'cgroups' is a better name than 'containers', since 
> > 'containers' is refering to just one specific use case.
> 
> Agreed on this one, although I still prefer the singular (it is also the
> name of the filesystem type).

Either singular / plural sounds fine to me

Regards,
Daniel
-- 
|: Red Hat, Engineering, London   -o-   http://people.redhat.com/berrange/ :|
|: http://libvirt.org  -o-  http://virt-manager.org  -o-  http://ovirt.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: GnuPG: 7D3B9505  -o-  F3C9 553F A1DA 4AC2 5648 23C1 B3DF F742 7D3B 9505 :|
