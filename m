From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [v2][PATCH 5/5] Merge code for single and multiple-instance
	mounts
Date: Fri, 6 Feb 2009 12:51:42 -0600
Message-ID: <20090206185142.GA29582@us.ibm.com>
References: <20090204043516.GB25963@us.ibm.com> <20090204043813.GE26202@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757233AbZBFSwJ@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090204043813.GE26202@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, hpa@zytor.com, hch@lst.de, sukadev@us.ibm.com, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting Sukadev Bhattiprolu (sukadev@linux.vnet.ibm.com):
> 
> From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
> Date: Wed, 28 Jan 2009 19:11:15 -0800
> Subject: [v2][PATCH 5/5] Merge code for single and multiple-instance mounts
> 
> new_pts_mount() (including the get_sb_nodev()), shares a lot of code
> with init_pts_mount(). The only difference between them is the 'test-super'
> function passed into sget().
> 
> Move all common code into devpts_get_sb() and remove the new_pts_mount() and
> init_pts_mount() functions,
> 
> Changelog[v2]:
> 	(Christoph Hellwig): Merge code in 'do_pts_mount()' into devpts_get_sb()
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>

Acked-by: Serge Hallyn <serue@us.ibm.com>
Tested-by: Serge Hallyn <serue@us.ibm.com>

except that:

> @@ -414,24 +365,41 @@ static int devpts_get_sb(struct file_system_type *fs_type,
>  			return error;
>  	}
> 
> -	if (opts.newinstance)
> -		error = new_pts_mount(fs_type, flags, data, &opts, mnt);
> -	else
> -		error = init_pts_mount(fs_type, flags, data, &opts, mnt);
> +	if (opts.newinstance) {
> +		printk(KERN_NOTICE "devpts: newinstance mount\n");
> +		s = sget(fs_type, NULL, set_anon_super, NULL);
> +	} else {
> +		printk(KERN_NOTICE "devpts: single-instance mount\n");

These printks probably shouldn't stay in...

> +		s = sget(fs_type, compare_init_pts_sb, set_anon_super, NULL);
> +	}

thanks,
-serge
