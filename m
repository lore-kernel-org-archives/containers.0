From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: kernel BUG at fs/dcache.c:1363 (from cgroup)
Date: Fri, 14 Jan 2011 12:56:17 +0800
Message-ID: <4D2FD771.9040301__33405.9629393325$1294981085$gmane$org@cn.fujitsu.com>
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
To: viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org, Nick Piggin <npiggin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Just mount the cgroupfs:

# mount -t cgroup -o cpuset xxx /mnt
(oops!!)

The bug is caused by:

=========
commit 0df6a63f8735a7c8a877878bc215d4312e41ef81
Author: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Date:   Tue Dec 21 13:29:29 2010 -0500

    switch cgroup
    
    switching it to s_d_op allows to kill the cgroup_lookup() kludge.
    
    Signed-off-by: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
=========

This line:

+       sb->s_d_op = &cgroup_dops;

will cause the dentry op be set twice, and thus trigger the bomb:

struct dentry *d_alloc(struct dentry * parent, const struct qstr *name)
{
	...
        if (parent) {
		...
                d_set_d_op(dentry, dentry->d_sb->s_d_op);
		...
        }
	...
}

static struct dentry *d_alloc_and_lookup(struct dentry *parent,
                                struct qstr *name, struct nameidata *nd)
{
	...
        dentry = d_alloc(parent, name);
	...
        old = inode->i_op->lookup(inode, dentry, nd);
	...
}

simple_lookup() will call d_set_d_op()...


==============

[   90.740906] kernel BUG at fs/dcache.c:1360!
..
[   90.810321] Call Trace:
[   90.814166]  [<c04f97ad>] simple_lookup+0x26/0x3c
[   90.818015]  [<c04e86ce>] d_alloc_and_lookup+0x36/0x54
[   90.818021]  [<c04e8aa8>] __lookup_hash+0x6a/0x71
[   90.818026]  [<c04e8f33>] lookup_one_len+0x81/0x90
[   90.818034]  [<c0473083>] cgroup_add_file+0x8e/0x132
[   90.818041]  [<c0473152>] cgroup_add_files+0x2b/0x3d
[   90.818047]  [<c0473188>] cgroup_populate_dir+0x24/0xdb
[   90.818053]  [<c047360b>] cgroup_mount+0x3cc/0x431
[   90.818061]  [<c04e238d>] vfs_kern_mount+0x57/0x109
[   90.818066]  [<c047323f>] ? cgroup_mount+0x0/0x431
[   90.818072]  [<c04e248e>] do_kern_mount+0x38/0xba
[   90.818077]  [<c04f6706>] do_mount+0x5e4/0x60f
[   90.818082]  [<c04f6094>] ? copy_mount_options+0x78/0xd7
[   90.818087]  [<c04f68de>] sys_mount+0x66/0x94
[   90.818093]  [<c040329f>] sysenter_do_call+0x12/0x38
