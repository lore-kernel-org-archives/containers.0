From: Elwin Stelzer Eliazer <stelzere-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Using 127.n.x.x/16 for namespace to host
Date: Mon, 6 Jul 2009 15:46:20 -0700
Message-ID: <638f07d70907061546h5e017064t57ee22f45fa746b2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

I am using an internal bridge for internal socket communication between the
host and various containers' applications.
This is purely an internal bridge and no external traffic is expected in
this.
I can use a regular private ip address subnet for this, for example a
192.168.x.x/16 for this, and things are working.
But since the applications at the container and host handle external traffic
as well, we are forced to exclude this internal subnet for external use.
Using a 127.n.x.x/16 subnet is preferred, since that is not expected to be
used externally.
But this is requiring kernel code change, since 127.0.0.1/8 is programmed
for loopback interface 'lo' in host.
Towards this tried changing:
     IFF_LOOPBACK 0x10 // in in.h, changed from 0x8 to 0x10
     ifa->ifa_prefixlen = 16; // in devinet.c, changed from 8 to 16
And still do not see them connected.

Any suggestions on this will be appreciated.

regards,
Elwin.
