From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/3] [RFC] user-cr: Hook implementation for userspace network
	bits
Date: Wed, 26 May 2010 07:42:36 -0700
Message-ID: <1274884956-21005-4-git-send-email-danms@us.ibm.com>
References: <1274884956-21005-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1274884956-21005-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

This patch adds a "net" hook application that (for now) handles the
c/r of network routes in a container.  At the moment, it just jumps into
the netns of the root task and saves or restores the routing information.
I think that's a reasonable first-step.

Note that it requires my patch to iproute2 to implement "save" and
"restore":

  http://marc.info/?l=linux-netdev&m=127446032232507&w=3

On checkpoint, it does a setns() into the network namespace of the root
task, and then opens a file and saves the current mapping of device names
to indexes, followed by the output of "ip route save".

On restart, it again does a setns() into the network namespace of the root
task, and opens the file.  This time, it maps the current device names and
indexes, but also reads the stored version, and then updates the saved
routing information (correcting indexes where necessary) as it feeds the
stream to "ip route restore".

There needs to be some more work done, at least the following:
1. Install the binaries into a libexec directory of some sort
2. Allow conditional execution of the net hook
3. Coordinate with the unfreezing of the tasks so that we can restore
   the routing information first
4. Disable the hook if the checkpoint or restart is working against
   stdio, or come up with a directory-based approach to storing the
   checkpoint stream and associated metadata

With this patch, I'm able to checkpoint/restart a container and have any
routes saved and restored along with it.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 hooks/Makefile       |   17 +++
 hooks/checkpoint-pre |    2 +
 hooks/map_ifs.c      |  268 +++++++++++++++++++++++++++++++++++++
 hooks/map_ifs.h      |   41 ++++++
 hooks/net.c          |  362 ++++++++++++++++++++++++++++++++++++++++++++++++++
 hooks/restart-post   |    2 +
 6 files changed, 692 insertions(+), 0 deletions(-)
 create mode 100644 hooks/Makefile
 create mode 100644 hooks/map_ifs.c
 create mode 100644 hooks/map_ifs.h
 create mode 100644 hooks/net.c

diff --git a/hooks/Makefile b/hooks/Makefile
new file mode 100644
index 0000000..2766388
--- /dev/null
+++ b/hooks/Makefile
@@ -0,0 +1,17 @@
+CFLAGS += -I../include
+
+all: net
+
+net.o: map_ifs.c map_ifs.h
+map_ifs.o: map_ifs.c map_ifs.h
+
+net: LDFLAGS += -lnl
+net: map_ifs.o net.o
+
+clean:
+	rm -f net map_ifs *.o
+
+# Test program for map_ifs
+map_ifs: CFLAGS += -D__TEST -lnl
+map_ifs: map_ifs.c map_ifs.h
+	$(CC) -o $@ $^ $(CFLAGS)
diff --git a/hooks/checkpoint-pre b/hooks/checkpoint-pre
index c586275..a4251ca 100644
--- a/hooks/checkpoint-pre
+++ b/hooks/checkpoint-pre
@@ -2,4 +2,6 @@
 
 echo "========= CHECKPOINT PRE HOOK ============"
 
+net -c -f ${CR_BASE_FILE}.netns ${CR_ROOT_PID}
+
 echo "========= CHECKPOINT PRE HOOK ============"
diff --git a/hooks/map_ifs.c b/hooks/map_ifs.c
new file mode 100644
index 0000000..760ba94
--- /dev/null
+++ b/hooks/map_ifs.c
@@ -0,0 +1,268 @@
+/*
+ *  map_ifs.c: implementation of an interface-to-name mapping for netdevs
+ *
+ *  Copyright 2010 IBM Corporation
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#define _GNU_SOURCE
+#include <stdio.h>
+#include <stdlib.h>
+#include <stdint.h>
+#include <string.h>
+#include <unistd.h>
+#include <sys/types.h>
+#include <dirent.h>
+#include <errno.h>
+
+#include <sys/socket.h>
+
+#include <linux/netlink.h>
+#include <netlink/msg.h>
+#include <linux/rtnetlink.h>
+
+#include "map_ifs.h"
+
+/* Data structure for saving the interface map */
+struct net_if_hdr {
+	uint32_t index;
+	uint32_t link;
+	uint8_t namelen;
+	uint8_t more;
+};
+
+static int add_map_entry(struct nlattr **tb,
+			 struct ifinfomsg *ifi,
+			 struct if_info *map)
+{
+	struct if_info *entry;
+
+	if (!tb[IFLA_IFNAME])
+		return -EINVAL;
+
+	entry = calloc(1, sizeof(*entry));
+	if (!entry)
+		return -ENOMEM;
+
+	entry->index = ifi->ifi_index;
+	strncpy(entry->name, RTA_DATA(tb[IFLA_IFNAME]), IFNAMSIZ);
+	if (tb[IFLA_LINK])
+		entry->link = *(int*)RTA_DATA(tb[IFLA_LINK]);
+	else
+		entry->link = entry->index;
+
+	map->next = entry;
+
+	return 0;
+}
+
+static int dump_interfaces(int nl, struct if_info *map)
+{
+	struct {
+		struct nlmsghdr nlh;
+		struct rtgenmsg g;
+	} req;
+	char buf[8192]; /* This default taken from iproute2 */
+	ssize_t len;
+	struct nlmsghdr *nlh = (struct nlmsghdr *)buf;
+	int ret = 0;
+
+	memset(&req, 0, sizeof(req));
+	req.nlh.nlmsg_len = sizeof(req);
+	req.nlh.nlmsg_type = RTM_GETLINK;
+	req.nlh.nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST;
+	req.g.rtgen_family = AF_PACKET;
+	len = send(nl, &req, sizeof(req), 0);
+	if (len == -1)
+		return len;
+	len = recv(nl, buf, sizeof(buf), 0);
+	if (len == -1)
+		return len;
+
+	while (nlmsg_ok(nlh, len)) {
+		struct ifinfomsg *ifi = NLMSG_DATA(nlh);
+		struct nlattr *tb[IFLA_MAX+1];
+		int nla_len = nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*ifi));
+
+		if (nlh->nlmsg_type != RTM_NEWLINK) {
+			ret = -EINVAL;
+			break;
+		}
+
+		ret = nla_parse(tb, IFLA_MAX, (struct nlattr *)IFLA_RTA(ifi),
+				nla_len, NULL);
+		if (ret < 0)
+			break;
+
+		ret = add_map_entry(tb, ifi, map);
+		if (ret < 0)
+			break;
+		map = map->next;
+
+		nlh = nlmsg_next(nlh, &len);
+	}
+
+	return ret;
+}
+
+int map_interfaces(struct if_info **map)
+{
+	struct if_info head = {"", -1, -1, NULL};
+	struct sockaddr_nl addr;
+	int nl;
+	int ret;
+
+	*map = NULL;
+	memset(&addr, 0, sizeof(addr));
+	addr.nl_family = AF_NETLINK;
+	nl = socket(AF_NETLINK, SOCK_RAW, NETLINK_ROUTE);
+	if (nl < 0)
+		return nl;
+	ret = dump_interfaces(nl, &head);
+	if (ret)
+		map_free(head.next);
+	else
+		*map = head.next;
+
+	close(nl);
+
+	return ret;
+}
+
+void map_free(struct if_info *map)
+{
+	struct if_info *ptr;
+
+	for (; map; map = ptr) {
+		ptr = map->next;
+		free(map);
+	}
+}
+
+struct if_info *map_find_by_index(struct if_info *map, int index)
+{
+	while (map) {
+		if (map->index == index)
+			return map;
+		map = map->next;
+	}
+
+	return NULL;
+}
+
+struct if_info *map_find_by_name(struct if_info *map, const char *name)
+{
+	while (map) {
+		if (strncmp(map->name, name, IFNAMSIZ) == 0)
+			return map;
+		map = map->next;
+	}
+
+	return NULL;
+}
+
+int map_save(struct if_info *map, int fd)
+{
+	int ret = 0;
+
+	while (map) {
+		struct net_if_hdr hdr;
+
+		hdr.index = map->index;
+		hdr.link = map->link;
+		hdr.namelen = strlen(map->name);
+		hdr.more = (map->next != NULL);
+
+		ret = write(fd, &hdr, sizeof(hdr));
+		if (ret < 0) {
+			ret = -errno;
+			break;
+		}
+
+		ret = write(fd, map->name, hdr.namelen);
+		if (ret < 0) {
+			ret = -errno;
+			break;
+		}
+
+		map = map->next;
+	}
+
+	return ret < 0 ? ret : 0;
+}
+
+int map_load(struct if_info **map, int fd)
+{
+	int ret;
+	struct if_info head;
+	struct if_info *ptr = &head;
+	struct net_if_hdr hdr;
+
+	*map = NULL;
+
+	do {
+		ret = read(fd, &hdr, sizeof(hdr));
+		if (ret < 0) {
+			ret = -errno;
+			break;
+		}
+
+		if (hdr.namelen >= IFNAMSIZ) {
+			ret = -EINVAL;
+			break;
+		}
+
+		ptr->next = calloc(1, sizeof(*ptr));
+		if (!ptr->next) {
+			ret = -ENOMEM;
+			break;
+		}
+
+		ptr->next->index = hdr.index;
+		ptr->next->link = hdr.link;
+		ret = read(fd, ptr->next->name, hdr.namelen);
+		if (ret < 0) {
+			ret = -errno;
+			break;
+		}
+		ptr = ptr->next;
+	} while (hdr.more);
+
+	if (ret < 0) {
+		ptr = head.next;
+		while (ptr) {
+			struct if_info *tmp = ptr->next;
+			free(ptr);
+			ptr = tmp;
+		}
+		return ret;
+	} else {
+		*map = head.next;
+		return 0;
+	}
+}
+
+#ifdef __TEST
+int main()
+{
+	int ret;
+	struct if_info *map;
+	struct if_info *_map;
+
+	ret = map_interfaces(&map);
+
+	_map = map;
+
+	printf("Returned %i\n", ret);
+
+	while (map) {
+		printf("%i: %s (%i)\n", map->index, map->name, map->link);
+		map = map->next;
+	}
+
+	map_free(_map);
+}
+#endif
diff --git a/hooks/map_ifs.h b/hooks/map_ifs.h
new file mode 100644
index 0000000..bebf230
--- /dev/null
+++ b/hooks/map_ifs.h
@@ -0,0 +1,41 @@
+/*
+ *  map_ifs.h: interface for interface mapping
+ *
+ *  Copyright 2010 IBM Corporation
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#ifndef __MAP_IFS_H
+#define __MAP_IFS_H
+
+#include <sys/socket.h>
+#include <linux/if.h>
+#include <stdio.h>
+
+struct if_info {
+	char name[IFNAMSIZ+1];
+	int index;
+	int link;
+	struct if_info *next;
+};
+
+int map_interfaces(struct if_info **map);
+void map_free(struct if_info *map);
+struct if_info *map_find_by_index(struct if_info *map, int index);
+struct if_info *map_find_by_name(struct if_info *map, const char *name);
+int map_save(struct if_info *map, int fd);
+int map_load(struct if_info **map, int fd);
+
+static inline void map_print(struct if_info *map, FILE *out)
+{
+	while (map) {
+		fprintf(out, "%i: %s (link=%i)\n",
+			map->index, map->name, map->link);
+		map = map->next;
+	}
+}
+
+#endif
diff --git a/hooks/net.c b/hooks/net.c
new file mode 100644
index 0000000..37bab68
--- /dev/null
+++ b/hooks/net.c
@@ -0,0 +1,362 @@
+/*
+ *  net.c: implementation of (applicable) netns bits c/r in userspace
+ *
+ *  Copyright 2010 IBM Corporation
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#define _GNU_SOURCE
+#include <stdio.h>
+#include <stdlib.h>
+#include <stdint.h>
+#include <getopt.h>
+
+#include <unistd.h>
+#include <errno.h>
+#include <fcntl.h>
+#include <sys/types.h>
+#include <sys/wait.h>
+#include <sys/mman.h>
+
+#include <netlink/netlink.h>
+#include <netlink/msg.h>
+#include <linux/rtnetlink.h>
+
+#include <linux/checkpoint.h>
+
+#include "map_ifs.h"
+
+int setns(int type, int fd)
+{
+	return syscall(__NR_setns, type, fd);
+}
+
+int set_netns_to(int pid)
+{
+	char *path = NULL;
+	int fd;
+	int ret;
+
+	if (asprintf(&path, "/proc/%i/ns/net", pid) == -1)
+		return -ENOMEM;
+
+	fd = open(path, O_RDWR);
+	free(path);
+	if (fd < 0)
+		return fd;
+
+	ret = setns(0, fd);
+	close(fd);
+
+	return ret;
+}
+
+int checkpoint_child(int fd, int pid)
+{
+	int ret;
+	struct if_info *map;
+
+	ret = set_netns_to(pid);
+	if (ret < 0)
+		return ret;
+
+	ret = map_interfaces(&map);
+	if (ret)
+		return ret;
+
+	ret = map_save(map, fd);
+	map_print(map, stderr);
+	map_free(map);
+	if (ret < 0)
+		return ret;
+
+	if (fd != 1) {
+		close(1);
+		close(2);
+		dup2(fd, 1);
+		dup2(fd, 2);
+	}
+
+	return execlp("ip", "ip", "route", "save", NULL);
+}
+
+int checkpoint_netns(const char *file, int pid)
+{
+	int ret;
+	int status;
+	int cpid;
+	int fd;
+
+	fd = open(file, O_WRONLY | O_TRUNC | O_CREAT, 0666);
+	if (fd < 0)
+		return -errno;
+
+	cpid = fork();
+	if (cpid == 0)
+		exit(checkpoint_child(fd, pid));
+
+	close(fd);
+
+	ret = waitpid(cpid, &status, 0);
+
+	return WEXITSTATUS(status);
+}
+
+int fix_index(struct if_info *this_map, struct if_info *prev_map,
+	      struct nlmsghdr *nlh)
+{
+	struct rtmsg *r = NLMSG_DATA(nlh);
+	struct nlattr *tb[RTA_MAX+1];
+	int len = nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r));
+	int ret;
+
+	ret = nla_parse(tb, RTA_MAX, (struct nlattr *)RTM_RTA(r), len, NULL);
+	if (ret < 0)
+		return ret;
+
+	if (tb[RTA_OIF]) {
+		int *oif = (int*)RTA_DATA(tb[RTA_OIF]);
+		struct if_info *prev_dev;
+		struct if_info *this_dev;
+
+		prev_dev = map_find_by_index(prev_map, *oif);
+		if (!prev_dev)
+			return -ENODEV;
+		this_dev = map_find_by_name(this_map, prev_dev->name);
+		if (!this_dev)
+			return -ENODEV;
+
+		*oif = this_dev->index;
+
+		fprintf(stderr, "Updated device %s %i->%i\n",
+			prev_dev->name, prev_dev->index, this_dev->index);
+	}
+
+	return 0;
+}
+
+int read_and_fix_route_data(struct if_info *this_map, struct if_info *prev_map,
+			    int fd, void *rdata, int rlen)
+{
+	struct nlmsghdr *nlh;
+	int ret;
+
+	ret = read(fd, rdata, rlen);
+	if (ret < 0)
+		return ret;
+	else if (ret != rlen)
+		return -EINVAL;
+
+	nlh = rdata;
+
+	for (; nlmsg_ok(nlh, rlen); nlh = nlmsg_next(nlh, &rlen)) {
+		if (nlh->nlmsg_type == RTM_NEWROUTE) {
+			ret = fix_index(this_map, prev_map, nlh);
+			if (ret < 0)
+				break;
+		}
+	}
+
+	return ret;
+}
+
+int restore_routes(void *rdata, int rlen)
+{
+	int pipefd[2];
+	int ret;
+	int pid;
+	int len;
+	int status;
+
+	ret = pipe(pipefd);
+	if (ret < 0)
+		return ret;
+
+	pid = fork();
+	if (pid == 0) {
+		close(pipefd[1]);
+		close(0);
+		dup2(pipefd[0], 0);
+		exit(execlp("ip", "ip", "route", "restore", NULL));
+	}
+
+	close(pipefd[0]);
+	len = write(pipefd[1], rdata, rlen);
+	close(pipefd[1]);
+
+	ret = waitpid(pid, &status, 0);
+	if (ret < 0)
+		return ret;
+
+	if (WIFEXITED(status))
+		return WEXITSTATUS(status);
+
+	return -EINVAL;
+}
+
+int get_maps(int fd, struct if_info **this_map, struct if_info **prev_map)
+{
+	int ret;
+
+	ret = map_interfaces(this_map);
+	if (ret < 0)
+		return ret;
+
+	ret = map_load(prev_map, fd);
+	if (ret < 0) {
+		map_free(*this_map);
+		return ret;
+	}
+
+	return 0;
+}
+
+int restore_child(int fd, int pid)
+{
+	int ret;
+	struct if_info *this_map;
+	struct if_info *prev_map;
+	void *rdata = NULL;
+	struct stat s;
+	off_t rlen;
+
+	ret = set_netns_to(pid);
+	if (ret < 0)
+		return ret;
+
+	ret = fstat(fd, &s);
+	if (ret < 0)
+		return ret;
+
+	ret = get_maps(fd, &this_map, &prev_map);
+	if (ret < 0)
+		return ret;
+
+	rlen = s.st_size - lseek(fd, 0, SEEK_CUR);
+	if (rlen == 0)
+		return 0; /* No routing information */
+
+	rdata = malloc(rlen);
+	if (!rdata) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	ret = read_and_fix_route_data(this_map, prev_map, fd, rdata, rlen);
+	if (ret < 0)
+		goto out;
+
+	ret = restore_routes(rdata, rlen);
+ out:
+	free(rdata);
+	map_free(this_map);
+	map_free(prev_map);
+
+	return ret;
+}
+
+int restore_netns(const char *file, int pid)
+{
+	int ret;
+	int status;
+	int cpid;
+	int fd;
+
+	fd = open(file, O_RDONLY, 0666);
+	if (fd < 0)
+		return -errno;
+
+	cpid = fork();
+	if (cpid == 0)
+		exit(restore_child(fd, pid));
+
+	close(fd);
+
+	ret = waitpid(cpid, &status, 0);
+
+	return ret < 0 ? errno : WEXITSTATUS(status);
+}
+
+void usage(const char *name)
+{
+	fprintf(stderr, "Usage: %s [-c|-r] [-f file] [pid]\n", name);
+}
+
+enum {
+	CMD_UNSPEC,
+	CMD_CHECKPOINT,
+	CMD_RESTORE,
+};
+
+int main(int argc, char **argv)
+{
+	int pid;
+	int c;
+	char *file = NULL;
+	int cmd = CMD_UNSPEC;
+	int ret;
+
+	while (1) {
+		int optidx = 0;
+		static struct option long_opts[] = {
+			{"file",       1, 0, 'f'},
+			{"checkpoint", 0, 0, 'c'},
+			{"restore",    0, 0, 'r'},
+			{NULL,   0, 0,  0 }
+		};
+
+		c = getopt_long(argc, argv, "f:cr", long_opts, &optidx);
+		if (c == -1)
+			break;
+
+		switch (c) {
+		case 'f':
+			file = optarg;
+			break;
+		case 'c':
+			cmd = CMD_CHECKPOINT;
+			break;
+		case 'r':
+			cmd = CMD_RESTORE;
+			break;
+		default:
+			fprintf(stderr, "getopt error\n");
+			exit(1);
+		}
+	}
+
+	if (optind < argc) {
+		if (sscanf(argv[optind], "%i", &pid) != 1) {
+			fprintf(stderr, "Invalid pid `%s'\n", argv[optind]);
+			return 1;
+		}
+
+		if (optind + 1 != argc) {
+			fprintf(stderr, "Garbage after pid\n");
+			return 1;
+		}
+	} else {
+		usage(argv[0]);
+		return 1;
+	}
+
+	switch (cmd) {
+	case CMD_CHECKPOINT:
+		ret = checkpoint_netns(file, pid);
+		break;
+	case CMD_RESTORE:
+		ret = restore_netns(file, pid);
+		break;
+	default:
+		fprintf(stderr, "No command specified\n");
+		return 1;
+	}
+
+	if (ret)
+		fprintf(stderr, "Failed: %s\n", strerror(ret));
+
+	return ret;
+}
diff --git a/hooks/restart-post b/hooks/restart-post
index dbce024..a2fa0cb 100644
--- a/hooks/restart-post
+++ b/hooks/restart-post
@@ -2,4 +2,6 @@
 
 echo "========= RESTART POST HOOK ============"
 
+net -r -f ${CR_BASE_FILE}.netns ${CR_ROOT_PID}
+
 echo "========= RESTART POST HOOK ============"
-- 
1.7.0.4
