From: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: "hot plugging" filesystem mounts into running LXC containers
Date: Fri, 27 Jul 2012 17:07:12 +0100
Message-ID: <20120727160712.GZ2225@redhat.com>
Reply-To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

One of the things I've been thinking about in the context of libvirt's
LXC support, is how to support "hot plug" of new filesystem mounts
into a running container.

eg

 * mount host directory /export/bigdata at /var/www in a container
 * mount host device /dev/volgroup/bigdata at /var/www in a container
 * mount host file /export/bigdata.img at /var/www in a container

If the container & host OS share the same root filesystem this is
easy-ish:

  1. nsfd = open("/proc/self/ns/mounts")
  2. setns(nsfd, CLONE_NEWNS)
  3. mount("/export/bigdata", "/var/www", NULL, MS_BIND, NULL);

Also mounting devices it is easy, because assuming suitable cgroups
device ACL settings, the device nodes are not hidden from the process
doing the mount after setns().

The problem is what todo in the case that the container and host have
completely separated root filesystems, and you want to setup a new bind
mount. Step 3 would fail because /export/bigdata is not visible once
inside the container's mount namespace.

One random idea I had would be to enable mount based on a file
descriptor as the source, via an invented syscall

   mountat(fd, tgt, fstype, flags, data)

eg

  1. nsfd = open("/proc/self/ns/mounts")
  2. srcfd = open("/export/bigdata")
  2. setns(fd, CLONE_NEWNS)
  3. mountat(srcfd, "/var/www", NULL, MS_BIND, NULL);

An alternative would be if the container's mount namespace was actually
visible in the host. In theory /proc/$PID/root would be the thing to use,
but that doesn't actually give you a proper view into the container's
mount namespace. If /proc/$PID/root  did actually do the right thing,
then we could just do

  1. mountat("/export/bigdata", "/proc/$PID/root/var/www", NULL, MS_BIND, NULL);

Any other ideas / suggestions ?

Regards,
Daniel
-- 
|: http://berrange.com      -o-    http://www.flickr.com/photos/dberrange/ :|
|: http://libvirt.org              -o-             http://virt-manager.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: http://entangle-photo.org       -o-       http://live.gnome.org/gtk-vnc :|
