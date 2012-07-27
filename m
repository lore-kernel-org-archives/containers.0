From: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Atomically changing NIC dev name + namespace ?
Date: Fri, 27 Jul 2012 17:28:25 +0100
Message-ID: <20120727162825.GB2225@redhat.com>
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

Another feature I'd like to provide in libvirt LXC is "hotplug" of NIC
devices to containers.

eg, I have a NIC eth1 in the host and I want to make it appear as eth0
in the container. There are two ways I can do this

  # ip link set eth1 name eth0
  # ip link set eth0 ns $PID

Or

  # ip link set eth1 ns $PID
  # setns --net $PID  (assume it opens /proc/$PID/ns/net & does setns(fd))
  # ip link set eth1 name eth0


Both these approaches suffer from flaws though. The first approach fails
on step one, if there is already another NIC in the host, that has the
same name as the target we want to use in the container. The second
approach fails on step 1 if there is already a NIC in the container
which has the same name as the original device on the host.

To get around this, we'd basically need to temporarily use a completely
random NIC name eg

  # ip link set eth1 name $RANDOMNAME
  # ip link set $RANDOMNAME ns $PID
  # setns --net $PID  (assume it opens /proc/$PID/ns/net & does setns(fd))
  # ip link set $RANDOMNAME name eth0

This is workable, but feels slightly unpleasant.  So IMHO if would be
desirable if the kernel allowed us to atomically change the NIC device
name and namespace at the same time. eg

  # ip link set eth1 name eth0 ns $PID

Although that 'ip' CLI syntax is allowed, it appears to implement it in
two steps, doing the rename first and then setting the namespace, so you
still hit the NIC name clash problem.

Regards,
Daniel
-- 
|: http://berrange.com      -o-    http://www.flickr.com/photos/dberrange/ :|
|: http://libvirt.org              -o-             http://virt-manager.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: http://entangle-photo.org       -o-       http://live.gnome.org/gtk-vnc :|
