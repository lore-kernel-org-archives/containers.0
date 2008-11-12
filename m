From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH] Implement ns_of_pid()
Date: Tue, 11 Nov 2008 22:53:07 -0800
Message-ID: <20081112065307.GD27806@us.ibm.com>
References: <20081112064139.GA27806@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081112064139.GA27806-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org


Oops, the subject should say [PATCH 1/3]

I forward ported these patches from Eric's patchset and touch
tested them again. I think we were in agreement on this set.
Should we push these 3 patches upstream (after some more testing).

Sukadev

Sukadev Bhattiprolu [sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org] wrote:
| 
| From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
| Date: Mon, 10 Nov 2008 19:03:56 -0800
| Subject: [PATCH 1/3] pid: Implement ns_of_pid
| 
| A current problem with the pid namespace is that it is
| easy to do pid related work after exit_task_namespaces which
| drops the nsproxy pointer.
| 
| However if we are doing pid namespace related work we are
| always operating on some struct pid which retains the pid_namespace
| pointer of the pid namespace it was allocated in.
| 
| So provide ns_of_pid which allows us to find the pid
| namespace a pid was allocated in.
| 
| Using this we have the needed infrastructure to do pid
| namespace related work at anytime we have a struct pid,
| removing the chance of accidentally having a NULL
| pointer dereference when accessing current->nsproxy.
| 
| Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
| ---
|  include/linux/pid.h |   11 +++++++++++
|  1 files changed, 11 insertions(+), 0 deletions(-)
| 
| diff --git a/include/linux/pid.h b/include/linux/pid.h
| index d7e98ff..e9aec85 100644
| --- a/include/linux/pid.h
| +++ b/include/linux/pid.h
| @@ -122,6 +122,17 @@ int next_pidmap(struct pid_namespace *pid_ns, int last);
|  extern struct pid *alloc_pid(struct pid_namespace *ns);
|  extern void free_pid(struct pid *pid);
|  
| +/* ns_of_pid returns the pid namespace in which the specified
| + * pid was allocated.
| + */
| +static inline struct pid_namespace *ns_of_pid(struct pid *pid)
| +{
| +	struct pid_namespace *ns = NULL;
| +	if (pid)
| +		ns = pid->numbers[pid->level].ns;
| +	return ns;
| +}
| +
|  /*
|   * the helpers to get the pid's id seen from different namespaces
|   *
| -- 
| 1.5.2.5
| 
