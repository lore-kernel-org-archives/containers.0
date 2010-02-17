From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: Container for Amazon EC2?
Date: Wed, 17 Feb 2010 09:36:19 -0600
Message-ID: <20100217153619.GA23760@hallyn.com>
References: <2c2629fa1002150243n4c91d93ctee4509912228f3ea@mail.gmail.com>
	<20100215143905.GD28038@us.ibm.com>
	<20100217151943.GA9159@us.ibm.com>
	<2c2629fa1002170723o43aed18as7745b2ce4217474b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <2c2629fa1002170723o43aed18as7745b2ce4217474b-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jun OKAJIMA <okajima-og82NyAXoxRpnGNL948N7c8NsWr+9BEh@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Jun OKAJIMA (okajima-og82NyAXoxRpnGNL948N7c8NsWr+9BEh@public.gmane.org):
> This is my result.
> I dont know very well about lxc,
> but this is usable?

I'm not sure which you mean as usable:  lxc is very usable, and
lets you run multiple application and system containers of various
distros.  The lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org mailing list was
recently started to accomodate its growing user base.

The kernel on the ec2 instance, however, is not :)

It might be worth jumping onto #ubuntu-virt and asking whether
they have, or can publish, a kernel with, at the least:

CONFIG_CGROUP_DEVICE=y
CONFIG_CGROUP_FREEZER=y
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
CONFIG_USER_NS=y
CONFIG_PID_NS=y
CONFIG_NET_NS=y
CONFIG_VETH=y
CONFIG_MACVLAN=y
CONFIG_BRIDGE=y
CONFIG_DEVPTS_MULTIPLE_INSTANCES=y

Those should be sufficient to start using lxc very nicely

-serge
