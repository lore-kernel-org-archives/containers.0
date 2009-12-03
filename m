From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: ckpt-v19-rc2
Date: Thu, 03 Dec 2009 15:31:09 -0600
Message-ID: <1259875869.8693.30.camel@localhost.localdomain>
References: <Pine.LNX.4.64.0912012352420.5665@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-/H+SwZnh35QjaAOgczgn"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0912012352420.5665-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


--=-/H+SwZnh35QjaAOgczgn
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Wed, 2009-12-02 at 00:23 -0500, Oren Laadan wrote:
> I put together ckpt-v19-rc2 (kernel and user)

I'm not sure yet whether this is a regression, but checkpoint seems to
be unable to handle file mappings that extend past the end of the file.
I noticed this with Fedora 11 userspace on powerpc (ld.so sometimes maps
libraries this way).  I did not see this failure with a v19-rc1-based
kernel I tested earlier this week, but I haven't retested with that yet.

Here's an example - 8K mapping of a 4K file:

# stat -c%s /tmp/myfile 
4096

# grep myfile /proc/5164/maps
f7e2b000-f7e2d000 r--p 00000000 08:06 5103709                            /tmp/myfile

# checkpoint 5164 > /tmp/mmap.ckpt
checkpoint: Bad address

When we try to follow the mapping past the end of the file, we get
VM_FAULT_SIGBUS from handle_mm_fault(); the stack trace from debugging
code I added is:

.__get_dirty_page+0x4c/0x164 (unreliable)
.checkpoint_memory_contents+0x134/0x5a4
.private_vma_checkpoint+0xf4/0x120
.filemap_checkpoint+0x198/0x1d0
.checkpoint_mm+0x3c4/0x4fc
.checkpoint_obj+0x17c/0x1d0
.checkpoint_obj_mm+0x50/0x88
.checkpoint_task+0x710/0xaa0
.do_checkpoint+0x9c0/0xb24
.SyS_checkpoint+0xd0/0x11c

Attached is a testcase.


--=-/H+SwZnh35QjaAOgczgn
Content-Disposition: attachment; filename="mmap.c"
Content-Type: text/x-csrc; name="mmap.c"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/types.h>

static size_t page_sz;	/* system page size */
static size_t file_sz;	/* size of the file */
static size_t map_sz;	/* size of the mapping to establish */

static const char *filepath = "myfile";

static void setup(void)
{
	page_sz = sysconf(_SC_PAGESIZE);
	file_sz = page_sz;
	map_sz  = file_sz + page_sz;
}

static void bail_perror(const char *msg)
{
	perror(msg);
	exit(1);
}

static void bail_msg(const char *msg)
{
	fprintf(stderr, "%s\n", msg);
	exit(1);
}

int create_file(size_t sz)
{
	const void *buf;
	ssize_t written;
	struct stat sb;
	int fd;
	int rc;

	rc = unlink(filepath);
	if (rc < 0 && errno != ENOENT)
		bail_perror("unlink");

	fd = open(filepath, (O_RDWR | O_CREAT | O_EXCL), S_IRUSR);
	if (fd < 0)
		bail_perror("creat");

	buf = calloc(1, sz);
	if (!buf)
		bail_perror("calloc");

	written = 0;
	while (written < sz) {
		ssize_t res;
		/* unsigned char zero = '\0'; */

		res = write(fd, buf + written, sz - written);

		if (res < 0)
			bail_perror("write");

		written += res;
	}

	/* check size */
	rc = fstat(fd, &sb);
	if (rc < 0)
		bail_perror("fstat");

	if (sb.st_size != sz)
		bail_msg("unexpected file size");

	return fd;
}

void map_file(int fd, size_t map_sz)
{
	void *addr;

	addr = mmap(NULL, map_sz, PROT_READ, MAP_PRIVATE, fd, 0);
	if (addr == MAP_FAILED)
		bail_perror("mmap");
}

int main(int argc, char **argv)
{
	int fd;

	setup();

	fd = create_file(file_sz);
	map_file(fd, map_sz);

	printf("ready\n");
	pause();

	return 0;
}

--=-/H+SwZnh35QjaAOgczgn
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--=-/H+SwZnh35QjaAOgczgn--
