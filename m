From: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 10/11] fuse: Allow user namespace mounts
Date: Thu, 15 Feb 2018 09:46:51 +0100
Message-ID: <CAOssrKf+d3PcHxT-GTfpESONywk9kFanmnzrX4EN=1XUpizFsg__33505.0469883301$1518684324$gmane$org@mail.gmail.com>
References: <cover.1512741134.git.dongsu@kinvolk.io>
	<a26103156b3f6ba73b1e46c6f577f1bee74872d9.1512041070.git.dongsu@kinvolk.io>
	<CAOssrKcHOp9OaCWRALsxe5MTk+tv7Gi5rPsHz2VLguzK-P+LMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAOssrKcHOp9OaCWRALsxe5MTk+tv7Gi5rPsHz2VLguzK-P+LMw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Feb 14, 2018 at 2:44 PM, Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Fri, Dec 22, 2017 at 3:32 PM, Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org> wrote:
>> From: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>>
>> To be able to mount fuse from non-init user namespaces, it's necessary
>> to set FS_USERNS_MOUNT flag to fs_flags.
>>
>> Patch v4 is available: https://patchwork.kernel.org/patch/8944681/
>>
>> Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> Cc: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>> Signed-off-by: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>> [dongsu: add a simple commit messasge]
>> Signed-off-by: Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
>> ---
>>  fs/fuse/inode.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
>> index 7f6b2e55..8c98edee 100644
>> --- a/fs/fuse/inode.c
>> +++ b/fs/fuse/inode.c
>> @@ -1212,7 +1212,7 @@ static void fuse_kill_sb_anon(struct super_block *sb)
>>  static struct file_system_type fuse_fs_type = {
>>         .owner          = THIS_MODULE,
>>         .name           = "fuse",
>> -       .fs_flags       = FS_HAS_SUBTYPE,
>> +       .fs_flags       = FS_HAS_SUBTYPE | FS_USERNS_MOUNT,
>>         .mount          = fuse_mount,
>>         .kill_sb        = fuse_kill_sb_anon,
>>  };
>
> I think enabling FS_USERNS_MOUNT should be pretty safe.
>
> I was thinking opting out should be as simple as "chmod o-rw
> /dev/fuse".  But that breaks libfuse, even though fusermount opens
> /dev/fuse in privileged mode, so it shouldn't.

I'm talking rubbish, /dev/fuse is opened without privs in fusermount as well.

So there's not way to differentiate user_ns unpriv mounts from suid
fusermount unpriv mounts.

Maybe that's just as well...

Thanks,
Miklos
