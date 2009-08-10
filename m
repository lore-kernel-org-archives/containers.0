From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][v4][PATCH 7/7]: Define clone_with_pids syscall
Date: Mon, 10 Aug 2009 15:26:19 -0700
Message-ID: <20090810222619.GA4805__3855.17640174857$1249943390$gmane$org@us.ibm.com>
References: <20090807061103.GA19343@us.ibm.com>
	<20090807061517.GG20672@us.ibm.com> <20090810145425.GA1378@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090810145425.GA1378-+ZI9xUNit7I@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Pavel Machek [pavel-+ZI9xUNit7I@public.gmane.org] wrote:
| Hi!
| 
| > 
| > Subject: [RFC][v4][PATCH 7/7]: Define clone_with_pids syscall
| > 
| > Container restart requires that a task have the same pid it had when it was
| > checkpointed. When containers are nested the tasks within the containers
| > exist in multiple pid namespaces and hence have multiple pids to specify
| > during restart.
| > 
| > clone_with_pids(), intended for use during restart, is the same as clone(),
| > except that it takes a 'target_pid_set' paramter. This parameter lets caller
| > choose specific pid numbers for the child process, in the process's active
| > and ancestor pid namespaces. (Descendant pid namespaces in general don't
| > matter since processes don't have pids in them anyway, but see comments
| > in copy_target_pids() regarding CLONE_NEWPID).
| 
| This should go to documentation/manpage somewhere.

Agree. Will update once we have some consensus on the interface.

The interface defined in this patch 7/7 

	syscall(__NR_clone_with_pids, flags, stack, NULL, NULL, NULL, &pid_set);

meets the requirements of checkpoint/restart. But as mentioned in patch 0/7,
we are just not sure if we should take this opportunity to address the
clone-flags limitation so we are not forced to define another flavor of
clone() soon.

Sukadev
