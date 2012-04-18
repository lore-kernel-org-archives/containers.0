From: Matt Chapman <matt-JH8ux4lg5NqC8CmZemzhMw@public.gmane.org>
Subject: Checking memory limit inside a container
Date: Wed, 18 Apr 2012 16:13:33 -0700
Message-ID: <CAPE4pjBNqeBXqUTpfnY1UyB13H0fKUiKaLW_HL0uWsrLTJ62mA@mail.gmail.com>
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
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello,

I'm new to using LXC, but really impressed so far. I'm trying to set-up
memory limits for a container, and have added these lines to my container
config file:

lxc.cgroup.memory.limit_in_bytes = 15872M
lxc.cgroup.memory.memsw.limit_in_bytes = 16896M

...and I've stopped & restarted my container.

But from inside the container, using `free` or `top`,etc, still reports the
total available memory as that of the host system, not what has been
allocated to the container.

Is this normal, or does it suggest I did something wrong? Is there a way to
accurately check memory usage for a container from within that container?
Or even from the host system?

Any help would be greatly appreciated.

Thanks,

Matt Chapman
