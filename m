From: Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>
Subject: Re: [PATCH 01/29] task containersv11 basic task container framework
Date: Sat, 29 Sep 2007 22:10:30 -0700
Message-ID: <20070929221030.04881227.pj@sgi.com>
References: <20070911195239.997111000@menage.corp.google.com>
	<20070911200144.779221000@menage.corp.google.com>
	<20070929214043.57e9cc39.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070929214043.57e9cc39.pj-sJ/iWh9BUns@public.gmane.org>
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

I had to push down all of the following patches, before I could get it to build:

    task-containersv11-basic-task-container-framework.patch
    task-containersv11-basic-task-container-framework-fix.patch
    task-containersv11-basic-task-container-framework-containers-fix-refcount-bug.patch
    task-containersv11-add-tasks-file-interface.patch
    task-containersv11-add-fork-exit-hooks.patch
    task-containersv11-add-container_clone-interface.patch
    task-containersv11-add-container_clone-interface-containers-fix-refcount-bug.patch
    task-containersv11-add-procfs-interface.patch
    task-containersv11-add-procfs-interface-containers-bdi-init-hooks.patch
    task-containersv11-shared-container-subsystem-group-arrays.patch
    task-containersv11-shared-container-subsystem-group-arrays-avoid-lockdep-warning.patch
    task-containersv11-shared-container-subsystem-group-arrays-include-fix.patch

That's a big stretch of forbidden territory for innocent bisecters.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org> 1.925.600.0401
