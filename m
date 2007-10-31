From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [RFD] net list protected by rcu
Date: Wed, 31 Oct 2007 15:42:13 +0100
Message-ID: <47289445.1060108@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
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
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Cc: "container >> Linux Containers" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

Benjamin and I, we are currently looking for using IPV6 for the network 
namespaces.

There is a special case where we must browse the network namespace list 
to check the routes ages at a given time for garbage collecting.

fib6_run_gc
  => fib6_clean_all

In this function we browse the network namespace list with the usual 
macro: for_each_net, which should be protected by rtnl_lock.

The function fib6_run_gc is a timer callback, that means we are called 
from interrupt handler. But in this case, we can not use rtnl_lock 
because it locks a mutex and this is forbidden to do that from an 
interrupt handler.

If we put apart the fact there is perhaps a better solution than 
browsing the netns list (eg. make a gc timer per namespace), can we 
consider to simply use the RCU to lock the network namespace list ?

So we can remove the rtnl_lock calls in the network namespaces and just 
use rcu_read_lock for browsing the netns list in the network code. That 
will be more flexible, we can use it in interrupt handler, we can nest 
with another rcu_read_lock and we don't add more locking contention for 
the network.
