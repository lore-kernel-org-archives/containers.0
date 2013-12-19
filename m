From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] audit: listen in all network namespaces
Date: Thu, 19 Dec 2013 11:59:22 +0800
Message-ID: <52B26F1A.9070308@cn.fujitsu.com>
References: <1374006760-7687-1-git-send-email-rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1374006760-7687-1-git-send-email-rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 07/17/2013 04:32 AM, Richard Guy Briggs wrote:
> Convert audit from only listening in init_net to use register_pernet_subsys()
> to dynamically manage the netlink socket list.
> 
> Signed-off-by: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---

I think it's the time for us to discuss if we should revert this
commit, since this one prevent me from continuing to achieve
audit namespace.


The major problem is in kaudit_send_skb, we have no idea which
audit sock the skb should send to.

in this patch, there only is one auditd proecess, so the
audit_sock is the only one. but when we have audit namespace.
there will be multi audit socks. we have to store audit_sock
into auditns(auditns will be passed to kauditd_send_skb),
this will cause auditns have to get a reference of netns.
and for some reason(netfilter audit target), netns will
get reference of auditns too. this is terrible...

So why not we revert this one, and use a very simple one to
replace it? the below patch will save us from the refer to
each other case, achieve the same effect.

what's your opinion?


Add a compare function which always return true for
audit netlink socket, this will cause audit netlink
sockets netns unaware, and no matter which netns the
user space audit netlink sockets belong to, they all
can find out and communicate with audit_sock.

This gets rid of the necessary to create per-netns
audit kernel side socket(audit_sock), it's pain to
depend on and get reference of netns for auditns.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/audit.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/kernel/audit.c b/kernel/audit.c
index 7b0e23a..468950b 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -886,12 +886,18 @@ static void audit_receive(struct sk_buff  *skb)
 	mutex_unlock(&audit_cmd_mutex);
 }

+static bool audit_compare(struct net *net, struct sock *sk)
+{
+	return true;
+}
+
 /* Initialize audit support at boot time. */
 static int __init audit_init(void)
 {
 	int i;
 	struct netlink_kernel_cfg cfg = {
 		.input	= audit_receive,
+		.compare = audit_compare,
 	};

 	if (audit_initialized == AUDIT_DISABLED)
