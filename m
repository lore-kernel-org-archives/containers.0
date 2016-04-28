From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Unprivileged containers and co-ordinating user namespaces
Date: Thu, 28 Apr 2016 15:02:08 -0700
Message-ID: <1461880928.2307.48.camel@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, util-linux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org
List-Id: containers.vger.kernel.org

It's always been annoying to me that we never co-ordinate our use of
namespace resources, but it's never really mattered until the user
namespace came along because namespaces didn't overlap and the only
annoyance was not being able to use existing tools to manipulate other
containers (mainly not being able to us ip netns).

However, with the user namespace, it's become necessary to co-ordinate
if you're giving users a range of uids beyond their own because you
don't want to have two separate container users owning overlapping uid
numbers (especially if they're unprivileged) because that will lead to
all sorts of security issues.  I think we need two things: a file
describing this for other things (like container orchestration systems
that want to know) and a mechanism for delegating the alloted uids to
the user.  One possible way of doing this would be to have the init
system set up the correctly owned user namespace at boot time.  It's
appealing to have the user sort out their own administration by simply
spawning new child user namespaces, but it adds the complexity that we
have to know what we're mapping to inside the namespace, whereas all
the administrator really cares about is what exterior uid range is
allocated (and that it remain that same range between reboots, because
these are the uids that's going to appear on disk).

Assuming everyone agrees it's a file and a utility, I'd propose the
file be

/etc/usernamespaces

and the format be <user>:<start>:<length>:<flags>

For the allocated uids.  <user>,<start> and <length> are obvious but
<flags> would be used for things like deny setgroups and possibly other
privilege reductions.

Then we need a utility, say userns that has cap_setuid+cap_setgid and
takes as an argument the raw uid_map, gid_map the user wants to install
plus similar arguments to unshare.  It then validates that the exterior
range are allowed by /etc/usernamespaces and sets up the usernamespace
with that range owned by the invoking user.

Container orchestration systems can either register their (probably
huge) ranges in the file, or simply use the file to know what ranges to
avoid.

If this sounds OK to people, I can code up a utility that does this,
which should probably belong in util-linux.

James
