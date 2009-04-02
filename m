From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/3] c/r: Add UTS support (v6)
Date: Thu, 02 Apr 2009 10:54:10 -0700
Message-ID: <87wsa32b7h.fsf@caffeine.danplanet.com>
References: <1238533107-11796-1-git-send-email-danms@us.ibm.com>
	<1238533107-11796-3-git-send-email-danms@us.ibm.com>
	<20090402174451.GC9984@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

SH> One thing to note is that this will drive the ns cgroup bananas.
SH> It might still be worthwhile collecting the flags for all the
SH> to-be-unshared namespaces, and then doing all of the unsharing at
SH> once.

Okay, that's fair.

SH> Futhermore, you do sys_unshare here, then further down you do
SH> another copy_namespaces(CLONE_NEWUTS)?

That's in the case where our UTS namespace has already been created by
a previous task.  We need to copy_namespaces() in order to get a new
nsproxy (since our nsproxy must be copied if we no longer share all
namespaces with our parent).  I have to pass a clone flag to it to get
it to do anything.  I promptly drop my hold on that new UTS namespace
and replace it in my new nsproxy with the one from the objhash that my
predecessor created (which is kinda ugly).

SH> Finally, it seems to me every task will unshare(CLONE_NEWUTS), no?
SH> Where is the check done (and stored) for whether this task has a
SH> different utsns from its parent?

No, tasks only unshare() if their UTS namespace objref is not found in
the objhash (thus indicating that they're the first of that namespace
to be restarted).

Perhaps you're referring to the fact that all tasks call
copy_namespaces() (if they're not the first).  You're correct there,
but I'm not sure that a check to see if we need to
(i.e. task->nsproxy->uts == uts) because at the time that the tasks
were created, none of them had done their unshare() yet).

SH> Save identifiers for all of the namespaces at the top of the
SH> checkpoint image; have restart create a set of dummy tasks, enough
SH> to contain all of the new namespaces; have each unshare their
SH> namespaces; then, as each real new task is restarted, manually
SH> create a new nsproxy and link it to all of the required new
SH> namespaces.

Well, that's an option I suppose.  Oren said he wanted to avoid an
additional loop over all tasks during checkpoint and preferred that it
all be stored with the task itself.  Oren?

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
