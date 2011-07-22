From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [TOOLS] To make use of the patches
Date: Fri, 22 Jul 2011 16:45:58 -0700
Message-ID: <20110722234558.GD16940@count0.beaverton.ibm.com>
References: <4E204466.8010204@parallels.com> <4E204554.6040901@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4E204554.6040901-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Jul 15, 2011 at 05:49:08PM +0400, Pavel Emelyanov wrote:
> Additionally the binfmt_img.h from kernel is required for cr-restore.

> #include <stdio.h>
> #include <unistd.h>
> #include <signal.h>
> #include <dirent.h>
> #include <string.h>
> #include <fcntl.h>
> #include <sys/stat.h>
> #include <errno.h>
> #include <linux/kdev_t.h>
> #include <stdlib.h>
> #include <sys/mman.h>
> #include <sys/vfs.h>
> 
> #include <linux/types.h>
> #include "img_structs.h"
> 
> static int fdinfo_img;
> static int pages_img;
> static int core_img;
> static int shmem_img;
> static int pipes_img;
> 
> #define PIPEFS_MAGIC 0x50495045

Shouldn't there be only one MAGIC number for checkpoint contents?

You can always add an additional "type" number following the magic
number. Or make the type a string with the name of the /proc file it's
from... etc.

> 
> static int prep_img_files(int pid)
> {
> 	__u32 type;
> 	char name[64];
> 
> 	sprintf(name, "fdinfo-%d.img", pid);
> 	fdinfo_img = open(name, O_WRONLY | O_CREAT | O_EXCL, 0600);
> 	if (fdinfo_img < 0) {
> 		perror("Can't open fdinfo");
> 		return 1;
> 	}
> 
> 	type = FDINFO_MAGIC;
> 	write(fdinfo_img, &type, 4);
> 
> 	sprintf(name, "pages-%d.img", pid);
> 	pages_img = open(name, O_WRONLY | O_CREAT | O_EXCL, 0600);
> 	if (pages_img < 0) {
> 		perror("Can't open shmem");
> 		return 1;
> 	}
> 
> 	type = PAGES_MAGIC;
> 	write(pages_img, &type, 4);
> 
> 	sprintf(name, "core-%d.img", pid);
> 	core_img = open(name, O_WRONLY | O_CREAT | O_EXCL, 0600);
> 	if (core_img < 0) {
> 		perror("Can't open core");
> 		return 1;
> 	}
> 
> 	sprintf(name, "shmem-%d.img", pid);
> 	shmem_img = open(name, O_WRONLY | O_CREAT | O_EXCL, 0600);
> 	if (shmem_img < 0) {
> 		perror("Can't open shmem");
> 		return 1;
> 	}
> 
> 	type = SHMEM_MAGIC;
> 	write(shmem_img, &type, 4);
> 
> 	sprintf(name, "pipes-%d.img", pid);
> 	pipes_img = open(name, O_WRONLY | O_CREAT | O_EXCL, 0600);
> 	if (pipes_img < 0) {
> 		perror("Can't open pipes");
> 		return 1;
> 	}
> 
> 	type = PIPES_MAGIC;
> 	write(pipes_img, &type, 4);
> 
> 	return 0;
> }
> 
> static void kill_imgfiles(int pid)
> {
> 	/* FIXME */
> }
> 
> static int stop_task(int pid)
> {
> 	return kill(pid, SIGSTOP);
> }
> 
> static void continue_task(int pid)
> {
> 	if (kill(pid, SIGCONT))
> 		perror("Can't cont task");
> }

Eventually, I think you should use the cgroup freezer here rather
than signals. Shells and debuggers use these signals so a checkpoint
could easily and quietly be corrupted.

Even if you use the freezer, there needs to be a mechanism to
assure that the frozen cgroup is not thawed before a consistent
checkpoint is complete. Otherwise corruption is always a possibility.

> 
> static char big_tmp_str[PATH_MAX];
> 
> static int read_fd_params(int pid, char *fd, unsigned long *pos, unsigned int *flags)
> {
> 	char fd_str[128];
> 	int ifd;
> 
> 	sprintf(fd_str, "/proc/%d/fdinfo/%s", pid, fd);
> 
> 	printf("\tGetting fdinfo for fd %s\n", fd);
> 	ifd = open(fd_str, O_RDONLY);
> 	if (ifd < 0) {
> 		perror("Can't open fdinfo");
> 		return 1;
> 	}
> 
> 	read(ifd, big_tmp_str, sizeof(big_tmp_str));
> 	close(ifd);
> 
> 	sscanf(big_tmp_str, "pos:\t%lli\nflags:\t%o\n", pos, flags);
> 	return 0;
> }
> 
> static int dump_one_reg_file(int type, unsigned long fd_name, int lfd,
> 		int lclose, unsigned long pos, unsigned int flags)
> {
> 	char fd_str[128];
> 	int len;
> 	struct fdinfo_entry e;
> 
> 	sprintf(fd_str, "/proc/self/fd/%d", lfd);
> 	len = readlink(fd_str, big_tmp_str, sizeof(big_tmp_str) - 1);
> 	if (len < 0) {
> 		perror("Can't readlink fd");
> 		return 1;
> 	}
> 
> 	big_tmp_str[len] = '\0';
> 	printf("\tDumping path for %x fd via self %d [%s]\n", fd_name, lfd, big_tmp_str);
> 
> 	if (lclose)
> 		close(lfd);
> 
> 	e.type = type;
> 	e.addr = fd_name;
> 	e.len = len;
> 	e.pos = pos;
> 	e.flags = flags;
> 
> 	write(fdinfo_img, &e, sizeof(e));
> 	write(fdinfo_img, big_tmp_str, len);
> 
> 	return 0;
> }
> 
> #define MAX_PIPE_BUF_SIZE	1024 /* FIXME - this is not so */
> #define SPLICE_F_NONBLOCK	0x2
> 
> static int dump_pipe_and_data(int lfd, struct pipes_entry *e)
> {
> 	int steal_pipe[2];
> 	int ret;
> 
> 	printf("\tDumping data from pipe %x\n", e->pipeid);
> 	if (pipe(steal_pipe) < 0) {
> 		perror("Can't create pipe for stealing data");
> 		return 1;
> 	}
> 
> 	ret = tee(lfd, steal_pipe[1], MAX_PIPE_BUF_SIZE, SPLICE_F_NONBLOCK);

Neat application of tee().

> 	if (ret < 0) {
> 		if (errno != EAGAIN) {
> 			perror("Can't pick pipe data");
> 			return 1;
> 		}
> 
> 		ret = 0;
> 	}
> 
> 	e->bytes = ret;
> 	write(pipes_img, e, sizeof(*e));
> 
> 	if (ret) {
> 		ret = splice(steal_pipe[0], NULL, pipes_img, NULL, ret, 0);
> 		if (ret < 0) {
> 			perror("Can't push pipe data");
> 			return 1;
> 		}
> 	}
> 
> 	close(steal_pipe[0]);
> 	close(steal_pipe[1]);
> 	return 0;
> }
> 
> static int dump_one_pipe(int fd, int lfd, unsigned int id, unsigned int flags)
> {
> 	struct pipes_entry e;
> 
> 	printf("\tDumping pipe %d/%x flags %x\n", fd, id, flags);
> 
> 	e.fd = fd;
> 	e.pipeid = id;
> 	e.flags = flags;
> 
> 	if (flags & O_WRONLY) {
> 		e.bytes = 0;
> 		write(pipes_img, &e, sizeof(e));
> 		return 0;
> 	}
> 
> 	return dump_pipe_and_data(lfd, &e);
> }
> 
> static int dump_one_fd(int dir, char *fd_name, unsigned long pos, unsigned int flags)
> {
> 	int fd;
> 	struct stat st_buf;
> 	struct statfs stfs_buf;
> 
> 	printf("\tDumping fd %s\n", fd_name);
> 	fd = openat(dir, fd_name, O_RDONLY);
> 	if (fd == -1) {
> 		printf("Tried to openat %d/%d %s\n", getpid(), dir, fd_name);
> 		perror("Can't open fd");
> 		return 1;
> 	}
> 
> 	if (fstat(fd, &st_buf) < 0) {
> 		perror("Can't stat one");
> 		return 1;
> 	}
> 
> 	if (S_ISREG(st_buf.st_mode))
> 		return dump_one_reg_file(FDINFO_FD, atoi(fd_name), fd, 1, pos, flags);
> 
> 	if (S_ISFIFO(st_buf.st_mode)) {
> 		if (fstatfs(fd, &stfs_buf) < 0) {
> 			perror("Can't statfs one");
> 			return 1;
> 		}
> 
> 		if (stfs_buf.f_type == PIPEFS_MAGIC)
> 			return dump_one_pipe(atoi(fd_name), fd, st_buf.st_ino, flags);
> 	}

This is starting to look like a linear search over the set of all
possible types of things file descriptors can refer to. A kernel implementation
doesn't have to do this. Furthermore, if lots of file descriptors are open
this could be alot of fstat() and fstatfs() calls -- will making so many
syscalls force us to an completely in-kernel implementation, like the
set already proposed, just to get usable performance?

> 
> 	if (!strcmp(fd_name, "0")) {
> 		printf("\tSkipping stdin\n");
> 		return 0;
> 	}

Assuming that fd 0 is "stdin" is very very gross. Yes, it's almost always
true. But that does *not* mean that it's a pty. stdin could be a pipe
we need to checkpoint. Really, this is also about the "type" of thing
the fd is referring to -- not about which fd nr it is.

What are your plans for removing this?


> 
> 	if (!strcmp(fd_name, "1")) {
> 		printf("\tSkipping stdout\n");
> 		return 0;
> 	}

Gross again, for the same reasons.

> 
> 	if (!strcmp(fd_name, "2")) {
> 		printf("\tSkipping stderr\n");
> 		return 0;
> 	}

Gross again, for the same reasons.

> 
> 	fprintf(stderr, "Can't dump file %s of that type [%x]\n", fd_name, st_buf.st_mode);
> 	return 1;
> 
> }
> 
> static int dump_task_files(int pid)
> {
> 	char pid_fd_dir[64];
> 	DIR *fd_dir;
> 	struct dirent *de;
> 	unsigned long pos;
> 	unsigned int flags;
> 
> 	printf("Dumping open files for %d\n", pid);
> 
> 	sprintf(pid_fd_dir, "/proc/%d/fd", pid);
> 	fd_dir = opendir(pid_fd_dir);
> 	if (fd_dir == NULL) {
> 		perror("Can't open fd dir");
> 		return -1;
> 	}
> 
> 	while ((de = readdir(fd_dir)) != NULL) {
> 		if (de->d_name[0] == '.')
> 			continue;
> 
> 		if (read_fd_params(pid, de->d_name, &pos, &flags))
> 			return 1;
> 
> 		if (dump_one_fd(dirfd(fd_dir), de->d_name, pos, flags))
> 			return 1;
> 	}
> 
> 	closedir(fd_dir);
> 	return 0;
> }
> 
> #define PAGE_SIZE	4096
> #define PAGE_RSS	0x1
> 
> static unsigned long rawhex(char *str, char **end)
> {
> 	unsigned long ret = 0;
> 
> 	while (1) {
> 		if (str[0] >= '0' && str[0] <= '9') {
> 			ret <<= 4;
> 			ret += str[0] - '0';
> 		} else if (str[0] >= 'a' && str[0] <= 'f') {
> 			ret <<= 4;
> 			ret += str[0] - 'a' + 0xA;
> 		} else if (str[0] >= 'A' && str[0] <= 'F') {
> 			ret <<= 4;
> 			ret += str[0] - 'A' + 0xA;
> 		} else {
> 			if (end)
> 				*end = str;
> 			return ret;
> 		}
> 
> 		str++;
> 	}
> }

nit: I haven't looked closely enough to see where rawhex is being used,
	but is there's no suitable library function for this?

> 
> static void map_desc_parm(char *desc, unsigned long *pgoff, unsigned long *len)
> {
> 	char *s;
> 	unsigned long start, end;
> 
> 	start = rawhex(desc, &s);
> 	if (*s != '-') {
> 		goto bug;
> 	}
> 
> 	end = rawhex(s + 1, &s);
> 	if (*s != ' ') {
> 		goto bug;
> 	}
> 
> 	s = strchr(s + 1, ' ');
> 	*pgoff = rawhex(s + 1, &s);
> 	if (*s != ' ') {
> 		goto bug;
> 	}
> 
> 	if (start > end)
> 		goto bug;
> 
> 	*len = end - start;
> 
> 	if (*len % PAGE_SIZE) {
> 		goto bug;
> 	}
> 	if (*pgoff % PAGE_SIZE) {
> 		goto bug;
> 	}
> 
> 	return;
> bug:
> 	fprintf(stderr, "BUG\n");
> 	exit(1);
> }
> 
> static int dump_map_pages(int lfd, unsigned long start, unsigned long pgoff, unsigned long len)
> {
> 	unsigned int nrpages, pfn;
> 	void *mem;
> 	unsigned char *mc;
> 
> 	printf("\t\tDumping pages start %x len %x off %x\n", start, len, pgoff);
> 	mem = mmap(NULL, len, PROT_READ, MAP_FILE | MAP_PRIVATE, lfd, pgoff);
> 	if (mem == MAP_FAILED) {
> 		perror("Can't map");
> 		return 1;
> 	}
> 
> 	nrpages = len / PAGE_SIZE;
> 	mc = malloc(nrpages);
> 	if (mincore(mem, len, mc)) {
> 		perror("Can't mincore mapping");
> 		return 1;
> 	}
> 
> 	for (pfn = 0; pfn < nrpages; pfn++)
> 		if (mc[pfn] & PAGE_RSS) {
> 			__u64 vaddr;
> 
> 			vaddr = start + pfn * PAGE_SIZE;
> 			write(pages_img, &vaddr, 8);
> 			write(pages_img, mem + pfn * PAGE_SIZE, PAGE_SIZE);
> 		}
> 
> 	munmap(mem, len);
> 
> 	return 0;
> }
> 
> static int dump_anon_private_map(char *start)
> {
> 	printf("\tSkipping anon private mapping at %s\n", start);
> 	return 0;
> }
> 
> static int dump_anon_shared_map(char *_start, char *mdesc, int lfd, struct stat *st)
> {
> 	unsigned long pgoff, len;
> 	struct shmem_entry e;
> 	unsigned long start;
> 	struct stat buf;
> 
> 	map_desc_parm(mdesc, &pgoff, &len);
> 
> 	start = rawhex(_start, NULL);
> 	e.start = start;
> 	e.end = start + len;
> 	e.shmid = st->st_ino;
> 
> 	write(shmem_img, &e, sizeof(e));
> 
> 	if (dump_map_pages(lfd, start, pgoff, len))
> 		return 1;
> 
> 	close(lfd);
> 	return 0;
> }
> 
> static int dump_file_shared_map(char *start, char *mdesc, int lfd)
> {
> 	printf("\tSkipping file shared mapping at %s\n", start);
> 	close(lfd);
> 	return 0;
> }

Shouldn't this be an error since it appears these shared mappings
are currently unsupported?

> 
> static int dump_file_private_map(char *_start, char *mdesc, int lfd)
> {
> 	unsigned long pgoff, len;
> 	unsigned long start;
> 
> 	map_desc_parm(mdesc, &pgoff, &len);
> 
> 	start = rawhex(_start, NULL);
> 	if (dump_one_reg_file(FDINFO_MAP, start, lfd, 0, 0, O_RDONLY))
> 		return 1;
> 
> 	close(lfd);
> 	return 0;
> }
> 
> static int dump_one_mapping(char *mdesc, DIR *mfd_dir)
> {
> 	char *flags, *tmp;
> 	char map_start[32];
> 	int lfd;
> 	struct stat st_buf;
> 
> 	tmp = strchr(mdesc, '-');
> 	memset(map_start, 0, sizeof(map_start));
> 	strncpy(map_start, mdesc, tmp - mdesc);
> 	flags = strchr(mdesc, ' ');
> 	flags++;
> 
> 	printf("\tDumping %s\n", map_start);
> 	lfd = openat(dirfd(mfd_dir), map_start, O_RDONLY);
> 	if (lfd == -1) {
> 		if (errno != ENOENT) {
> 			perror("Can't open mapping");
> 			return 1;
> 		}
> 
> 		if (flags[3] != 'p') {
> 			fprintf(stderr, "Bogus mapping [%s]\n", mdesc);
> 			return 1;
> 		}
> 
> 		return dump_anon_private_map(map_start);
> 	}
> 
> 	if (fstat(lfd, &st_buf) < 0) {
> 		perror("Can't stat mapping!");
> 		return 1;
> 	}
> 
> 	if (!S_ISREG(st_buf.st_mode)) {
> 		perror("Can't handle non-regular mapping");
> 		return 1;
> 	}
> 
> 	if (MAJOR(st_buf.st_dev) == 0) {
> 		if (flags[3] != 's') {
> 			fprintf(stderr, "Bogus mapping [%s]\n", mdesc);
> 			return 1;
> 		}
> 
> 		/* FIXME - this can be tmpfs visible file mapping */
> 		return dump_anon_shared_map(map_start, mdesc, lfd, &st_buf);
> 	}
> 
> 	if (flags[3] == 'p')
> 		return dump_file_private_map(map_start, mdesc, lfd);
> 	else
> 		return dump_file_shared_map(map_start, mdesc, lfd);
> }
> 
> static int dump_task_ext_mm(int pid)
> {
> 	char path[64];
> 	DIR *mfd_dir;
> 	FILE *maps;
> 
> 	printf("Dumping mappings for %d\n", pid);
> 
> 	sprintf(path, "/proc/%d/mfd", pid);
> 	mfd_dir = opendir(path);
> 	if (mfd_dir == NULL) {
> 		perror("Can't open mfd dir");
> 		return -1;
> 	}
> 
> 	sprintf(path, "/proc/%d/maps", pid);
> 	maps = fopen(path, "r");
> 	if (maps == NULL) {
> 		perror("Can't open maps file");
> 		return 1;
> 	}
> 
> 	while (fgets(big_tmp_str, sizeof(big_tmp_str), maps) != NULL)
> 		if (dump_one_mapping(big_tmp_str, mfd_dir))
> 			return 1;
> 
> 	fclose(maps);
> 	closedir(mfd_dir);
> 	return 0;
> }
> 
> static int dump_task_state(int pid)
> {
> 	char path[64];
> 	int dump_fd;
> 	void *mem;
> 
> 	printf("Dumping task image for %d\n", pid);
> 	sprintf(path, "/proc/%d/dump", pid);
> 	dump_fd = open(path, O_RDONLY);
> 	if (dump_fd < 0) {
> 		perror("Can't open dump file");
> 		return 1;
> 	}
> 
> 	mem = mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_ANON | MAP_PRIVATE, 0, 0);
> 	if (mem == MAP_FAILED) {
> 		perror("Can't get mem");
> 		return 1;
> 	}
> 
> 	while (1) {
> 		int r, w;
> 
> 		r = read(dump_fd, mem, 4096);
> 		if (r == 0)
> 			break;
> 		if (r < 0) {
> 			perror("Can't read dump file");
> 			return 1;
> 		}
> 
> 		w = 0;
> 		while (w < r) {
> 			int ret;
> 
> 			ret = write(core_img, mem + w, r - w);
> 			if (ret <= 0) {
> 				perror("Can't write core");
> 				return 1;
> 			}
> 
> 			w += ret;
> 		}
> 	}
> 
> 	munmap(mem, 4096);
> 	close(dump_fd);
> 
> 	return 0;
> }
> 
> static int dump_one_task(int pid, int stop)
> {
> 	printf("Dumping task %d\n", pid);
> 
> 	if (prep_img_files(pid))
> 		return 1;
> 
> 	if (stop && stop_task(pid))
> 		goto err_task;
> 
> 	if (dump_task_files(pid))
> 		goto err;
> 
> 	if (dump_task_ext_mm(pid))
> 		goto err;
> 
> 	if (dump_task_state(pid))
> 		goto err;
> 
> 	if (stop)
> 		continue_task(pid);
> 
> 	printf("Dump is complete\n");
> 	return 0;
> 
> err:
> 	if (stop)
> 		continue_task(pid);
> err_task:
> 	kill_imgfiles(pid);
> 	return 1;
> }
> 
> static int pstree_fd;
> static char big_tmp_str[4096];
> static int *pids, nr_pids;
> 
> static char *get_children_pids(int pid)
> {
> 	FILE *f;
> 	int len;
> 	char *ret, *tmp;
> 
> 	sprintf(big_tmp_str, "/proc/%d/status", pid);
> 	f = fopen(big_tmp_str, "r");
> 	if (f == NULL)
> 		return NULL;
> 
> 	while ((fgets(big_tmp_str, sizeof(big_tmp_str), f)) != NULL) {
> 		if (strncmp(big_tmp_str, "Children:", 9))
> 			continue;
> 
> 		tmp = big_tmp_str + 10;
> 		len = strlen(tmp);
> 		ret = malloc(len + 1);
> 		strcpy(ret, tmp);
> 		if (len)
> 			ret[len - 1] = ' ';
> 
> 		fclose(f);
> 		return ret;
> 	}
> 
> 	fclose(f);
> 	return NULL;
> }
> 
> static int dump_pid_and_children(int pid)
> {
> 	struct pstree_entry e;
> 	char *chlist, *tmp, *tmp2;
> 
> 	printf("\tReading %d children list\n", pid);
> 	chlist = get_children_pids(pid);
> 	if (chlist == NULL)
> 		return 1;
> 
> 	printf("\t%d has children %s\n", pid, chlist);
> 
> 	e.pid = pid;
> 	e.nr_children = 0;
> 
> 	pids = realloc(pids, (nr_pids + 1) * sizeof(int));
> 	pids[nr_pids++] = e.pid;
> 
> 	tmp = chlist;
> 	while ((tmp = strchr(tmp, ' ')) != NULL) {
> 		tmp++;
> 		e.nr_children++;
> 	}
> 
> 	write(pstree_fd, &e, sizeof(e));
> 	tmp = chlist;
> 	while (1) {
> 		__u32 cpid;
> 
> 		cpid = strtol(tmp, &tmp, 10);
> 		if (cpid == 0)
> 			break;
> 		if (*tmp != ' ') {
> 			fprintf(stderr, "Error in string with children!\n");
> 			return 1;
> 		}
> 
> 		write(pstree_fd, &cpid, sizeof(cpid));
> 		tmp++;
> 	}
> 
> 	tmp = chlist;
> 	while ((tmp2 = strchr(tmp, ' ')) != NULL) {
> 		*tmp2 = '\0';
> 		if (dump_pid_and_children(atoi(tmp)))
> 			return 1;
> 		tmp = tmp2 + 1;
> 	}
> 
> 	free(chlist);
> 	return 0;
> }
> 
> static int __dump_all_tasks(void)
> {
> 	int i, pid;
> 
> 	printf("Dumping tasks' images for");
> 	for (i = 0; i < nr_pids; i++)
> 		printf(" %d", pids[i]);
> 	printf("\n");
> 
> 	printf("Stopping tasks\n");
> 	for (i = 0; i < nr_pids; i++)
> 		if (stop_task(pids[i]))
> 			goto err;
> 
> 	for (i = 0; i < nr_pids; i++) {
> 		if (dump_one_task(pids[i], 0))
> 			goto err;
> 	}
> 
> 	printf("Resuming tasks\n");
> 	for (i = 0; i < nr_pids; i++)
> 		continue_task(pids[i]);
> 
> 	return 0;
> 
> err:
> 	for (i = 0; i < nr_pids; i++)
> 		continue_task(pids[i]);
> 	return 1;
> 
> }
> 
> static int dump_all_tasks(int pid)
> {
> 	char *chlist;
> 	__u32 type;
> 
> 	pids = NULL;
> 	nr_pids = 0;
> 
> 	printf("Dumping process tree, start from %d\n", pid);
> 
> 	sprintf(big_tmp_str, "pstree-%d.img", pid);
> 	pstree_fd = open(big_tmp_str, O_WRONLY | O_CREAT | O_EXCL, 0600);
> 	if (pstree_fd < 0) {
> 		perror("Can't create pstree");
> 		return 1;
> 	}
> 
> 	type = PSTREE_MAGIC;
> 	write(pstree_fd, &type, sizeof(type));
> 
> 	if (dump_pid_and_children(pid))
> 		return 1;
> 
> 	close(pstree_fd);
> 
> 	return __dump_all_tasks();
> }
> 
> int main(int argc, char **argv)
> {
> 	if (argc != 3)
> 		goto usage;
> 	if (argv[1][0] != '-')
> 		goto usage;
> 	if (argv[1][1] == 'p')
> 		return dump_one_task(atoi(argv[2]), 1);
> 	if (argv[1][1] == 't')
> 		return dump_all_tasks(atoi(argv[2]));
> 
> usage:
> 	printf("Usage: %s (-p|-t) <pid>\n", argv[0]);
> 	return 1;
> }

> #include <stdio.h>
> #include <unistd.h>
> #include <signal.h>
> #include <dirent.h>
> #include <string.h>
> #include <fcntl.h>
> #include <sys/stat.h>
> #include <errno.h>
> #include <linux/kdev_t.h>
> #include <stdlib.h>
> #include <sys/mman.h>
> #include <sys/sendfile.h>
> 
> #define PAGE_SIZE	4096
> 
> #include <linux/types.h>
> #include "img_structs.h"
> #include "binfmt_img.h"
> 
> struct fmap_fd {
> 	unsigned long start;
> 	int fd;
> 	struct fmap_fd *next;
> };
> 
> static struct fmap_fd *fmap_fds;
> 
> struct shmem_info {
> 	unsigned long start;
> 	unsigned long end;
> 	unsigned long id;
> 	int pid;
> 	int real_pid;
> };
> 
> static struct shmem_info *shmems;
> static int nr_shmems;
> 
> struct pipes_info {
> 	unsigned int id;
> 	int pid;
> 	int real_pid;
> 	int read_fd;
> 	int write_fd;
> 	int users;
> };
> 
> static struct pipes_info *pipes;
> static int nr_pipes;
> 
> static void show_saved_shmems(void)
> {
> 	int i;
> 
> 	printf("\tSaved shmems:\n");
> 	for (i = 0; i < nr_shmems; i++)
> 		printf("\t\t%016lx %lx %d\n", shmems[i].start, shmems[i].id, shmems[i].pid);
> }
> 
> static void show_saved_pipes(void)
> {
> 	int i;
> 
> 	printf("\tSaved pipes:\n");
> 	for (i = 0; i < nr_pipes; i++)
> 		printf("\t\t%x -> %d\n", pipes[i].id, pipes[i].pid);
> }
> 
> static struct shmem_info *search_shmem(unsigned long addr, unsigned long id)
> {
> 	int i;
> 
> 	for (i = 0; i < nr_shmems; i++) {
> 		struct shmem_info *si;
> 
> 		si = shmems + i;
> 		if (si->start <= addr && si->end >= addr && si->id == id)
> 			return si;
> 	}
> 
> 	return NULL;
> }
> 
> static struct pipes_info *search_pipes(unsigned int pipeid)
> {
> 	int i;
> 
> 	for (i = 0; i < nr_pipes; i++) {
> 		struct pipes_info *pi;
> 
> 		pi = pipes + i;
> 		if (pi->id == pipeid)
> 			return pi;
> 	}
> 
> 	return NULL;
> }
> 
> static void shmem_update_real_pid(int vpid, int rpid)
> {
> 	int i;
> 
> 	for (i = 0; i < nr_shmems; i++)
> 		if (shmems[i].pid == vpid)
> 			shmems[i].real_pid = rpid;
> }
> 
> static int shmem_wait_and_open(struct shmem_info *si)
> {
> 	/* FIXME - not good */
> 	char path[128];
> 	unsigned long time = 1000;
> 
> 	sleep(1);
> 
> 	while (si->real_pid == 0)
> 		usleep(time);
> 
> 	sprintf(path, "/proc/%d/mfd/0x%lx", si->real_pid, si->start);
> 	while (1) {
> 		int ret;
> 
> 		ret = open(path, O_RDWR);
> 		if (ret > 0)
> 			return ret;
> 
> 		if (ret < 0 && errno != ENOENT) {
> 			perror("     Can't stat shmem");
> 			return -1;
> 		}
> 
> 		printf("Waiting for [%s] to appear\n", path);
> 		if (time < 20000000)
> 			time <<= 1;
> 		usleep(time);
> 	}
> }
> 
> static int try_to_add_shmem(int pid, struct shmem_entry *e)
> {
> 	int i;
> 
> 	for (i = 0; i < nr_shmems; i++) {
> 		if (shmems[i].start != e->start || shmems[i].id != e->shmid)
> 			continue;
> 
> 		if (shmems[i].end != e->end) {
> 			printf("Bogus shmem\n");
> 			return 1;
> 		}
> 
> 		if (shmems[i].pid > pid)
> 			shmems[i].pid = pid;
> 
> 		return 0;
> 	}
> 
> 	if ((nr_shmems + 1) * sizeof(struct shmem_info) >= 4096) {
> 		printf("OOM storing shmems\n");
> 		return 1;
> 	}
> 
> 	shmems[nr_shmems].start = e->start;
> 	shmems[nr_shmems].end = e->end;
> 	shmems[nr_shmems].id = e->shmid;
> 	shmems[nr_shmems].pid = pid;
> 	shmems[nr_shmems].real_pid = 0;
> 	nr_shmems++;
> 
> 	return 0;
> }
> 
> static int try_to_add_pipe(int pid, struct pipes_entry *e, int p_fd)
> {
> 	int i;
> 
> 	for (i = 0; i < nr_pipes; i++) {
> 		if (pipes[i].id != e->pipeid)
> 			continue;
> 
> 		if (pipes[i].pid > pid)
> 			pipes[i].pid = pid;
> 		pipes[i].users++;
> 
> 		return 0;
> 	}
> 
> 	if ((nr_pipes + 1) * sizeof(struct pipes_info) >= 4096) {
> 		printf("OOM storing pipes\n");
> 		return 1;
> 	}
> 
> 	pipes[nr_pipes].id = e->pipeid;
> 	pipes[nr_pipes].pid = pid;
> 	pipes[nr_pipes].real_pid = 0;
> 	pipes[nr_pipes].read_fd = 0;
> 	pipes[nr_pipes].write_fd = 0;
> 	pipes[nr_pipes].users = 1;
> 	nr_pipes++;
> 
> 	return 0;
> }
> 
> static int prepare_shmem_pid(int pid)
> {
> 	char path[64];
> 	int sh_fd;
> 	__u32 type = 0;
> 
> 	sprintf(path, "shmem-%d.img", pid);
> 	sh_fd = open(path, O_RDONLY);
> 	if (sh_fd < 0) {
> 		perror("Can't open shmem info");
> 		return 1;
> 	}
> 
> 	read(sh_fd, &type, sizeof(type));
> 	if (type != SHMEM_MAGIC) {
> 		perror("Bad shmem magic");
> 		return 1;
> 	}
> 
> 	while (1) {
> 		struct shmem_entry e;
> 		int ret;
> 
> 		ret = read(sh_fd, &e, sizeof(e));
> 		if (ret == 0)
> 			break;
> 		if (ret != sizeof(e)) {
> 			perror("Can't read shmem entry");
> 			return 1;
> 		}
> 
> 		if (try_to_add_shmem(pid, &e))
> 			return 1;
> 	}
> 
> 	close(sh_fd);
> 	return 0;
> }
> 
> static int prepare_pipes_pid(int pid)
> {
> 	char path[64];
> 	int p_fd;
> 	__u32 type = 0;
> 
> 	sprintf(path, "pipes-%d.img", pid);
> 	p_fd = open(path, O_RDONLY);
> 	if (p_fd < 0) {
> 		perror("Can't open pipes image");
> 		return 1;
> 	}
> 
> 	read(p_fd, &type, sizeof(type));
> 	if (type != PIPES_MAGIC) {
> 		perror("Bad pipes magin");
> 		return 1;
> 	}
> 
> 	while (1) {
> 		struct pipes_entry e;
> 		int ret;
> 
> 		ret = read(p_fd, &e, sizeof(e));
> 		if (ret == 0)
> 			break;
> 		if (ret != sizeof(e)) {
> 			fprintf(stderr, "Read pipes for %s failed %d of %d read\n",
> 					path, ret, sizeof(e));
> 			perror("Can't read pipes entry");
> 			return 1;
> 		}
> 
> 		if (try_to_add_pipe(pid, &e, p_fd))
> 			return 1;
> 
> 		lseek(p_fd, e.bytes, SEEK_CUR);
> 	}
> 
> 	close(p_fd);
> 	return 0;
> }
> 
> static int prepare_shared(int ps_fd)
> {
> 	printf("Preparing info about shared resources\n");
> 
> 	nr_shmems = 0;
> 	shmems = mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_SHARED | MAP_ANON, 0, 0);
> 	if (shmems == MAP_FAILED) {
> 		perror("Can't map shmems");
> 		return 1;
> 	}
> 
> 	pipes = mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_SHARED | MAP_ANON, 0, 0);
> 	if (pipes == MAP_FAILED) {
> 		perror("Can't map pipes");
> 		return 1;
> 	}
> 
> 	while (1) {
> 		struct pstree_entry e;
> 		int ret;
> 
> 		ret = read(ps_fd, &e, sizeof(e));
> 		if (ret == 0)
> 			break;
> 
> 		if (ret != sizeof(e)) {
> 			perror("Can't read ps");
> 			return 1;
> 		}
> 
> 		if (prepare_shmem_pid(e.pid))
> 			return 1;
> 
> 		if (prepare_pipes_pid(e.pid))
> 			return 1;
> 
> 		lseek(ps_fd, e.nr_children * sizeof(__u32), SEEK_CUR);
> 	}
> 
> 	lseek(ps_fd, sizeof(__u32), SEEK_SET);
> 
> 	show_saved_shmems();
> 	show_saved_pipes();
> 
> 	return 0;
> }
> 
> static struct fmap_fd *pop_fmap_fd(unsigned long start)
> {
> 	struct fmap_fd **p, *r;
> 
> 	for (p = &fmap_fds; *p != NULL; p = &(*p)->next) {
> 		if ((*p)->start != start)
> 			continue;
> 
> 		r = *p;
> 		*p = r->next;
> 		return r;
> 	}
> 
> 	return NULL;
> }
> 
> static int open_fe_fd(struct fdinfo_entry *fe, int fd)
> {
> 	char path[PATH_MAX];
> 	int tmp;
> 
> 	if (read(fd, path, fe->len) != fe->len) {
> 		fprintf(stderr, "Error reading path");
> 		return -1;
> 	}
> 
> 	path[fe->len] = '\0';
> 
> 	tmp = open(path, fe->flags);
> 	if (tmp < 0) {
> 		perror("Can't open file");
> 		return -1;
> 	}
> 
> 	lseek(tmp, fe->pos, SEEK_SET);
> 
> 	return tmp;
> }
> 
> static int reopen_fd(int old_fd, int new_fd)
> {
> 	int tmp;
> 
> 	if (old_fd != new_fd) {
> 		tmp = dup2(old_fd, new_fd);
> 		if (tmp < 0)
> 			return tmp;
> 
> 		close(old_fd);
> 	}
> 
> 	return new_fd;
> }
> 
> static int open_fd(int pid, struct fdinfo_entry *fe, int *cfd)
> {
> 	int fd, tmp;
> 
> 	if (*cfd == (int)fe->addr) {
> 		tmp = dup(*cfd);
> 		if (tmp < 0) {
> 			perror("Can't dup file");
> 			return 1;
> 		}
> 
> 		*cfd = tmp;
> 	}
> 
> 	tmp = open_fe_fd(fe, *cfd);
> 	if (tmp < 0)
> 		return 1;
> 
> 	fd = reopen_fd(tmp, (int)fe->addr);
> 	if (fd < 0) {
> 		perror("Can't dup");
> 		return 1;
> 	}
> 
> 	return 0;
> }
> 
> static int open_fmap(int pid, struct fdinfo_entry *fe, int fd)
> {
> 	int tmp;
> 	struct fmap_fd *new;
> 
> 	tmp = open_fe_fd(fe, fd);
> 	if (tmp < 0)
> 		return 1;
> 
> 	printf("%d:\t\tWill map %x to %d\n", pid, fe->addr, tmp);
> 	new = malloc(sizeof(*new));
> 	new->start = fe->addr;
> 	new->fd = tmp;
> 	new->next = fmap_fds;
> 	fmap_fds = new;
> 
> 	return 0;
> }
> 
> static int prepare_fds(int pid)
> {
> 	__u32 mag;
> 	char path[64];
> 	int fdinfo_fd;
> 
> 	printf("%d: Opening files\n", pid);
> 
> 	sprintf(path, "fdinfo-%d.img", pid);
> 	fdinfo_fd = open(path, O_RDONLY);
> 	if (fdinfo_fd < 0) {
> 		perror("Can't open fdinfo");
> 		return 1;
> 	}
> 
> 	read(fdinfo_fd, &mag, 4);
> 	if (mag != FDINFO_MAGIC) {
> 		fprintf(stderr, "Bad file\n");
> 		return 1;
> 	}
> 
> 	while (1) {
> 		int ret;
> 		struct fdinfo_entry fe;
> 
> 		ret = read(fdinfo_fd, &fe, sizeof(fe));
> 		if (ret == 0) {
> 			close(fdinfo_fd);
> 			return 0;
> 		}
> 
> 		if (ret < 0) {
> 			perror("Can't read file");
> 			return 1;
> 		}
> 		if (ret != sizeof(fe)) {
> 			fprintf(stderr, "Error reading\n");
> 			return 1;
> 		}
> 
> 		printf("\t%d: Got fd for %lx type %d namelen %d\n", pid,
> 				(unsigned long)fe.addr, fe.type, fe.len);
> 		switch (fe.type) {
> 		case FDINFO_FD:
> 			if (open_fd(pid, &fe, &fdinfo_fd))
> 				return 1;
> 
> 			break;
> 		case FDINFO_MAP:
> 			if (open_fmap(pid, &fe, fdinfo_fd))
> 				return 1;
> 
> 			break;
> 		default:
> 			fprintf(stderr, "Some bullshit in a file\n");
> 			return 1;
> 		}
> 	}
> }
> 
> struct shmem_to_id {
> 	unsigned long addr;
> 	unsigned long end;
> 	unsigned long id;
> 	struct shmem_to_id *next;
> };
> 
> static struct shmem_to_id *my_shmem_ids;
> 
> static unsigned long find_shmem_id(unsigned long addr)
> {
> 	struct shmem_to_id *si;
> 
> 	for (si = my_shmem_ids; si != NULL; si = si->next)
> 		if (si->addr <= addr && si->end >= addr)
> 			return si->id;
> 
> 	return 0;
> }
> 
> static void save_shmem_id(struct shmem_entry *e)
> {
> 	struct shmem_to_id *si;
> 
> 	si = malloc(sizeof(*si));
> 	si->addr = e->start;
> 	si->end = e->end;
> 	si->id = e->shmid;
> 	si->next = my_shmem_ids;
> 	my_shmem_ids = si;
> }
> 
> static int prepare_shmem(int pid)
> {
> 	char path[64];
> 	int sh_fd;
> 	__u32 type = 0;
> 
> 	sprintf(path, "shmem-%d.img", pid);
> 	sh_fd = open(path, O_RDONLY);
> 	if (sh_fd < 0) {
> 		perror("Can't open shmem info");
> 		return 1;
> 	}
> 
> 	read(sh_fd, &type, sizeof(type));
> 	if (type != SHMEM_MAGIC) {
> 		perror("Bad shmem magic");
> 		return 1;
> 	}
> 
> 	while (1) {
> 		struct shmem_entry e;
> 		int ret;
> 
> 		ret = read(sh_fd, &e, sizeof(e));
> 		if (ret == 0)
> 			break;
> 		if (ret != sizeof(e)) {
> 			perror("Can't read shmem entry");
> 			return 1;
> 		}
> 
> 		save_shmem_id(&e);
> 	}
> 
> 	close(sh_fd);
> 	return 0;
> }
> 
> static int try_fixup_file_map(int pid, struct binfmt_vma_image *vi, int fd)
> {
> 	struct fmap_fd *fmfd;
> 
> 	fmfd = pop_fmap_fd(vi->start);
> 	if (fmfd != NULL) {
> 		printf("%d: Fixing %lx vma to %d fd\n", pid, vi->start, fmfd->fd);
> 		lseek(fd, -sizeof(*vi), SEEK_CUR);
> 		vi->fd = fmfd->fd;
> 		if (write(fd, vi, sizeof(*vi)) != sizeof(*vi)) {
> 			perror("Can't write img");
> 			return 1;
> 		}
> 
> 		free(fmfd);
> 	}
> 
> 	return 0;
> }
> 
> static int try_fixup_shared_map(int pid, struct binfmt_vma_image *vi, int fd)
> {
> 	struct shmem_info *si;
> 	unsigned long id;
> 
> 	id = find_shmem_id(vi->start);
> 	if (id == 0)
> 		return 0;
> 
> 	si = search_shmem(vi->start, id);
> 	printf("%d: Search for %016lx shmem %p/%d\n", pid, vi->start, si, si ? si->pid : -1);
> 
> 	if (si == NULL) {
> 		fprintf(stderr, "Can't find my shmem %016lx\n", vi->start);
> 		return 1;
> 	}
> 
> 	if (si->pid != pid) {
> 		int sh_fd;
> 
> 		sh_fd = shmem_wait_and_open(si);
> 		printf("%d: Fixing %lx vma to %x/%d shmem -> %d\n", pid, vi->start, si->id, si->pid, sh_fd);
> 		if (fd < 0) {
> 			perror("Can't open shmem");
> 			return 1;
> 		}
> 
> 		lseek(fd, -sizeof(*vi), SEEK_CUR);
> 		vi->fd = sh_fd;
> 		if (write(fd, vi, sizeof(*vi)) != sizeof(*vi)) {
> 			perror("Can't write img");
> 			return 1;
> 		}
> 	}
> 
> 	return 0;
> }
> 
> static int fixup_vma_fds(int pid, int fd)
> {
> 	lseek(fd, sizeof(struct binfmt_img_header) +
> 			sizeof(struct binfmt_regs_image) +
> 			sizeof(struct binfmt_mm_image), SEEK_SET);
> 
> 	while (1) {
> 		struct binfmt_vma_image vi;
> 
> 		if (read(fd, &vi, sizeof(vi)) != sizeof(vi)) {
> 			perror("Can't read");
> 			return 1;
> 		}
> 
> 		if (vi.start == 0 && vi.end == 0)
> 			return 0;
> 
> 		printf("%d: Fixing %016lx-%016lx %016lx vma\n", pid, vi.start, vi.end, vi.pgoff);
> 		if (try_fixup_file_map(pid, &vi, fd))
> 			return 1;
> 
> 		if (try_fixup_shared_map(pid, &vi, fd))
> 			return 1;
> 	}
> }
> 
> static inline int should_restore_page(int pid, unsigned long vaddr)
> {
> 	struct shmem_info *si;
> 	unsigned long id;
> 
> 	id = find_shmem_id(vaddr);
> 	if (id == 0)
> 		return 1;
> 
> 	si = search_shmem(vaddr, id);
> 	return si->pid == pid;
> }
> 
> static int fixup_pages_data(int pid, int fd)
> {
> 	char path[128];
> 	int shfd;
> 	__u32 mag;
> 	__u64 vaddr;
> 
> 	sprintf(path, "pages-%d.img", pid);
> 	shfd = open(path, O_RDONLY);
> 	if (shfd < 0) {
> 		perror("Can't open shmem image");
> 		return 1;
> 	}
> 
> 	read(shfd, &mag, sizeof(mag));
> 	if (mag != PAGES_MAGIC) {
> 		fprintf(stderr, "Bad shmem image\n");
> 		return 1;
> 	}
> 
> 	lseek(fd, -sizeof(struct binfmt_page_image), SEEK_END);
> 	read(fd, &vaddr, sizeof(vaddr));
> 	if (vaddr != 0) {
> 		printf("SHIT %lx\n", (unsigned long)vaddr);
> 		return 1;
> 	}
> 	lseek(fd, -sizeof(struct binfmt_page_image), SEEK_END);
> 
> 	while (1) {
> 		int ret;
> 
> 		ret = read(shfd, &vaddr, sizeof(vaddr));
> 		if (ret == 0)
> 			break;
> 
> 		if (ret < 0 || ret != sizeof(vaddr)) {
> 			perror("Can't read vaddr");
> 			return 1;
> 		}
> 
> 		if (vaddr == 0)
> 			break;
> 
> 		if (!should_restore_page(pid, vaddr)) {
> 			lseek(shfd, PAGE_SIZE, SEEK_CUR);
> 			continue;
> 		}
> 
> //		printf("Copy page %lx to image\n", (unsigned long)vaddr);
> 		write(fd, &vaddr, sizeof(vaddr));
> 		sendfile(fd, shfd, NULL, PAGE_SIZE);
> 	}
> 
> 	close(shfd);
> 	vaddr = 0;
> 	write(fd, &vaddr, sizeof(vaddr));
> 	return 0;
> }
> 
> static int prepare_image_maps(int fd, int pid)
> {
> 	printf("%d: Fixing maps before executing image\n", pid);
> 
> 	if (fixup_vma_fds(pid, fd))
> 		return 1;
> 
> 	if (fixup_pages_data(pid, fd))
> 		return 1;
> 
> 	close(fd);
> 	return 0;
> }
> 
> static int execute_image(int pid)
> {
> 	char path[128];
> 	int fd, fd_new;
> 	struct stat buf;
> 
> 	sprintf(path, "core-%d.img", pid);
> 	fd = open(path, O_RDONLY);
> 	if (fd < 0) {
> 		perror("Can't open exec image");
> 		return 1;
> 	}
> 
> 	if (fstat(fd, &buf)) {
> 		perror("Can't stat");
> 		return 1;
> 	}
> 
> 	sprintf(path, "core-%d.img.out", pid);
> 	fd_new = open(path, O_RDWR | O_CREAT | O_EXCL, 0700);
> 	if (fd_new < 0) {
> 		perror("Can't open new image");
> 		return 1;
> 	}
> 
> 	printf("%d: Preparing execution image\n", pid);
> 	sendfile(fd_new, fd, NULL, buf.st_size);
> 	close(fd);
> 
> 	if (fchmod(fd_new, 0700)) {
> 		perror("Can't prepare exec image");
> 		return 1;
> 	}
> 
> 	if (prepare_image_maps(fd_new, pid))
> 		return 1;
> 
> 	printf("%d/%d EXEC IMAGE\n", pid, getpid());
> 	return execl(path, path, NULL);

How are you going to restore O_CLOEXEC flags?

> }
> 
> static int create_pipe(int pid, struct pipes_entry *e, struct pipes_info *pi, int pipes_fd)
> {
> 	int pfd[2], tmp;
> 	unsigned long time = 1000;
> 
> 	printf("\t%d: Creating pipe %x\n", pid, e->pipeid);
> 
> 	if (pipe(pfd) < 0) {
> 		perror("Can't create pipe");
> 		return 1;
> 	}
> 
> 	if (e->bytes) {
> 		printf("\t%d: Splicing data to %d\n", pid, pfd[1]);
> 
> 		tmp = splice(pipes_fd, NULL, pfd[1], NULL, e->bytes, 0);
> 		if (tmp != e->bytes) {
> 			fprintf(stderr, "Wanted to restore %ld bytes, but got %ld\n",
> 					e->bytes, tmp);
> 			if (tmp < 0)
> 				perror("Error splicing data");
> 			return 1;
> 		}
> 	}
> 
> 	pi->read_fd = pfd[0];
> 	pi->write_fd = pfd[1];
> 	pi->real_pid = getpid();
> 
> 	printf("\t%d: Done, waiting for others on %d pid with r:%d w:%d\n",
> 			pid, pi->real_pid, pfd[0], pfd[1]);
> 
> 	while (1) {
> 		if (pi->users == 1) /* only I left */
> 			break;
> 
> 		printf("\t%d: Waiting for %x pipe to attach (%d users left)\n",
> 				pid, e->pipeid, pi->users - 1);
> 		if (time < 20000000)
> 			time <<= 1;
> 		usleep(time);
> 	}
> 
> 	printf("\t%d: All is ok - reopening pipe for %d\n", pid, e->fd);
> 	if (e->flags & O_WRONLY) {
> 		close(pfd[0]);
> 		tmp = reopen_fd(pfd[1], e->fd);
> 	} else {
> 		close(pfd[1]);
> 		tmp = reopen_fd(pfd[0], e->fd);
> 	}
> 
> 	if (tmp < 0) {
> 		perror("Can't dup pipe fd");
> 		return 1;
> 	}
> 
> 	return 0;
> }
> 
> static int attach_pipe(int pid, struct pipes_entry *e, struct pipes_info *pi)
> {
> 	char path[128];
> 	int tmp, fd;
> 
> 	printf("\t%d: Wating for pipe %x to appear\n", pid, e->pipeid);
> 
> 	while (pi->real_pid == 0)
> 		usleep(1000);
> 
> 	if (e->flags & O_WRONLY)
> 		tmp = pi->write_fd;
> 	else
> 		tmp = pi->read_fd;
> 
> 	sprintf(path, "/proc/%d/fd/%d", pi->real_pid, tmp);
> 	printf("\t%d: Attaching pipe %s\n", pid, path);
> 
> 	fd = open(path, e->flags);
> 	if (fd < 0) {
> 		perror("Can't attach pipe");
> 		return 1;
> 	}
> 
> 	printf("\t%d: Done, reopening for %d\n", pid, e->fd);
> 	pi->users--;
> 	tmp = reopen_fd(fd, e->fd);
> 	if (tmp < 0) {
> 		perror("Can't dup to attach pipe");
> 		return 1;
> 	}
> 
> 	return 0;
> 
> }
> 
> static int open_pipe(int pid, struct pipes_entry *e, int *pipes_fd)
> {
> 	struct pipes_info *pi;
> 
> 	printf("\t%d: Opening pipe %x on fd %d\n", pid, e->pipeid, e->fd);
> 	if (e->fd == *pipes_fd) {
> 		int tmp;
> 
> 		tmp = dup(*pipes_fd);
> 		if (tmp < 0) {
> 			perror("Can't dup file");
> 			return 1;
> 		}
> 
> 		*pipes_fd = tmp;
> 	}
> 
> 	pi = search_pipes(e->pipeid);
> 	if (pi == NULL) {
> 		fprintf(stderr, "BUG: can't find my pipe %x\n", e->pipeid);
> 		return 1;
> 	}
> 
> 	if (pi->pid == pid)
> 		return create_pipe(pid, e, pi, *pipes_fd);
> 	else
> 		return attach_pipe(pid, e, pi);
> }
> 
> static int prepare_pipes(int pid)
> {
> 	char path[64];
> 	int pipes_fd;
> 	__u32 type = 0;
> 
> 	printf("%d: Opening pipes\n", pid);
> 
> 	sprintf(path, "pipes-%d.img", pid);
> 	pipes_fd = open(path, O_RDONLY);
> 	if (pipes_fd < 0) {
> 		perror("Can't open pipes img");
> 		return 1;
> 	}
> 
> 	read(pipes_fd, &type, sizeof(type));
> 	if (type != PIPES_MAGIC) {
> 		perror("Bad pipes file");
> 		return 1;
> 	}
> 
> 	while (1) {
> 		struct pipes_entry e;
> 		int ret;
> 
> 		ret = read(pipes_fd, &e, sizeof(e));
> 		if (ret == 0) {
> 			close(pipes_fd);
> 			return 0;
> 		}
> 		if (ret != sizeof(e)) {
> 			perror("Bad pipes entry");
> 			return 1;
> 		}
> 
> 		if (open_pipe(pid, &e, &pipes_fd))
> 			return 1;
> 	}
> }
> 
> static int restore_one_task(int pid)
> {
> 	printf("%d: Restoring resources\n", pid);
> 
> 	if (prepare_pipes(pid))
> 		return 1;
> 
> 	if (prepare_fds(pid))
> 		return 1;
> 
> 	if (prepare_shmem(pid))
> 		return 1;
> 
> 	return execute_image(pid);
> }
> 
> static int restore_task_with_children(int my_pid, char *pstree_path);
> 
> #if 0
> static inline int fork_with_pid(int pid, char *pstree_path)
> {
> 	/* FIXME - no such ability now */
> 	int ret;
> 
> 	ret = fork();
> 	if (ret == 0) {
> 		ret = restore_task_with_children(pid, pstree_path);
> 		exit(ret);
> 	}
> 
> 	return ret;
> }
> #else
> #define CLONE_CHILD_USEPID      0x02000000
> 
> static int do_child(void *arg)
> {
> 	return restore_task_with_children(getpid(), arg);
> }
> 
> static inline int fork_with_pid(int pid, char *pstree_path)
> {
> 	void *stack;
> 
> 	stack = mmap(0, 4 * 4096, PROT_READ | PROT_WRITE,
> 			MAP_PRIVATE | MAP_ANON | MAP_GROWSDOWN, 0, 0);
> 	if (stack == MAP_FAILED)
> 		return -1;
> 
> 	stack += 4 * 4096;
> 	return clone(do_child, stack, SIGCHLD | CLONE_CHILD_USEPID, pstree_path, NULL, NULL, &pid);
> 
> }
> #endif
> 
> static int restore_task_with_children(int my_pid, char *pstree_path)
> {
> 	int *pids;
> 	int fd, ret, i;
> 	struct pstree_entry e;
> 
> 	printf("%d: Starting restore\n", my_pid);
> 
> 	fd = open(pstree_path, O_RDONLY);
> 	if (fd < 0) {
> 		perror("Can't reopen pstree image");
> 		exit(1);
> 	}
> 
> 	lseek(fd, sizeof(__u32), SEEK_SET);
> 	while (1) {
> 		ret = read(fd, &e, sizeof(e));
> 		if (ret != sizeof(e)) {
> 			fprintf(stderr, "%d: Read returned %d\n", my_pid, ret);
> 			if (ret < 0)
> 				perror("Can't read pstree");
> 			exit(1);
> 		}
> 
> 		if (e.pid != my_pid) {
> 			lseek(fd, e.nr_children * sizeof(__u32), SEEK_CUR);
> 			continue;
> 		}
> 		
> 		break;
> 	}
> 
> 	if (e.nr_children > 0) {
> 		i = e.nr_children * sizeof(int);
> 		pids = malloc(i);
> 		ret = read(fd, pids, i);
> 		if (ret != i) {
> 			perror("Can't read children pids");
> 			exit(1);
> 		}
> 
> 		close(fd);
> 
> 		printf("%d: Restoring %d children:\n", my_pid, e.nr_children);
> 		for (i = 0; i < e.nr_children; i++) {
> 			printf("\tFork %d from %d\n", pids[i], my_pid);
> 			ret = fork_with_pid(pids[i], pstree_path);
> 			if (ret < 0) {
> 				perror("Can't fork kid");
> 				exit(1);
> 			}
> 		}
> 	} else
> 		close(fd);
> 
> 	shmem_update_real_pid(my_pid, getpid());
> 
> 	return restore_one_task(my_pid);
> }
> 
> static int restore_root_task(char *pstree_path, int fd)
> {
> 	struct pstree_entry e;
> 	int ret;
> 
> 	ret = read(fd, &e, sizeof(e));
> 	if (ret != sizeof(e)) {
> 		perror("Can't read root pstree entry");
> 		return 1;
> 	}
> 
> 	close(fd);
> 
> 	printf("Forking root with %d pid\n", e.pid);
> 	ret = fork_with_pid(e.pid, pstree_path);
> 	if (ret < 0) {
> 		perror("Can't fork root");
> 		return 1;
> 	}
> 
> 	wait(NULL);
> 	return 0;
> }
> 
> static int restore_all_tasks(char *pid)
> {
> 	char path[128];
> 	int pstree_fd;
> 	__u32 type = 0;
> 
> 	sprintf(path, "pstree-%s.img", pid);
> 	pstree_fd = open(path, O_RDONLY);
> 	if (pstree_fd < 0) {
> 		perror("Can't open pstree image");
> 		return 1;
> 	}
> 
> 	read(pstree_fd, &type, sizeof(type));
> 	if (type != PSTREE_MAGIC) {
> 		perror("Bad pstree magic");
> 		return 1;
> 	}
> 
> 	if (prepare_shared(pstree_fd))
> 		return 1;
> 
> 	return restore_root_task(path, pstree_fd);
> }
> 
> int main(int argc, char **argv)
> {
> 	if (argc != 3)
> 		goto usage;
> 	if (argv[1][0] != '-')
> 		goto usage;
> 	if (argv[1][1] == 'p')
> 		return restore_one_task(atoi(argv[2]));
> 	if (argv[1][1] == 't')
> 		return restore_all_tasks(argv[2]);
> 
> usage:
> 	printf("Usage: %s (-t|-p) <pid>\n", argv[0]);
> 	return 1;
> }

> #include <stdio.h>
> #include <unistd.h>
> #include <fcntl.h>
> #include <stdlib.h>
> #include <linux/types.h>
> #include <string.h>
> #include "img_structs.h"
> #include "binfmt_img.h"
> 
> static int show_fdinfo(int fd)
> {
> 	char data[1024];
> 	struct fdinfo_entry e;
> 
> 	while (1) {
> 		int ret;
> 
> 		ret = read(fd, &e, sizeof(e));
> 		if (ret == 0)
> 			break;
> 		if (ret != sizeof(e)) {
> 			perror("Can't read");
> 			return 1;
> 		}
> 
> 		ret = read(fd, data, e.len);
> 		if (ret != e.len) {
> 			perror("Can't read");
> 			return 1;
> 		}
> 
> 		data[e.len] = '\0';
> 		switch (e.type) {
> 		case FDINFO_FD:
> 			printf("fd %d [%s] pos %lx flags %o\n", (int)e.addr, data, e.pos, e.flags);
> 			break;
> 		case FDINFO_MAP:
> 			printf("map %lx [%s] flags %o\n", e.addr, data, e.flags);
> 			break;
> 		default:
> 			fprintf(stderr, "Unknown fdinfo entry type %d\n", e.type);
> 			return 1;
> 		}
> 	}
> 
> 	return 0;
> }
> 
> #define PAGE_SIZE	4096
> 
> static int show_mem(int fd)
> {
> 	__u64 vaddr;
> 	unsigned int data[2];
> 
> 	while (1) {
> 		if (read(fd, &vaddr, 8) == 0)
> 			break;
> 		if (vaddr == 0)
> 			break;
> 
> 		read(fd, &data[0], sizeof(unsigned int));
> 		lseek(fd, PAGE_SIZE - 2 * sizeof(unsigned int), SEEK_CUR);
> 		read(fd, &data[1], sizeof(unsigned int));
> 
> 		printf("\tpage 0x%lx [%x...%x]\n", (unsigned long)vaddr, data[0], data[1]);
> 	}
> 
> 	return 0;
> }
> 
> static int show_pages(int fd)
> {
> 	return show_mem(fd);
> }
> 
> static int show_shmem(int fd)
> {
> 	int r;
> 	struct shmem_entry e;
> 
> 	while (1) {
> 		r = read(fd, &e, sizeof(e));
> 		if (r == 0)
> 			return 0;
> 		if (r != sizeof(e)) {
> 			perror("Can't read shmem entry");
> 			return 1;
> 		}
> 
> 		printf("%016lx-%016lx %016x\n", e.start, e.end, e.shmid);
> 	}
> }
> 
> static char *segval(__u16 seg)
> {
> 	switch (seg) {
> 		case CKPT_X86_SEG_NULL:		return "nul";
> 		case CKPT_X86_SEG_USER32_CS:	return "cs32";
> 		case CKPT_X86_SEG_USER32_DS:	return "ds32";
> 		case CKPT_X86_SEG_USER64_CS:	return "cs64";
> 		case CKPT_X86_SEG_USER64_DS:	return "ds64";
> 	}
> 
> 	if (seg & CKPT_X86_SEG_TLS)
> 		return "tls";
> 	if (seg & CKPT_X86_SEG_LDT)
> 		return "ldt";
> 
> 	return "[unknown]";
> }
> 
> static int show_regs(int fd)
> {
> 	struct binfmt_regs_image ri;
> 
> 	if (read(fd, &ri, sizeof(ri)) != sizeof(ri)) {
> 		perror("Can't read registers from image");
> 		return 1;
> 	}
> 
> 	printf("Registers:\n");
> 
> 	printf("\tr15:     %016lx\n", ri.r15);
> 	printf("\tr14:     %016lx\n", ri.r14);
> 	printf("\tr13:     %016lx\n", ri.r13);
> 	printf("\tr12:     %016lx\n", ri.r12);
> 	printf("\tr11:     %016lx\n", ri.r11);
> 	printf("\tr10:     %016lx\n", ri.r10);
> 	printf("\tr9:      %016lx\n", ri.r9);
> 	printf("\tr8:      %016lx\n", ri.r8);
> 	printf("\tax:      %016lx\n", ri.ax);
> 	printf("\torig_ax: %016lx\n", ri.orig_ax);
> 	printf("\tbx:      %016lx\n", ri.bx);
> 	printf("\tcx:      %016lx\n", ri.cx);
> 	printf("\tdx:      %016lx\n", ri.dx);
> 	printf("\tsi:      %016lx\n", ri.si);
> 	printf("\tdi:      %016lx\n", ri.di);
> 	printf("\tip:      %016lx\n", ri.ip);
> 	printf("\tflags:   %016lx\n", ri.flags);
> 	printf("\tbp:      %016lx\n", ri.bp);
> 	printf("\tsp:      %016lx\n", ri.sp);
> 	printf("\tgs:      %016lx\n", ri.gs);
> 	printf("\tfs:      %016lx\n", ri.fs);
> 	printf("\tgsindex: %s\n", segval(ri.gsindex));
> 	printf("\tfsindex: %s\n", segval(ri.fsindex));
> 	printf("\tcs:      %s\n", segval(ri.cs));
> 	printf("\tss:      %s\n", segval(ri.ss));
> 	printf("\tds:      %s\n", segval(ri.ds));
> 	printf("\tes:      %s\n", segval(ri.es));
> 
> 	printf("\ttls0     %016lx\n", ri.tls[0]);
> 	printf("\ttls1     %016lx\n", ri.tls[1]);
> 	printf("\ttls2     %016lx\n", ri.tls[2]);
> 
> 	return 0;
> }
> 
> static int show_mm(int fd, unsigned long *stack)
> {
> 	struct binfmt_mm_image mi;
> 
> 	if (read(fd, &mi, sizeof(mi)) != sizeof(mi)) {
> 		perror("Can't read mm from image");
> 		return 1;
> 	}
> 
> 	printf("MM:\n");
> 	printf("\tflags:       %016lx\n", mi.flags);
> 	printf("\tdef_flags:   %016lx\n", mi.def_flags);
> 	printf("\tstart_code:  %016lx\n", mi.start_code);
> 	printf("\tend_code:    %016lx\n", mi.end_code);
> 	printf("\tstart_data:  %016lx\n", mi.start_data);
> 	printf("\tend_data:    %016lx\n", mi.end_data);
> 	printf("\tstart_brk:   %016lx\n", mi.start_brk);
> 	printf("\tbrk:         %016lx\n", mi.brk);
> 	printf("\tstart_stack: %016lx\n", mi.start_stack);
> 	printf("\targ_start:   %016lx\n", mi.arg_start);
> 	printf("\targ_end:     %016lx\n", mi.arg_end);
> 	printf("\tenv_start:   %016lx\n", mi.env_start);
> 	printf("\tenv_end:     %016lx\n", mi.env_end);
> 
> 	*stack = mi.start_stack;
> 
> 	return 0;
> }
> 
> static int show_vmas(int fd, unsigned long stack)
> {
> 	struct binfmt_vma_image vi;
> 
> 	printf("VMAs:\n");
> 	while (1) {
> 		char *note = "";
> 
> 		if (read(fd, &vi, sizeof(vi)) != sizeof(vi)) {
> 			perror("Can't read vma from image");
> 			return 1;
> 		}
> 
> 		if (vi.start == 0 && vi.end == 0)
> 			return 0;
> 
> 		if (vi.start <= stack && vi.end >= stack)
> 			note = "[stack]";
> 
> 		printf("\t%016lx-%016lx file %d %016lx prot %x flags %x %s\n",
> 				vi.start, vi.end, vi.fd, vi.pgoff,
> 				vi.prot, vi.flags, note);
> 	}
> }
> 
> static int show_privmem(int fd)
> {
> 	printf("Pages:\n");
> 	return show_mem(fd);
> }
> 
> static int show_core(int fd)
> {
> 	__u32 version = 0;
> 	unsigned long stack;
> 
> 	read(fd, &version, 4);
> 	if (version != BINFMT_IMG_VERS_0) {
> 		printf("Unsupported version %d\n", version);
> 		return 1;
> 	}
> 
> 	printf("Showing version 0\n");
> 
> 	if (show_regs(fd))
> 		return 1;
> 
> 	if (show_mm(fd, &stack))
> 		return 1;
> 
> 	if (show_vmas(fd, stack))
> 		return 1;
> 
> 	if (show_privmem(fd))
> 		return 1;
> 
> 	return 0;
> }
> 
> static int show_pstree(int fd)
> {
> 	int ret;
> 	struct pstree_entry e;
> 
> 	while (1) {
> 		int i;
> 		__u32 *ch;
> 
> 		ret = read(fd, &e, sizeof(e));
> 		if (ret == 0)
> 			return 0;
> 		if (ret != sizeof(e)) {
> 			perror("Can't read processes entry");
> 			return 1;
> 		}
> 
> 		printf("%d:", e.pid);
> 		i = e.nr_children * sizeof(__u32);
> 		ch = malloc(i);
> 		ret = read(fd, ch, i);
> 		if (ret != i) {
> 			perror("Can't read children list");
> 			return 1;
> 		}
> 
> 		for (i = 0; i < e.nr_children; i++)
> 			printf(" %d", ch[i]);
> 		printf("\n");
> 	}
> }
> 
> static int show_pipes(int fd)
> {
> 	struct pipes_entry e;
> 	int ret;
> 	char buf[17];
> 
> 	while (1) {
> 		ret = read(fd, &e, sizeof(e));
> 		if (ret == 0)
> 			break;
> 		if (ret != sizeof(e)) {
> 			perror("Can't read pipe entry");
> 			return 1;
> 		}
> 
> 		printf("%d: %lx %o %d ", e.fd, e.pipeid, e.flags, e.bytes);
> 		if (e.flags & O_WRONLY) {
> 			printf("\n");
> 
> 			if (e.bytes) {
> 				printf("Bogus pipe\n");
> 				return 1;
> 			}
> 
> 			continue;
> 		}
> 
> 		memset(buf, 0, sizeof(buf));
> 		ret = e.bytes;
> 		if (ret > 16)
> 			ret = 16;
> 
> 		read(fd, buf, ret);
> 		printf("\t[%s", buf);
> 		if (ret < e.bytes)
> 			printf("...");
> 		printf("]\n");
> 		lseek(fd, e.bytes - ret, SEEK_CUR);
> 	}
> 
> 	return 0;
> 
> }
> 
> int main(int argc, char **argv)
> {
> 	__u32 type;
> 	int fd;
> 
> 	fd = open(argv[1], O_RDONLY);
> 	if (fd < 0) {
> 		perror("Can't open");
> 		return 1;
> 	}
> 
> 	read(fd, &type, 4);
> 
> 	if (type == FDINFO_MAGIC)
> 		return show_fdinfo(fd);
> 	if (type == PAGES_MAGIC)
> 		return show_pages(fd);
> 	if (type == SHMEM_MAGIC)
> 		return show_shmem(fd);
> 	if (type == PSTREE_MAGIC)
> 		return show_pstree(fd);
> 	if (type == PIPES_MAGIC)
> 		return show_pipes(fd);
> 	if (type == BINFMT_IMG_MAGIC)
> 		return show_core(fd);
> 
> 	printf("Unknown file type 0x%x\n", type);
> 	return 1;
> }

> 
> #define FDINFO_MAGIC	0x01010101
> 
> struct fdinfo_entry {
> 	__u8	type;
> 	__u8	len;
> 	__u16	flags;
> 	__u32	pos;
> 	__u64	addr;
> };
> 
> #define FDINFO_FD	1
> #define FDINFO_MAP	2
> 
> #define PAGES_MAGIC	0x20202020
> 
> #define SHMEM_MAGIC	0x03300330
> 
> struct shmem_entry {
> 	__u64	start;
> 	__u64	end;
> 	__u64	shmid;
> };
> 
> #define PSTREE_MAGIC	0x40044004
> 
> struct pstree_entry {
> 	__u32	pid;
> 	__u32	nr_children;
> };
> 
> #define PIPES_MAGIC	0x05055050
> 
> struct pipes_entry {
> 	__u32	fd;
> 	__u32	pipeid;
> 	__u32	flags;
> 	__u32	bytes;
> };

> all: cr-dump img-show cr-restore
> 
> img-show: img-show.c
> 	gcc -o $@ $<
> 
> cr-dump: cr-dump.c
> 	gcc -o $@ $<
> 
> cr-restore: cr-restore.c
> 	gcc -o $@ $<
> 
> clean:
> 	rm -f cr-dump img-show cr-restore

> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers

For any subsequent postings could you split this up into multiple
emails -- perhaps one per file? Or perhaps make them patches to the
kernel's tools directory?

Cheers,
	-Matt Helsley
