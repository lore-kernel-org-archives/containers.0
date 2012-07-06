From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Network namespace and bonding WARNING at fs/proc/generic.c
	remove_proc_entry
Date: Fri, 06 Jul 2012 11:40:45 -0700
Message-ID: <87pq88g2c2.fsf__1418.93511540747$1341600071$gmane$org@xmission.com>
References: <1340900320.3441.88.camel@pro6455b.example.com>
	<20120705220749.GA11255@mail.hallyn.com> <87ehopu3e5.fsf@xmission.com>
	<1341597680.2829.22.camel@pro6455b.example.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1341597680.2829.22.camel-1RhL1yiVGhRuYUHNOcvv81aTQe2KTcn/@public.gmane.org> (Dilip Daya's
	message of "Fri, 06 Jul 2012 14:01:20 -0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: dilip.daya-VXdhtT5mjnY@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Dilip Daya <dilip.daya-VXdhtT5mjnY@public.gmane.org> writes:

> Hi Eric,

> We do need to move bonds between namespaces - because we require
> physical interfaces in each namespace -- we don't want the overheads of
> virtual interfaces, don't have the management infrastructure, and don't
> want to manufacture fake mac addresses that would be required for
> macvlan interfaces.   Since the bonds are implicitly created in the host
> namespace, the only way we know to get bonds directly into the
> namespaces is to move them.

There about 3 ways to create bonding devices.  One of those ways
is to create bonding devices when loading the module.  Another
way is to create a bond device with "echo '+bond35 > /sys/class/net/bonding_masters".
them when loading the module, and my favorite is the standard way
"ip link add type bond".  All but loading the bonding device work in the
network namespace you are in at the type.

> Would "NETDEV_UNREGISTER and NETDEV_REGISTER events to remove/add the
> per device proc files at the appropriate time." help in the case?

Yes.  But since you can create the bonding device in the network
namespace you need it in, I don't see the point, of adding a code
path no one will test for 3 years at a time.

It seems easier to me to just not allow migration of bonding devices
and set peoples expectations a little lower.  Especially given
the very complex user space interfaces.

On ther other hand if you want to write and test and generally own the
patch I will review it.

Eric
