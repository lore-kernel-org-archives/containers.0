From: sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Subject: Re: [PATCH 09/10] Enable multiple instances of devpts
Date: Mon, 29 Sep 2008 08:18:28 -0700
Message-ID: <20080929151828.GA10202@us.ibm.com>
References: <20080912174845.GA17350@us.ibm.com>
	<20080912175322.GJ17350@us.ibm.com>
	<20080924202616.GB31664@us.ibm.com>
	<20080926210347.GB31505@us.ibm.com>
	<20080929130131.GA12531@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080929130131.GA12531-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
| Quoting sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
| > | > @@ -232,6 +246,8 @@ static int devpts_show_options(struct seq_file *seq, struct vfsmount *vfs)
| > | >  	seq_printf(seq, ",mode=%03o", opts->mode);
| > | >  #ifdef CONFIG_DEVPTS_MULTIPLE_INSTANCES
| > | >  	seq_printf(seq, ",ptmxmode=%03o", opts->ptmxmode);
| > | > +	if (opts->newinstance)
| > | > +		seq_printf(seq, ",newinstance");
| > | 
| > | Is actually that something we want to show?  It doesn't seem
| > | informative.
| > 
| > Without this users have no easy way of knowing whether they have a 
| > private mount specially if they mounted from command line ?

You mean in a nested container ? I agree that it does not help then.

| 
| If they were in a container to begin with, then they still don't know.
| 
| Now if you were to keep a unique per-instance id and have show_options
| list 'instance=%x', that would be helpful.  Either that or just
| dropping the info altogether make sense.  This 'newinstance' listing
| is meaningless.
| 

Another way to look at it is that it is a mount option that was specified
and we just report it. It may not be useful always but might help in some
cases. But I am fine either way.

<snip>

| > | > +
| > | > +		err = mknod_ptmx(mnt->mnt_sb);
| > | > +		if (err) {
| > | > +			dput(mnt->mnt_sb->s_root);
| > | > +			deactivate_super(mnt->mnt_sb);
| > | > +		} else
| > | > +			devpts_mnt = mnt;
| > | > +
| > | > +		return err;
| > | 
| > | There is no locking here, so in early-userspace two competing processes
| > | could both try to set devpts_mnt, right?
| > 
| > Hmm. I was thinking there would be only one thread calling the
| > vfs_kern_mount() in init_devpts_fs.
| 
| But what if init happens to (perhaps mistakenly) lead to 2 racing ones?
| 
| Sure it's just a small memory leak, but why not just prevent it.

Ok.

| 
| > | 
| > | > +	}
| > | > +
| > | > +	return get_sb_ref(devpts_mnt->mnt_sb, flags, data, mnt);
| > | > +}
| > | > +
| > | >  static int devpts_get_sb(struct file_system_type *fs_type,
| > | >  	int flags, const char *dev_name, void *data, struct vfsmount *mnt)
| > | >  {
| > | > +	int new;
| > | > +
| > | > +	new = is_new_instance_mount(data);
| > | > +	if (new < 0)
| > | > +		return new;
| > | > +
| > | > +	if (new)
| > | > +		return new_pts_mount(fs_type, flags, data, mnt);
| > | > +
| > | > +	return init_pts_mount(fs_type, flags, data, mnt);
| > | 
| > | Wait a sec - so if a container does
| > | 
| > | 	mount -t devpts -o newinstance none /dev/pts
| > | 	and then later on just does
| > | 	mount -t devpts none /dev/pts
| > | 
| > | it'll get the init_pts_ns, not the one it had created?
| > 
| > Yes.  Should we treat the latter as remount of the private instance ?
| > If so, user could add '-oremount' ?
| > 
| > The logic seems simple: With newinstance create a private namespace.
| > Without newinstance, bind to initial ns.
| 
| But if I'm in a container in a new mounts ns and somehow managed 
| to umount -l /dev/pts, shouldn't i be able to remount my container's
| devpts by just doing 'mount -t devpts devpts /dev/pts'?

Now wouldn't that require us to associate the devpts mount with some
notion of a container ? (a namespace object in nsproxy of container-init 
like we do with /proc).

Yes, after 'umount -l'  we have lost _that_ devpts ns and we may have to
'redo' the relevant container-init parts
