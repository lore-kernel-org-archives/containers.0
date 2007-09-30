From: Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>
Subject: Re: [PATCH 01/29] task containersv11 basic task container framework
Date: Sat, 29 Sep 2007 21:40:43 -0700
Message-ID: <20070929214043.57e9cc39.pj@sgi.com>
References: <20070911195239.997111000@menage.corp.google.com>
	<20070911200144.779221000@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070911200144.779221000-B63HFAS8fGlSzHKm+aFRNNkmqwFzkYv6@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
Cc: dev-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Paul M:

This patch doesn't build for me in the following case.  If I apply the
rest of the containersv11 patches, it builds, but if I happen to bisect
into this set of patches having applied only:

  task-containersv11-basic-task-container-framework.patch

while using sn2_defconfig (with CONFIG_CGROUPS=y), then a build for
arch ia64 fails with:


$ make kernel/cgroup.o
  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  CALL    scripts/checksyscalls.sh
<stdin>:1389:2: warning: #warning syscall revokeat not implemented
<stdin>:1393:2: warning: #warning syscall frevoke not implemented
  CC      kernel/cgroup.o
kernel/cgroup.c: In function 'cgroup_new_inode':
kernel/cgroup.c:227: error: variable 'cgroup_backing_dev_info' has initializer but incomplete type
kernel/cgroup.c:228: error: unknown field 'capabilities' specified in initializer
kernel/cgroup.c:228: error: 'BDI_CAP_NO_ACCT_DIRTY' undeclared (first use in this function)
kernel/cgroup.c:228: error: (Each undeclared identifier is reported only once
kernel/cgroup.c:228: error: for each function it appears in.)
kernel/cgroup.c:228: error: 'BDI_CAP_NO_WRITEBACK' undeclared (first use in this function)
kernel/cgroup.c:228: warning: excess elements in struct initializer
kernel/cgroup.c:228: warning: (near initialization for 'cgroup_backing_dev_info')
kernel/cgroup.c:227: error: storage size of 'cgroup_backing_dev_info' isn't known
kernel/cgroup.c:227: warning: unused variable 'cgroup_backing_dev_info'
make[1]: *** [kernel/cgroup.o] Error 1
make: *** [kernel/cgroup.o] Error 2


I haven't tested building other partial applications of the
containersv11 patch set; any initial sequence of them should build.

... also ... too bad the names of these patches all have 'container' in
them, not 'cgroup'.  I realize how this came to be, due to changing
container to cgroup after these patches were named, but it sure would
be nice if the final patch set record that gets layed down in Linus's
history showed the correct name of 'cgroup' in these patch names.

Well ... nice in my view ... such a patch rename would create more work
for Andrew, so I can't claim to know what he will think of this patch
name detail.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org> 1.925.600.0401
