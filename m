From: =?UTF-8?Q?=D0=9F=D1=91=D1=82=D1=80_=D0=92=D0=BE=D0=BB=D0=BA=D0=BE?=
	=?UTF-8?Q?=D0=B2?= <pva-IzMiZDvh46SHXe+LvDLADg@public.gmane.org>
Subject: Need help to debug container's freeze
Date: Fri, 29 Oct 2010 16:27:40 +0400
Message-ID: <1288355260.4451.121.camel@tablet>
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

Hi. We are using lxc to separate different services into containers: for
this discussions we have apache+php, mysql, nginx containers to serve
our web application. After upgrade (I think from kernel 2.6.32 into
something newer, now we are using 2.6.35, but tried 34 too) we've
experience following issue: at some point nginx starts to show us "504
Gateway Time-out" error and while it is possible to ssh on server `ps
aux` hangs (with no ability to stop it), it is impossible to restart
apache container (hangs on stop) and the only way to fix this is to
restart server using sysrq or power button. At the same time there is
nothing in the logs. I suspect apache starts to eat lots of memory but
oom killer somehow freezes container but I don't have any proves. What
could you suggest to debug this issue? What sysrq information could be
useful here?

-- 
Peter.
