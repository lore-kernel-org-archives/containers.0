From: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: setns vs unshare bug
Date: Fri, 10 Aug 2012 18:55:36 +0400
Message-ID: <502520E8.5040401@parallels.com>
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
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi, Eric!

There's an issue with setns versus unshare syscall which I consider
to be worth looking at. Look -- when you open some task's namespace file,
e.g. /proc/<pid>/ns/net, the net namespace is cached on the proc inode.

If later the task with the pid <pid> unshares the namespace in question
(in this case -- net ns) the subsequent openings of this task's proc ns
file will result in old namespace obtained and the setns call will not
work as expected. Here's a simple proggie which demonstrates this:

int main(void)
{
	int pid, fd;
	char path[64];

	pid = fork();
	if (!pid) {
		fd = open("/proc/self/ns/net", O_RDONLY);
		close(fd);
		unshare(CLONE_NEWNET);
		printf("New net:\n");
		system("ip l");
		sleep(1);
	} else {
		sleep(1);
		printf("Old net:\n");
		system("ip l");
		sprintf(path, "/proc/%d/ns/net", pid);
		fd = open(path, O_RDONLY);
		set_ns(fd, CLONE_NEWNET);
		printf("New net 2:\n");
		system("ip l");
	}

	return 0;
}

The "else" branch after set_ns expects the net it set to be the new one (and
contain a lo device only), but it's not so -- after the setns syscall the net
namespace isn't changed! If you comment out the "if" branch's open and close
calls (thus avoiding the ns caching) the setns works as expected.

I assume you're aware of this problem, so do you have plans to fix this?

Thanks,
Pavel
