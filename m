From: Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
Subject: Re: [PATCH 01/11] block_dev: Support checking inode permissions in
	lookup_bdev()
Date: Sat, 23 Dec 2017 13:00:56 +0100
Message-ID: <CANxcAMuqpWaMOSOjo812uqvTyfKogc7=uA+tgwhzetQU1Ynm4w__19257.7923452065$1514030426$gmane$org@mail.gmail.com>
References: <cover.1512741134.git.dongsu@kinvolk.io>
	<ef5e609602df6d7e2b4aa07b92600f04b6851902.1512041070.git.dongsu@kinvolk.io>
	<17fbec10-68b1-2d2b-d417-2cdfee22b0fa@coly.li>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <17fbec10-68b1-2d2b-d417-2cdfee22b0fa-53JG2FQvpdo@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Coly Li <i@coly.li>
Cc: linux-bcache-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Jan Kara <jack-IBi9RG/b67k@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

On Fri, Dec 22, 2017 at 7:59 PM, Coly Li <i@coly.li> wrote:
> On 22/12/2017 10:32 PM, Dongsu Park wrote:
> Hi Dongsu,
>
> Could you please use a macro like NO_PERMISSION_CHECK to replace hard
> coded 0 ? At least for me, I don't need to check what does 0 mean in the
> new lookup_bdev().

I see. I'll do that.

Thanks,
Dongsu

> Thanks.
>
> Coly Li
>
>> ---
>>  drivers/md/bcache/super.c |  2 +-
>>  drivers/md/dm-table.c     |  2 +-
>>  drivers/mtd/mtdsuper.c    |  2 +-
>>  fs/block_dev.c            | 13 ++++++++++---
>>  fs/quota/quota.c          |  2 +-
>>  include/linux/fs.h        |  2 +-
>>  6 files changed, 15 insertions(+), 8 deletions(-)
>>
>> diff --git a/drivers/md/bcache/super.c b/drivers/md/bcache/super.c
>> index b4d28928..acc9d56c 100644
>> --- a/drivers/md/bcache/super.c
>> +++ b/drivers/md/bcache/super.c
>> @@ -1967,7 +1967,7 @@ static ssize_t register_bcache(struct kobject *k, struct kobj_attribute *attr,
>>                                 sb);
>>       if (IS_ERR(bdev)) {
>>               if (bdev == ERR_PTR(-EBUSY)) {
>> -                     bdev = lookup_bdev(strim(path));
>> +                     bdev = lookup_bdev(strim(path), 0);
>>                       mutex_lock(&bch_register_lock);
>>                       if (!IS_ERR(bdev) && bch_is_open(bdev))
>>                               err = "device already registered";
>> diff --git a/drivers/md/dm-table.c b/drivers/md/dm-table.c
>> index 88130b5d..bca5eaf4 100644
> [snip]
>
>
> --
> Coly Li
