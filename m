From: "Elwin Stelzer Eliazer" <stelzere-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: RE: Using 127.n.x.x/16 for namespace to host
Date: Tue, 7 Jul 2009 02:09:55 -0700
Message-ID: <000001c9fee2$b3433540$19c99fc0$@com>
References: <638f07d70907061546h5e017064t57ee22f45fa746b2@mail.gmail.com>
	<20090707002842.GA20703@redback.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090707002842.GA20703-gvzKVTG1yJJBDgjK7y7TUQ@public.gmane.org>
Content-Language: en-us
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: 'Guenter Roeck' <groeck-gvzKVTG1yJJBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Thank you for the suggestion. The link local address should be good enough
for now.

Cheers,
Elwin.

-----Original Message-----
From: Guenter Roeck [mailto:groeck-gvzKVTG1yJJBDgjK7y7TUQ@public.gmane.org] 
Sent: Monday, July 06, 2009 5:29 PM
To: Elwin Stelzer Eliazer
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Subject: Re: Using 127.n.x.x/16 for namespace to host

Look for ipv4_is_loopback().

Another option might be to use link local addresses.

Guenter

On Mon, Jul 06, 2009 at 03:46:20PM -0700, Elwin Stelzer Eliazer wrote:
> Hi,
> 
> I am using an internal bridge for internal socket communication between
the
> host and various containers' applications.
> This is purely an internal bridge and no external traffic is expected in
> this.
> I can use a regular private ip address subnet for this, for example a
> 192.168.x.x/16 for this, and things are working.
> But since the applications at the container and host handle external
traffic
> as well, we are forced to exclude this internal subnet for external use.
> Using a 127.n.x.x/16 subnet is preferred, since that is not expected to be
> used externally.
> But this is requiring kernel code change, since 127.0.0.1/8 is programmed
> for loopback interface 'lo' in host.
> Towards this tried changing:
>      IFF_LOOPBACK 0x10 // in in.h, changed from 0x8 to 0x10
>      ifa->ifa_prefixlen = 16; // in devinet.c, changed from 8 to 16
> And still do not see them connected.
> 
> Any suggestions on this will be appreciated.
> 
> regards,
> Elwin.
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
