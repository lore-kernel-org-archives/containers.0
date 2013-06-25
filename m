From: Aaron Staley <aaron-ZNH+RosXeVlBDgjK7y7TUQ@public.gmane.org>
Subject: PROBLEM: Processes writing large files in memory-limited LXC
	container are killed by OOM
Date: Mon, 24 Jun 2013 22:45:02 -0700
Message-ID: <CAMcjixYa-mjo5TrxmtBkr0MOf+8r_iSeW5MF4c8nJKdp5m+RPA@mail.gmail.com>
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
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Id: containers.vger.kernel.org

This is better explained here:
http://serverfault.com/questions/516074/why-are-applications-in-a-memory-limited-lxc-container-writing-large-files-to-di
(The
highest-voted answer believes this to be a kernel bug.)

Summary: I have set up a system where I am using LXC to create multiple
virtualized containers on my system with limited resources. Unfortunately, I'm
running into a troublesome scenario where the OOM killer is hard killing
processes in my LXC container when I write a file with size exceeding the
memory limitation (set to 300MB). There appears to be some issue with the
file buffering respecting the containers memory limit.


Reproducing:

/done on a c1.xlarge instance running on Amazon EC2

Create 6 empty lxc containers (in my case I did lxc-create -n testcon -t
ubuntu -- -r precise)

Modify the configuration of each container to set lxc.cgroup.memory.
limit_in_bytes = 300M

Within each container run:
dd if=/dev/zero of=test2 bs=100k count=5010
parallel

This will with high probability activate the OOM (as seen in demsg); often
the dd processes themselves will be killed.

This has been verified to have problems on:
Linux 3.8.0-25-generic #37-Ubuntu SMP and Linux ip-10-8-139-98
3.2.0-29-virtual #46-Ubuntu SMP Fri Jul 27 17:23:50 UTC 2012 x86_64 x86_64
x86_64 GNU/Linux

Please let me know your thoughts.

Regards,
Aaron Staley
