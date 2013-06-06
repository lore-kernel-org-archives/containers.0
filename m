From: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Requirements for CAP_SYS_ADMIN on setns() ?
Date: Thu, 6 Jun 2013 11:01:49 +0100
Message-ID: <20130606100149.GG30217@redhat.com>
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

IIUC, currently, in order to be able to invoke setns() the calling
process is required to have CAP_SYS_ADMIN capability. Alternatively
with user namespaces, access is allowed if the process' effective
uid matches the uid of the owner of the namespace.

I have a scenario though that isn't dealt with by those rules. I have
a container that was spawned by uid == 0, and I have an unprivileged
process uid != 0 in the initial namespace that I wish to allow to enter
the namespaces associated with the container.

With the CAP_SYS_ADMIN rule on setns(), it seems that the unprivileged
process will need to execute some setuid binary in order to gain the
CAP_SYS_ADMIN capability required to call setns().

Of course you can't call setns() without first obtaining a file
descriptor corresponding to the /proc/$CONTAINERPID/ns/XXXX namespace
you wish to join. This appears to require elevated privileges too.

Is it not sufficient to rely on the permissions on the /proc/$PID/ns/XXX
file to control access to a namespace, and thus allow setns() without
a CAP_SYS_ADMIN check ?   ie setns() is basically useless unless you
already have sufficient privileges to get a file descriptor for the
namespace, so why does setns need an additional privilege check beyond
that done at time of open() on the proc file.

In my scenario this would allow for a privileged daemon to open the
/proc/$PID/ns/XXX file, and then pass the file descriptor back to the
unprivileged process using SCM_RIGHTS, which could then invoke setns().
This kind of privilege separation is perferrable to requiring the
unprivileged process to run some kind of setuid program to gain the
CAP_SYS_ADMIN capability.

Regards,
Daniel
-- 
|: http://berrange.com      -o-    http://www.flickr.com/photos/dberrange/ :|
|: http://libvirt.org              -o-             http://virt-manager.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: http://entangle-photo.org       -o-       http://live.gnome.org/gtk-vnc :|
