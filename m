From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 0/3] ns, procfs: pid conversion between ns and
	showing pidns hierarchy
Date: Sat, 13 Sep 2014 00:18:52 +0200
Message-ID: <20140912221852.GA18234@mail.hallyn.com>
References: <1409740200-26461-1-git-send-email-chenhanxiao@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1409740200-26461-1-git-send-email-chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Chen Hanxiao <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Richard Weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

so the below is just 30 mins worth of playing around, will hang if you give
it bad pids, and requires privilege, but shows how to get pid conversion
in some cases.  Basically it gives you what I had previously suggested
for the query_pid syscall before.

In general, usage is

translatepid reporter_pid dest_pid query_pid

where reporter_pid and dest_pid are pids in your pidns.  It will assume
query_pid is a valid pid in reporter_pid's pidns, and return the pid of
the same process in dest_pid's namespace.

In particular,

if a process in a container (say pid 1, pid 24444 in the host pidns)
reports something about another process (say pid 262) in the container,
and you have a shell (pid 1092) on the host, you can figure out the pid
for 262 in your host pidns using

translatepid $$ 24444 262

or to figure out what pid 25152 on the host is knows as in the
container,

translatepid 24444 $$ 25152

I wonder whether this is enough to give you all you need.  While it
won't be super-fast, you could use and ppid info to figure out who
is pid 1, etc.

#define _GNU_SOURCE             /* See feature_test_macros(7) */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <fcntl.h>
#include <sys/un.h>
#include <sched.h>
#include <errno.h>

/*
 * general usage:
 *    translatepid reporter_ns_pid dest_ns_pid query_pid
 *
 * reporter_ns_pid and dest_ns_pid are pids in your namespace.
 * query_pid is in reporter_ns_pid's namespace.  The result is
 * in dest_ns_pid's namespace.
 *
 * If you see pid 10064 and want to know what it's vpid
 * is:
 *    translatepid $$ 10064 10064
 * If pid 10064 reported something about a pid 9 in its
 * own ns and you want to know what pid that is in your
 * ns:
 *    translatepid 10064 $$ 9
 *
 * First cpid1, in rpid's pidns, sends us query_pid.
 * Then we send that translated pid to cpid2, in dpid's pidns.
 * It prints out the answer
 */

static int proxyrecv(int sockfd, void *buf, size_t len)
{
	struct timeval tv;
	fd_set rfds;

	FD_ZERO(&rfds);
	FD_SET(sockfd, &rfds);
	tv.tv_sec = 2;
	tv.tv_usec = 0;

	if (select(sockfd+1, &rfds, NULL, NULL, &tv) < 0)
		return -1;
	return recv(sockfd, buf, len, MSG_DONTWAIT);
}

void send_creds(int sock, struct ucred *cred)
{
	struct msghdr msg = { 0 };
	struct iovec iov;
	struct cmsghdr *cmsg;
	char cmsgbuf[CMSG_SPACE(sizeof(*cred))];
	char buf[1];
	buf[0] = 'p';

	if (proxyrecv(sock, buf, 1) != 1) {
		printf("%s: Error getting reply from server over socketpair",
			  __func__);
		exit(1);
	}

	msg.msg_control = cmsgbuf;
	msg.msg_controllen = sizeof(cmsgbuf);

	cmsg = CMSG_FIRSTHDR(&msg);
	cmsg->cmsg_len = CMSG_LEN(sizeof(struct ucred));
	cmsg->cmsg_level = SOL_SOCKET;
	cmsg->cmsg_type = SCM_CREDENTIALS;
	memcpy(CMSG_DATA(cmsg), cred, sizeof(*cred));

	msg.msg_name = NULL;
	msg.msg_namelen = 0;

	iov.iov_base = buf;
	iov.iov_len = sizeof(buf);
	msg.msg_iov = &iov;
	msg.msg_iovlen = 1;

	if (sendmsg(sock, &msg, 0) < 0) {
		printf("%s: failed at sendmsg: %s", __func__,
			  strerror(errno));
		exit(1);
	}
}

void recv_creds(int sock, struct ucred *cred)
{
	struct msghdr msg = { 0 };
	struct iovec iov;
	struct cmsghdr *cmsg;
	char cmsgbuf[CMSG_SPACE(sizeof(*cred))];
	char buf[1];
	int ret;
	int optval = 1;

	cred->pid = -1;
	cred->uid = -1;
	cred->gid = -1;

	if (setsockopt(sock, SOL_SOCKET, SO_PASSCRED, &optval, sizeof(optval)) == -1) {
		printf("Failed to set passcred: %s", strerror(errno));
		return;
	}
	buf[0] = '1';
	if (write(sock, buf, 1) != 1) {
		printf("Failed to start write on scm fd: %s", strerror(errno));
		return;
	}

	msg.msg_name = NULL;
	msg.msg_namelen = 0;
	msg.msg_control = cmsgbuf;
	msg.msg_controllen = sizeof(cmsgbuf);

	iov.iov_base = buf;
	iov.iov_len = sizeof(buf);
	msg.msg_iov = &iov;
	msg.msg_iovlen = 1;

	// retry logic is not ideal, especially as we are not
	// threaded.  Sleep at most 1 second waiting for the client
	// to send us the scm_cred
	ret = recvmsg(sock, &msg, 0);
	if (ret < 0) {
		printf("Failed to receive scm_cred: %s",
			  strerror(errno));
		return;
	}

	cmsg = CMSG_FIRSTHDR(&msg);

	if (cmsg && cmsg->cmsg_len == CMSG_LEN(sizeof(struct ucred)) &&
			cmsg->cmsg_level == SOL_SOCKET &&
			cmsg->cmsg_type == SCM_CREDENTIALS) {
		memcpy(cred, CMSG_DATA(cmsg), sizeof(*cred));
	}
}

int main(int argc, char *argv[])
{
	pid_t rpid, dpid, qpid;
	pid_t cpid1, cpid2;
	int optval = 1;
	struct ucred u;
	char path[100];
	int fd;

	int sv[2];

	if (argc != 4) {
		printf("Usage: %s report_pid dest_pid query_pid\n", argv[0]);
		exit(1);
	}

	if (socketpair(AF_UNIX, SOCK_DGRAM, 0, sv) < 0) {
		perror("socketpair");
		exit(1);
	}
	rpid = atoi(argv[1]);
	dpid = atoi(argv[2]);
	qpid = atoi(argv[3]);

	if ((cpid1 = fork()) < 0) {
		perror("fork");
		exit(1);
	}
	if (cpid1 == 0) {
		int xpid;
		sprintf(path, "/proc/%d/ns/pid", rpid);
		fd = open(path, O_RDWR);
		if (fd < 0) {
			perror("open of nspid");
			exit(1);
		}
		if (setns(fd, 0) < 0) {
			perror("setns");
			exit(1);
		}
		if ((xpid = fork()) < 0)
			exit(1);
		if (xpid == 0) {
			u.uid = 0;  u.gid = 0;  u.pid = qpid;
			send_creds(sv[0], &u);
		}
		exit(0);
	}
	recv_creds(sv[1], &u);

	close(sv[0]);
	close(sv[1]);

	if (socketpair(AF_UNIX, SOCK_DGRAM, 0, sv) < 0) {
		perror("socketpair");
		exit(1);
	}
	if ((cpid2 = fork()) < 0) {
		perror("fork");
		exit(1);
	}

	if (cpid2 == 0) {
		pid_t xpid;
		sprintf(path, "/proc/%d/ns/pid", dpid);
		fd = open(path, O_RDWR);
		if (fd < 0) {
			perror("open of nspid");
			exit(1);
		}
		if (setns(fd, 0) < 0) {
			perror("setns");
			exit(1);
		}
		if ((xpid = fork()) < 0)
			exit(1);
		if (xpid == 0) {
			recv_creds(sv[1], &u);
			printf("pid is: %d\n", (int) u.pid);
		}
		exit(0);
	}

	send_creds(sv[0], &u);

	waitpid(cpid2, NULL, 0);
	exit(0);
}
