From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH][RFC] checkpoint: refuse to checkpoint if
	monitoring	directories with dnotify
Date: Thu, 18 Feb 2010 11:52:21 -0500
Message-ID: <4B7D7045.90305@cs.columbia.edu>
References: <06e8a57fc278e96c909ff3c0f1a167cee7a48dd5.1266444614.git.matthltc@us.ibm.com>
	<20100218002422.GG3604@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100218002422.GG3604-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


After self-review:
Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

Will pull for v19.

Oren.

Matt Helsley wrote:
> Reviewing my own patch...
> 
> On Wed, Feb 17, 2010 at 02:10:58PM -0800, Matt Helsley wrote:
> 
> <snip>
> 
>> diff --git a/fs/notify/dnotify/dnotify.c b/fs/notify/dnotify/dnotify.c
>> index 7e54e52..9ce85f5 100644
>> --- a/fs/notify/dnotify/dnotify.c
>> +++ b/fs/notify/dnotify/dnotify.c
>> @@ -289,6 +289,28 @@ static int attach_dn(struct dnotify_struct *dn, struct dnotify_mark_entry *dnent
>>  	return 0;
>>  }
>>
>> +int is_dnotify_attached(struct file *filp)
>> +{
>> +	struct fsnotify_mark_entry *entry;
>> +	struct dnotify_mark_entry *dnentry;
>> +	struct dnotify_struct *dn;
>> +	struct dnotify_struct **prev;
> 
> Ugh, most of these variables aren't needed.
> 
>> +	struct inode *inode;
>> +
>> +	inode = filp->f_path.dentry->d_inode;
>> +	if (!S_ISDIR(inode->i_mode))
>> +		return 0;
>> +
>> +	spin_lock(&inode->i_lock);
>> +	entry = fsnotify_find_mark_entry(dnotify_group, inode);
>> +	spin_unlock(&inode->i_lock);
>> +	if (entry) {
>> +		fsnotify_put_mark(new_entry);
>> +		return 1;
>> +	}
> 
> I flipped the test to look more like normal kernel code and fixed the
> parameter to fsnotify_put_mark():
> 
> 	if (!entry)
> 		return 0;
> 	fsnotify_put_mark(entry);
> 	return 1;
> 
> Cheers,
> 	-Matt Helsley
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 
