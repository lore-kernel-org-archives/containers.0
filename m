From: sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Subject: Re: [PATCH 06/10] Define mknod_ptmx()
Date: Fri, 26 Sep 2008 14:29:54 -0700
Message-ID: <20080926212954.GE31505@us.ibm.com>
References: <20080912174845.GA17350@us.ibm.com>
	<20080912175237.GG17350@us.ibm.com>
	<20080924185046.GA31535@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080924185046.GA31535-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org
List-Id: containers.vger.kernel.org

Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
| > +	/*
| > +	 * Create a new 'ptmx' node in this mount of devpts.
| > +	 */
| > +	inode = new_inode(sb);
| > +	if (!inode) {
| > +		printk(KERN_ERR "Unable to alloc inode for ptmx node\n");
| > +		dput(dentry);
| > +		return -ENOMEM;
| > +	}
| > +
| > +	inode->i_uid = inode->i_gid = 0;
| > +	inode->i_blocks = 0;
| > +	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
| > +
| > +	mode = S_IFCHR|opts->ptmxmode;
| > +	init_special_inode(inode, mode, MKDEV(TTYAUX_MAJOR, 2));
| > +
| > +	d_add(dentry, inode);
| 
| Actually, you never do dput this dentry.

kill_litter_super() should dput it right ? Earlier we were not caching
ptmx_dentry and so relied on kill_litter_super() to dput.

Now that I have ptmx_dentry cached, I could explicitly dput() in
devpts_kill_sb() and go back to kill_anon_super(). Would that be better
?

| 
| At the moment you need to dput it here, then once you cache it, you
| don't dput it here, but dput the cache one at devpts_kill_sb.  Right?
| 
| > +	printk(KERN_DEBUG "Created ptmx node in devpts ino %lu\n",
| > +			inode->i_ino);
| > +
| > +	return 0;
| > +}
| > +#endif
| > +
| >  static int devpts_remount(struct super_block *sb, int *flags, char *data)
| >  {
| >  	struct pts_fs_info *fsi = DEVPTS_SB(sb);
| > @@ -136,6 +204,9 @@ static int devpts_show_options(struct seq_file *seq, struct vfsmount *vfs)
| >  	if (opts->setgid)
| >  		seq_printf(seq, ",gid=%u", opts->gid);
| >  	seq_printf(seq, ",mode=%03o", opts->mode);
| > +#ifdef CONFIG_DEVPTS_MULTIPLE_INSTANCES
| > +	seq_printf(seq, ",ptmxmode=%03o", opts->ptmxmode);
| > +#endif
| > 
| >  	return 0;
| >  }
| > @@ -156,6 +227,7 @@ static void *new_pts_fs_info(void)
| > 
| >  	ida_init(&fsi->allocated_ptys);
| >  	fsi->mount_opts.mode = DEVPTS_DEFAULT_MODE;
| > +	fsi->mount_opts.ptmxmode = DEVPTS_DEFAULT_PTMX_MODE;
| > 
| >  	return fsi;
| >  }
| > @@ -211,7 +283,7 @@ static void devpts_kill_sb(struct super_block *sb)
| >  	struct pts_fs_info *fsi = DEVPTS_SB(sb);
| > 
| >  	kfree(fsi);
| > -	kill_anon_super(sb);
| > +	kill_litter_super(sb);
| >  }
| > 
| >  static struct file_system_type devpts_fs_type = {
| > -- 
| > 1.5.2.5
