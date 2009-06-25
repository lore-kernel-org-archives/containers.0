From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] io-controller: do some changes of io.policy interface
Date: Thu, 25 Jun 2009 08:55:13 -0400
Message-ID: <20090625125513.GA25439__29702.9671761722$1245934587$gmane$org@redhat.com>
References: <1245443858-8487-1-git-send-email-vgoyal@redhat.com>
	<1245443858-8487-19-git-send-email-vgoyal@redhat.com>
	<6599ad830906241452t76e64815s7d68a22a6e746a59@mail.gmail.com>
	<4A435038.60406@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A435038.60406-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Jun 25, 2009 at 06:23:52PM +0800, Gui Jianfeng wrote:
> Paul Menage wrote:
> > On Fri, Jun 19, 2009 at 1:37 PM, Vivek Goyal<vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> >> You can use the following format to play with the new interface.
> >> #echo DEV:weight:ioprio_class > /patch/to/cgroup/policy
> >> weight=0 means removing the policy for DEV.
> >>
> >> Examples:
> >> Configure weight=300 ioprio_class=2 on /dev/hdb in this cgroup
> >> # echo /dev/hdb:300:2 > io.policy
> >> # cat io.policy
> >> dev weight class
> >> /dev/hdb 300 2
> > 
> > I think that the read and write should be consistent. Can you just use
> > white-space separation for both, rather than colon-separation for
> > writes and white-space separation for reads?
> > 
> > Also, storing device inode paths statically as strings into the
> > io_policy structure seems wrong, since it's quite possible for the
> > device node that was used originally to be gone by the time that
> > someone reads the io.policy file, or renamed, or even replaced with an
> > inode that refers to to a different block device
> > 
> > My preferred alternatives would be:
> > 
> > - read/write the value as a device number rather than a name
> > - read/write the block device's actual name (e.g. hda or sda) rather
> > than a path to the inode
> > 
> 
> Hi Paul, Vivek
> 
> Here is a patch to fix the issue Paul raised.
> 
> This patch achives the following goals
> 1 According to Paul's comment, Modifing io.policy interface to
>   use device number for read/write directly. 
> 2 Just use white-space separation for both, rather than colon-
>   separation for writes and white-space separation for reads.
> 3 Do more strict checking for inputting.
> 
> old interface:
> Configure weight=300 ioprio_class=2 on /dev/hdb in this cgroup
> # echo "/dev/hdb:300:2" > io.policy
> # cat io.policy
> dev weight class
> /dev/hdb 300 2
> 
> new interface:
> Configure weight=300 ioprio_class=2 on /dev/hdb in this cgroup
> # echo "3:64 300 2" > io.policy
> # cat io.policy
> dev     weight  class
> 3:64    300     2
> 
> Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  block/elevator-fq.c |   59 ++++++++++++++++++++++++++++++++++----------------
>  block/elevator-fq.h |    1 -
>  2 files changed, 40 insertions(+), 20 deletions(-)
> 
> diff --git a/block/elevator-fq.c b/block/elevator-fq.c
> index d779282..83c831b 100644
> --- a/block/elevator-fq.c
> +++ b/block/elevator-fq.c
> @@ -1895,12 +1895,12 @@ static int io_cgroup_policy_read(struct cgroup *cgrp, struct cftype *cft,
>  	if (list_empty(&iocg->policy_list))
>  		goto out;
>  
> -	seq_printf(m, "dev weight class\n");
> +	seq_printf(m, "dev\tweight\tclass\n");
>  
>  	spin_lock_irq(&iocg->lock);
>  	list_for_each_entry(pn, &iocg->policy_list, node) {
> -		seq_printf(m, "%s %lu %lu\n", pn->dev_name,
> -			   pn->weight, pn->ioprio_class);
> +		seq_printf(m, "%u:%u\t%lu\t%lu\n", MAJOR(pn->dev),
> +			   MINOR(pn->dev), pn->weight, pn->ioprio_class);
>  	}
>  	spin_unlock_irq(&iocg->lock);
>  out:
> @@ -1936,44 +1936,65 @@ static struct io_policy_node *policy_search_node(const struct io_cgroup *iocg,
>  	return NULL;
>  }
>  
> -static int devname_to_devnum(const char *buf, dev_t *dev)
> +static int check_dev_num(dev_t dev)
>  {
> -	struct block_device *bdev;
> +	int part = 0;
>  	struct gendisk *disk;
> -	int part;
>  
> -	bdev = lookup_bdev(buf);
> -	if (IS_ERR(bdev))
> +	disk = get_gendisk(dev, &part);
> +	if (!disk || part)
>  		return -ENODEV;
>  
> -	disk = get_gendisk(bdev->bd_dev, &part);
> -	if (part)
> -		return -EINVAL;
> -
> -	*dev = MKDEV(disk->major, disk->first_minor);
> -	bdput(bdev);
> -
>  	return 0;
>  }
>  
>  static int policy_parse_and_set(char *buf, struct io_policy_node *newpn)
>  {
> -	char *s[3], *p;
> +	char *s[4], *p, *major_s = NULL, *minor_s = NULL;
>  	int ret;
> +	unsigned long major, minor;
>  	int i = 0;
> +	dev_t dev;
>  
>  	memset(s, 0, sizeof(s));
> -	while ((p = strsep(&buf, ":")) != NULL) {
> +	while ((p = strsep(&buf, " ")) != NULL) {
>  		if (!*p)
>  			continue;
>  		s[i++] = p;
> +
> +		/* Prevent from inputing too many things */
> +		if (i == 4)
> +			break;
>  	}
>  
> -	ret = devname_to_devnum(s[0], &newpn->dev);
> +	if (i != 3)
> +		return -EINVAL;
> +
> +	p = strsep(&s[0], ":");
> +	if (p != NULL)
> +		major_s = p;
> +	else
> +		return -EINVAL;
> +
> +	minor_s = s[0];
> +	if (!minor_s)
> +		return -EINVAL;
> +
> +	ret = strict_strtoul(major_s, 10, &major);
> +	if (ret)
> +		return -EINVAL;
> +
> +	ret = strict_strtoul(minor_s, 10, &minor);
> +	if (ret)
> +		return -EINVAL;
> +
> +	dev = MKDEV(major, minor);
> +
> +	ret = check_dev_num(dev);
>  	if (ret)
>  		return ret;
>  
> -	strcpy(newpn->dev_name, s[0]);
> +	newpn->dev = dev;
>  
>  	if (s[1] == NULL)
>  		return -EINVAL;
> diff --git a/block/elevator-fq.h b/block/elevator-fq.h
> index b3193f8..7722ebe 100644
> --- a/block/elevator-fq.h
> +++ b/block/elevator-fq.h
> @@ -286,7 +286,6 @@ struct io_group {
>  
>  struct io_policy_node {
>  	struct list_head node;
> -	char dev_name[32];
>  	dev_t dev;
>  	unsigned long weight;
>  	unsigned long ioprio_class;

Hi Gui,

Thanks for the patch. "unsigned long" for ioprio_class is too big. How
about using "unsigned short"? I noticed that in io_cgroup also we are
using "unsigned long". I will fix that.

For storing weight now we are planning to use "unsigned int". Can you
please switch to that.

Thanks
Vivek
