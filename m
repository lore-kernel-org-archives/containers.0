From: Rishikesh K Rajak <risrajak-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Testing CGROUP inside CONTAINER]: BUG#1
Date: Thu, 4 Dec 2008 19:12:18 +0530
Message-ID: <OF56DEAF83.DB755A6D-ON65257515.004ACFC5-65257515.004B64CF@in.ibm.com>
References: <1228378478.4234.35.camel@localhost.localdomain>	
	<4937DA54.8060801@linux.vnet.ibm.com>
	<1228397664.13111.32.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1228397664.13111.32.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Iranna D Ankad <iranna.ankad-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Sudhir Kumar15 <sudhirkumarmalik-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dhaval Giani1 <dhavalgiani-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote on 12/04/2008 07:04:23 PM:

> On Thu, 2008-12-04 at 18:55 +0530, gowrishankar wrote:
> > It is expected behaviour of container, as PIDs in other namespaces will

> > always be shown as 0.
> > So here, these 0s are from system ns (probably, as you had only system
> > ns and delta ns).
>
> I think it is pretty bogus to be showing the 0's.  It is "expected" only
> when we got access to a task which we were not supposed to receive.
>
> Rishi, is this any different in behavior if you do the cgroup mount
> after creating the container?

Actually i reported the problem when i am doing cgroup mount after creating
container only.
But one thing is very interesting here, if i do this:

mount cgroup on root -> then create container -> cat /cpu/tasks inside
container -> again you can see many zero's which is highly undesirable.

-Rishi
>
> -- Dave
>
