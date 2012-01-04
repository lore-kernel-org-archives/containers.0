From: Whit Blauvelt <whit-M6G8SDWvnhfby3iVrkZq2A@public.gmane.org>
Subject: lxc-console on Debian Squeeze - both 0.7.2 and 0.7.5 less than happy
Date: Wed, 4 Jan 2012 14:38:52 -0500
Message-ID: <20120104193852.GA22727@black.transpect.com>
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

Hi,

On a Debian Squeeze system I'm trying to run some Debian Squeeze containers.
I've been having trouble with lxc-console. Sometimes it connects fine. Other
times it doesn't. This is with the Squeeze version of LXC, unfortunately
only 0.7.2. So I wanted to see if 0.7.5 would be better. Installed from tar
to its default location. Symlinked /usr/local/var/lib/lxc to /var/lib/lxc
where I already had a couple of containers configured.

That's enough to get the containers to start from the 0.7.5 lxc-start. But
it leaves the 0.7.5 lxc-console totally unhappy. It's obviously looking at
things differently than lxc-start and lxc-info:

# lxc-info -n xfer
state:   RUNNING
pid:      1414

# lxc-console -n xfer
lxc-console: 'xfer' is stopped

The 'xfer' container is running, and can be connected to by SSH just fine.
But I'd like to get lxc-console working dependably. Again, with 0.7.2
(providing that the 0.7.2 lxc-start was used) it connects or fails to
seemingly randomly. It's an older version. Who cares? But how do I convince
the 0.7.5 version that what lxc-info can see, it should see too, and connect
with?

Thanks,
Whit
