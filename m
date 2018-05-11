From: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC PATCH v4 0/5] ima: Namespacing IMA
Date: Fri, 11 May 2018 10:42:25 -0400
Message-ID: <20180511144230.75384-1-stefanb__26690.4306867675$1526049650$gmane$org@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-integrity-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: mkayaalp-4hyTIkVWTs8LubxHQvXPfYdd74u8MsAO@public.gmane.org, sunyuqiong1988-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, david.safford-JJi787mZWgc@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, john.johansen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

This patch set implements an IMA namespace data structure that gets
created by first writing a '1' into IMA's securityfs unshare file at
/sys/kernel/security/ima/unshare and then by clone(). This patch set
lays down the foundation for namespacing the different aspects of IMA
(eg. IMA-audit, IMA-measurement, IMA-appraisal).

The original PoC patches created a new CLONE_NEWIMA flag to explicitly
control when a new IMA namespace should be created. The previously posted
version 2 of this series had it hooked on the mount namespace, which was
regarded as inappropriate. The subsequent v3 tied it to the creation of a
user namespace. Based on comments, we elected to now again create an
independent IMA namespace through the above mentioned securityfs file.

The first patch creates the ima_namespace data, while the second patch
puts the iint->flags in the namespace. The third patch introduces an
audit message type for  IMA policy rules. The fourth patch introduces
a new IMA policy rule attribute 'ns' making rules only applicable to child
IMA namespaces. The last patch uses the flags for namespacing the
IMA-audit messages, enabling the same file to be audited each time it
is accessed in a new namespace.

   Stefan

Mehmet Kayaalp (2):
  ima: Add ns_status for storing namespaced iint data
  ima: namespace audit status flags

Mimi Zohar (1):
  ima: differentiate auditing policy rules from "audit" actions

Stefan Berger (1):
  ima: extend IMA audit policy rules with attribute to audit namespaces

Yuqiong Sun (1):
  ima: Add IMA namespace support

 fs/proc/namespaces.c                     |   3 +
 include/linux/ima.h                      |  53 +++++++++
 include/linux/nsproxy.h                  |   2 +
 include/linux/proc_ns.h                  |   1 +
 include/linux/sched.h                    |   6 +
 include/linux/user_namespace.h           |   1 +
 include/uapi/linux/audit.h               |   3 +-
 init/Kconfig                             |  11 ++
 kernel/fork.c                            |   5 +
 kernel/nsproxy.c                         |  25 ++++-
 kernel/ucount.c                          |   1 +
 security/integrity/ima/Makefile          |   3 +-
 security/integrity/ima/ima.h             |  82 +++++++++++++-
 security/integrity/ima/ima_api.c         |  14 ++-
 security/integrity/ima/ima_appraise.c    |   2 +-
 security/integrity/ima/ima_fs.c          |  55 ++++++++++
 security/integrity/ima/ima_init.c        |   4 +
 security/integrity/ima/ima_init_ima_ns.c |  51 +++++++++
 security/integrity/ima/ima_main.c        |  18 ++-
 security/integrity/ima/ima_ns.c          | 183 +++++++++++++++++++++++++++++++
 security/integrity/ima/ima_ns_status.c   | 133 ++++++++++++++++++++++
 security/integrity/ima/ima_policy.c      |  77 ++++++++++++-
 22 files changed, 712 insertions(+), 21 deletions(-)
 create mode 100644 security/integrity/ima/ima_init_ima_ns.c
 create mode 100644 security/integrity/ima/ima_ns.c
 create mode 100644 security/integrity/ima/ima_ns_status.c

-- 
2.14.3
