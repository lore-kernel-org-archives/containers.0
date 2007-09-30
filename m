From: Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>
Subject: Re: [PATCH 01/29] task containersv11 basic task container framework
Date: Sat, 29 Sep 2007 22:14:25 -0700
Message-ID: <20070929221425.f591f0ca.pj@sgi.com>
References: <20070911195239.997111000@menage.corp.google.com>
	<20070911200144.779221000@menage.corp.google.com>
	<20070929214043.57e9cc39.pj@sgi.com>
	<20070929221030.04881227.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070929221030.04881227.pj-sJ/iWh9BUns@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>
Cc: dev-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

And then I pushed just one more patch:

  task-containersv11-automatic-userspace-notification-of-idle-containers.patch

and the build died again:

$ make kernel/cgroup.o
  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  CALL    scripts/checksyscalls.sh
<stdin>:1389:2: warning: #warning syscall revokeat not implemented
<stdin>:1393:2: warning: #warning syscall frevoke not implemented
  CC      kernel/cgroup.o
kernel/cgroup.c: In function 'cgroup_release_agent':
kernel/cgroup.c:2725: error: implicit declaration of function 'call_usermodehelper'
kernel/cgroup.c:2725: error: 'UMH_WAIT_EXEC' undeclared (first use in this function)
kernel/cgroup.c:2725: error: (Each undeclared identifier is reported only once
kernel/cgroup.c:2725: error: for each function it appears in.)
make[1]: *** [kernel/cgroup.o] Error 1
make: *** [kernel/cgroup.o] Error 2


-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org> 1.925.600.0401
