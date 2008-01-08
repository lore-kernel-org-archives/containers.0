From: Dave Hansen <haveblue@us.ibm.com>
Subject: Re: [patch 5/9] unprivileged mounts: allow unprivileged bind mounts
Date: Tue, 08 Jan 2008 10:12:38 -0800
Message-ID: <1199815958.9834.58.camel@localhost>
References: <20080108113502.184459371@szeredi.hu>
	 <20080108113626.895583537@szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20080108113626.895583537@szeredi.hu>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, hch@infradead.org, serue@us.ibm.com, viro@ftp.linux.org.uk, ebiederm@xmission.com, kzak@redhat.com, linux-fsdevel@vger.kernel.org, containers@lists.osdl.org, util-linux-ng@vger.kernel.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On Tue, 2008-01-08 at 12:35 +0100, Miklos Szeredi wrote:
> +static int reserve_user_mount(void)
> +{
> +       int err = 0;
> +
> +       spin_lock(&vfsmount_lock);
> +       if (nr_user_mounts >= max_user_mounts && !capable(CAP_SYS_ADMIN))
> +               err = -EPERM;
> +       else
> +               nr_user_mounts++;
> +       spin_unlock(&vfsmount_lock);
> +       return err;
> +} 

Would -ENOSPC or -ENOMEM be a more descriptive error here?  

-- Dave

