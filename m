From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [v2][PATCH 2/5] Parse mount options just once and copy them to
	super block
Date: Wed, 4 Feb 2009 18:10:10 -0600
Message-ID: <20090205001010.GC17354@us.ibm.com>
References: <20090204043516.GB25963@us.ibm.com> <20090204043705.GB26202@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759748AbZBEAK3@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090204043705.GB26202@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, hpa@zytor.com, hch@lst.de, sukadev@us.ibm.com, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting Sukadev Bhattiprolu (sukadev@linux.vnet.ibm.com):
> 
> From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
> Date: Tue, 27 Jan 2009 23:15:47 -0800
> Subject: [v2][PATCH 2/5] Parse mount options just once and copy them to super block
> 
> Since all the mount option parsing is done in devpts, we could do it
> just once and pass it around in devpts functions and eventually store
> it in the super block.
> ---
>  fs/devpts/inode.c |  100 ++++++++++++-----------------------------------------
>  1 files changed, 22 insertions(+), 78 deletions(-)

Nice ratio of - to +....

> @@ -495,17 +434,22 @@ static int init_pts_mount(struct file_system_type *fs_type, int flags,
>  static int devpts_get_sb(struct file_system_type *fs_type,
>  	int flags, const char *dev_name, void *data, struct vfsmount *mnt)
>  {
> -	int new;
> -
> -	new = is_new_instance_mount(data);
> -	if (new < 0)
> -		return new;
> +	int error;
> +	struct pts_mount_opts opts;
> 
> -	if (new)
> -		return new_pts_mount(fs_type, flags, data, mnt);
> +	memset(&opts, 0, sizeof(opts)); 
> +	if (data) {
> +		error = parse_mount_options(data, PARSE_MOUNT, &opts);

Is there any reason to keep the PARSE_MOUNT argument to
parse_mount_options?

> +		if (error)
> +			return error;
> +	}
> 
> -	return init_pts_mount(fs_type, flags, data, mnt);
> +	if (opts.newinstance)
> +		return new_pts_mount(fs_type, flags, data, &opts, mnt);
> +	else
> +		return init_pts_mount(fs_type, flags, data, &opts, mnt);
>  }
> +
>  #else
>  /*
>   * This supports only the legacy single-instance semantics (no
> -- 
> 1.5.2.5
