From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [PATCH 3/4] devpts: Make the newinstance option historical
Date: Sun, 23 Sep 2012 05:46:03 +0100
Message-ID: <20120923044603.GN13973@ZenIV.linux.org.uk>
References: <20120124010758.GJ23916@ZenIV.linux.org.uk>
	<m1k44gj1cu.fsf@fess.ebiederm.org>
	<20120124220247.GA26353@hallyn.com>
	<CAPXgP13_gczQmG_USAp0p2AuTfxkzAvzHvjbZY_rbbLH-4rDyg@mail.gmail.com>
	<20120124231601.GA4470@sergelap>
	<CAPXgP12REAwmDORzdGJhsxZKU8nhiauCxoVdKa8Eifw4MWWtgA@mail.gmail.com>
	<20120128195103.GA11299@sergelap> <87txup763i.fsf_-_@xmission.com>
	<87d31d75yj.fsf_-_@xmission.com>
	<20120923041906.GM13973@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120923041906.GM13973-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andy Whitcroft <apw-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, Sep 23, 2012 at 05:19:06AM +0100, Al Viro wrote:
> On Sat, Sep 22, 2012 at 08:50:44PM -0700, Eric W. Biederman wrote:
> 
> > +struct inode *devpts_redirect(struct file *filp)
> > +{
> > +	struct inode *inode;
> > +	struct file *filp2;
> > +
> > +	/* Is the inode already a devpts inode? */
> > +	inode = filp->f_dentry->d_inode;
> > +	if (filp->f_dentry->d_sb->s_magic == DEVPTS_SUPER_MAGIC)
> > +		goto out;
> > +
> > +	/* Is f_dentry->d_parent usable? */
> > +	inode = ERR_PTR(-ENODEV);
> > +	if (filp->f_vfsmnt->mnt_root == filp->f_dentry)
> > +		goto out;
> > +
> > +	/* Is there a devpts inode we can use instead? */
> > +	
> > +	filp2 = file_open_root(filp->f_dentry->d_parent, filp->f_vfsmnt,
> > +			       "pts/ptmx", O_PATH);
> > +	if (!IS_ERR(filp2)) {
> > +		if (filp2->f_dentry->d_sb->s_magic == DEVPTS_SUPER_MAGIC) {
> > +			struct path old;
> > +			old = filp->f_path;
> > +			filp->f_path = filp2->f_path;
> > +			inode = filp->f_dentry->d_inode;
> > +			path_get(&filp->f_path);
> > +			path_put(&old);
> 
> You are welcome to supply an analysis of the reasons why ->open() pulling
> such tricks will not break all kinds of code in VFS.
> > +		}
> > +		fput(filp2);
> 
> ... starting with "what happens when some joker binds /dev/ptmx on
> /dev/pts/ptmx"

Or does mknod /tmp/ptmx c 5 2; mkdir /tmp/pts; ln /tmp/ptmx /tmp/pts/ptmx,
for that matter...
