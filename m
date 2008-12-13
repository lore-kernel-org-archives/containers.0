From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] pid: Implement ns_of_pid
Date: Fri, 12 Dec 2008 18:34:54 -0800
Message-ID: <20081213023454.GA4147@us.ibm.com>
References: <20081213023144.GA3951@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756124AbYLMCfw@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081213023144.GA3951@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Oleg Nesterov <oleg@tv-sign.ru>, roland@redhat.com, bastian@waldi.eu.org, Pavel Emelyanov <xemul@openvz.org>, sukadev@linux.vnet.ibm.com, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Resending with complete cc list.

Sukadev Bhattiprolu [sukadev@linux.vnet.ibm.com] wrote:
| This and following patch were discussed a couple of times but I
| did not see any objections to them. The ns_of_pid() introduced
| here will also be used in a follow-on patch to fix si_pid from
| mqueue.
| 
| ---
| From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
| Date: Fri, 12 Dec 2008 11:44:55 -0800
| Subject: [PATCH 1/2] pid: Implement ns_of_pid
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
| Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
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
