From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] proc: Supply proc_shrink_automounts when CONFIG_PROC_FS=N
Date: Fri, 07 Nov 2008 08:04:40 -0800
Message-ID: <m18wrvv7xj.fsf_-_@frodo.ebiederm.org>
References: <m1ej1p2l6u.fsf@frodo.ebiederm.org>
	<m1abcd2kqk.fsf@frodo.ebiederm.org>
	<20081107044118.GA21330@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753427AbYKGQFb@vger.kernel.org>
In-Reply-To: <20081107044118.GA21330@x200.localdomain> (Alexey Dobriyan's
	message of "Fri, 7 Nov 2008 07:41:18 +0300")
Sender: linux-kernel-owner@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org


Alexey Dobriyan <adobriyan@gmail.com> writes:

>>  	tracehook_prepare_release_task(p);
>>  	atomic_dec(&p->user->processes);
>> +	proc_shrink_automounts();
>
> This, of course, won't compile when PROC_FS=n.

Which of course leads to this incremental patch.

Oops.  I forgot to account for the rare but possible
case of someone not compiling procfs into their kernel.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/proc_fs.h |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 52cc6bd..394593d 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -207,6 +207,9 @@ static inline void proc_net_remove(struct net *net, const char *name) {}
 static inline void proc_flush_task(struct task_struct *task)
 {
 }
+static inline void proc_shrink_automounts(void)
+{
+}
 
 static inline struct proc_dir_entry *create_proc_entry(const char *name,
 	mode_t mode, struct proc_dir_entry *parent) { return NULL; }
-- 
1.5.3.rc6.17.g1911
