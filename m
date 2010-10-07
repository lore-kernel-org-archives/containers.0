From: =?Big5?B?qVCrwqfK?= <richard925215-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Question about libnetfilter_queue and container
Date: Thu, 7 Oct 2010 17:52:17 +0800
Message-ID: <AANLkTi=bNa0FTVc+iXeO_8OTyLxJNz5=amuHB0m+-sBS@mail.gmail.com>
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

Hi every body,

I'm a newbie to container use.

I am going to use the libnetfilter_queue, an userspace library, to
forward the packets that have been queued by the kernel packet filter,
such like iptables,
to userspace program but it didn't work. Do anyone else has been try
this way before or had a similar experience?

I followed the website below to set up my container.

http://en.opensuse.org/LXC

All libnetfilter_queue related libraries installed by zypper, as
the following commands.

$ zypper in libnfnetlink-devel libnfnetlink0
$ zypper in libnetfilter_queue-devel libnetfilter_queue1

I really appreciate for someone who can help me to deal with this problem.

thanks,
Richard
