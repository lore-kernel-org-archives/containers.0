From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCHSET] Sysfs cleanups from Eric W. Biederman
Date: Wed, 22 Aug 2007 11:26:08 +0200
Message-ID: <20070822112608.1645030c@gondolin.boeblingen.de.ibm.com>
References: <11876133893720-git-send-email-htejun@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762613AbXHVJY7@vger.kernel.org>
In-Reply-To: <11876133893720-git-send-email-htejun@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Tejun Heo <htejun@gmail.com>
Cc: ebiederm@xmission.com, greg@kroah.com, linux-kernel@vger.kernel.org, satyam@infradead.org, stern@rowland.harvard.edu, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Mon, 20 Aug 2007 21:36:29 +0900,
Tejun Heo <htejun@gmail.com> wrote:

> Hello, all.
> 
> This is subset of Eric W. Biederman's "Sysfs cleanups & tagged
> directory support" patchset[1] with the following modifications.
> 
> * fix-i_mutex-locking-in-sysfs_get_dentry patch is added at the top
>   and #14-Don_t-use-lookup_one_len_kern and
>   #15-vfs-Remove-lookup_one_len_kern are dropped.  This is because #14
>   contained had a bug where it might created dentry/inode for an
>   already deleted sysfs_dirent.  I think it's benefitial to keep
>   single lookup path.
> 
> * Rewrote simplify-sysfs_get_dentry patch and
>   #08-Implement-__sysfs_get_dentry,
>   #09-Move-sysfs_get_dentry-below-__sysfs_get_dentry and
>   #10-Rewrite-sysfs_get_dentry-in-terms-of-__sysfs_get_dentry are
>   omitted as __sysfs_get_dentry() isn't used by anyone.
> 
> * #16, 19-25 are omitted as it isn't clear yet how the tagged entry
>   support will end up.
> 
> * readdir simplification fixed.
> 
> * sysfs_mutex double locking fixed.
> 
> The patchset is on top of the current -gregkh.

Survives some casual testing (including moving devices). Patches look
sane to me at a cursory glance as well (sorry, don't have much time at
the moment).
