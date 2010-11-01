From: Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 0/3] rcu - removing superfluous rcu_read_lock_held check
Date: Mon,  1 Nov 2010 20:15:06 +0100
Message-ID: <1288638909-10541-1-git-send-email-jolsa@redhat.com>
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
To: dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, paul.moore-VXdhtT5mjnY@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, dipankar-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

hi,

the rcu_dereference_check is defined as

  #define rcu_dereference_check(p, c) \
     __rcu_dereference_check((p), rcu_read_lock_held() || (c), __rcu)

so the caller does not need to specify rcu_read_lock_held()
condition.

Several places in kernel are spcifying rcu_read_lock_held as
rcu_dereference_check condition parameter.  I separated them
into 3 patches:

1/3 - cgroup - removing superfluous rcu_read_lock_held check
2/3 - kernel,cred,kvm,security - removing superfluous rcu_read_lock_held check
3/3 - net - removing superfluous rcu_read_lock_held check


sry if I might missed or added somebody wrongly to recipients

wbr,
jirka


Signed-off-by: Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 include/linux/cgroup.h             |    1 -
 include/linux/cred.h               |    1 -
 include/linux/fdtable.h            |    1 -
 include/linux/kvm_host.h           |    1 -
 include/linux/rtnetlink.h          |    3 +--
 include/net/sock.h                 |    3 +--
 kernel/cgroup.c                    |    6 ++----
 kernel/exit.c                      |    1 -
 kernel/pid.c                       |    1 -
 kernel/rcutorture.c                |    2 --
 net/mac80211/sta_info.c            |    4 ----
 net/netlabel/netlabel_domainhash.c |    3 +--
 net/netlabel/netlabel_unlabeled.c  |    3 +--
 security/keys/keyring.c            |    1 -
 14 files changed, 6 insertions(+), 25 deletions(-)
