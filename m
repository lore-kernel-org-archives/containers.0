From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: cgroup dentry insufficiently initialized prior to calling
	d_instantiate.
Date: Tue, 14 May 2013 18:47:23 +0800
Message-ID: <5192163B.9010208__18659.7878266641$1368528584$gmane$org@huawei.com>
References: <518D6E7C.9050204@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <518D6E7C.9050204-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
Cc: tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lkml-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 2013/5/11 6:02, Casey Schaufler wrote:
> 
> In kernel/cgroup.c in cgroup_add_file() we have:
> 
> 
>         dentry = lookup_one_len(name, dir, strlen(name));
>         if (IS_ERR(dentry)) {
>                 error = PTR_ERR(dentry);
>                 goto out;
>         }
> 
>         mode = cgroup_file_mode(cft);
>         error = cgroup_create_file(dentry, mode | S_IFREG, cgrp->root->sb);
>         if (!error) {
>                 cfe->type = (void *)cft;
>                 cfe->dentry = dentry;
>                 dentry->d_fsdata = cfe;
>                 simple_xattrs_init(&cfe->xattrs);
>                 list_add_tail(&cfe->node, &parent->files);
>                 cfe = NULL;
>         }
>         dput(dentry);
> 
> cgroup_create_file() calls d_instantiate, which may
> decide to look at the xattrs on the file. Smack always
> does this and SELinux can be configured to do so, although
> no one seems to be using that option. Since the dentry
> has not been initialized panics in __d_xattr ensue. See
> bugzilla 57791.
> 

cgroup_add_file() should initialize xattrs before calling d_instantiate(),
just like cgroup_create() does.

I'll prepare a patch to fix it. Thanks for the report!
