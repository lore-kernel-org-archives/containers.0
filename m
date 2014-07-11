From: "chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org" <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Could not mount sysfs when enable userns but disable netns
Date: Fri, 11 Jul 2014 07:27:53 +0000
Message-ID: <5871495633F38949900D2BF2DC04883E562293@G08CNEXMBPEKD02.g08.fujitsu.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Language: zh-CN
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org)" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, "Serge Hallyn (serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org)" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Greg
	Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

How to reproduce:
1. Prepare a container, enable userns and disable netns
2. use libvirt-lxc to start a container
3. libvirt could not mount sysfs then failed to start.

Then I found that
commit 7dc5dbc879bd0779924b5132a48b731a0bc04a1e says:
"Don't allow mounting sysfs unless the caller has CAP_SYS_ADMIN rights
over the net namespace."

But why should we check sysfs mouont permission over net namespace?
We've already checked CAP_SYS_ADMIN though.

What the relationship between sysfs and net namespace,
or this check is a little redundant?

Any insights on this?

Thanks,
- Chen

PS: codes below could be a workaround

@@ -34,7 +35,8 @@ static struct dentry *sysfs_mount(struct file_system_type *fs_type,
                if (!capable(CAP_SYS_ADMIN) && !fs_fully_visible(fs_type))
                        return ERR_PTR(-EPERM);
 
-               if (!kobj_ns_current_may_mount(KOBJ_NS_TYPE_NET))
+               if (current->nsproxy->net_ns != &init_net &&
+                    !kobj_ns_current_may_mount(KOBJ_NS_TYPE_NET))
                        return ERR_PTR(-EPERM);
        }
