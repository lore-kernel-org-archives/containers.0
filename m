From: Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>
Subject: nspawn and rocket.
Date: Mon, 7 Sep 2015 14:21:44 -0500
Message-ID: <55EDE3C8.2030704@landley.net>
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
To: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

I'm poking at adding the third layer of container support to toybox, by
which I mean I have unshare and nsenter, but need something to act as
the init process in the container to do the early I/O setup (filesystem
mounts, device import/export, network device setup, etc) that requires
interacting with the host.

At the plumber's container BOF I got pointed at systemd-nspawn, which is
apparently what Rocket is built on top of? As in rocket provides a bunch
of host-side plumbing, but the non-distro code that runs inside the
container for early bringup is essentially nspawn?

The nspawn webpage says that it's "just for testing" and that there's a
lot of other stuff you have to do to make it actually secure. Has
anybody documented what that stuff _is_? (Presumably rocket is layering
that on top of nspawn, and I want to implement something that rocket can
use but otherwise stays out of its way. I'd _really_ like it if I can
avoid having parse json.)

Does it sound like I'm on the right track here? Or should I just fluff
out nsenter a bit, implement tunctl, and not worry about nspawn?

Rob
